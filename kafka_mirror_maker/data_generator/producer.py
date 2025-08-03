import threading
import time
import json
import logging
from collections import deque
from confluent_kafka import Producer, KafkaException, KafkaError
from enum import Enum

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(threadName)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

class ClusterStatus(Enum):
    """Represents the detailed health status of a cluster."""
    HEALTHY = "HEALTHY"
    UNHEALTHY = "UNHEALTHY"
    PROBING = "PROBING"

class SmoothFailoverProducer:
    """
    An advanced producer that handles failover without blocking the application.

    It uses an internal queue and a dispatcher thread to make message production
    asynchronous. Failback to a recovered cluster is handled gracefully in the
    background by probing the cluster's health before switching traffic,
    preventing application freezes.
    """
    def __init__(self, conf_a, conf_b, topic, check_interval=300):
        self.topic = topic
        self.check_interval = check_interval
        
        # Internal queue for messages. The main app thread adds to this queue.
        self._message_queue = deque()
        
        # Enhanced producer configurations
        self.conf_a = self._enhance_config(conf_a.copy(), 'producer-a')
        self.conf_b = self._enhance_config(conf_b.copy(), 'producer-b')
        
        # Initialize producers
        self.prod_a = Producer(self.conf_a)
        self.prod_b = Producer(self.conf_b)
        
        # State management with more detailed status
        self.active_cluster_id = 'A'
        self.cluster_status = {'A': ClusterStatus.HEALTHY, 'B': ClusterStatus.HEALTHY}
        
        # Thread safety and control events
        self.lock = threading.RLock()
        self.shutdown_event = threading.Event()

        self._start_background_threads()
        
        logger.info(f"Initialized with Cluster A ({self.conf_a['bootstrap.servers']}) as primary.")
        logger.info(f"Secondary is Cluster B ({self.conf_b['bootstrap.servers']}).")

    def _enhance_config(self, config, client_id):
        """Applies production-ready default settings."""
        
        # All thinks important for kafka reblance when restart!
        defaults = {
            'client.id': client_id,
            'acks': 'all',
            'retries': 3,
            'message.timeout.ms': 10000,
            'request.timeout.ms': 5000,
            'retry.backoff.ms': 10,
            'enable.idempotence': True,
            'max.in.flight.requests.per.connection': 5,     # Allow some batching for 3 retry
            'linger.ms': 10                                 # Wait up to batch messages
        }
        defaults.update(config)
        return defaults

    def _start_background_threads(self):
        # Not working, not starting threads on background
        # Freezing the application when the swtich cluster-a -> cluster-b
        # No data loss, but need to try to high throughput
        """Starts background threads for polling, dispatching, and recovery checks."""
        threading.Thread(target=self._poll_loop, daemon=True, name="KafkaPollThread").start()
        threading.Thread(target=self._dispatcher_loop, daemon=True, name="DispatcherThread").start()
        threading.Thread(target=self._recovery_checker_loop, daemon=True, name="RecoveryCheckThread").start()

    def _poll_loop(self):
        """Background loop to poll both producers for delivery callbacks."""
        while not self.shutdown_event.is_set():
            try:
                self.prod_a.poll(0.1)
                self.prod_b.poll(0.1)
            except Exception as e:
                logger.error(f"Error in poll loop: {e}", exc_info=True)
            time.sleep(0.1)

    def _dispatcher_loop(self):
        """
        The core worker thread. Reads from the internal queue and sends messages.
        Handles all failover and non-blocking failback logic.
        """
        while not self.shutdown_event.is_set():
            try:
                # --- Step 1: Handle Failback Probing ---
                with self.lock:
                    # If we're on B, but A is recovering, send a test ping
                    if self.active_cluster_id == 'B' and self.cluster_status['A'] == ClusterStatus.PROBING:
                        self._probe_and_recover_cluster_a()

                # --- Step 2: Dispatch a message from the queue ---
                try:
                    key, value, callback = self._message_queue.popleft()
                except IndexError:
                    time.sleep(0.05) # Queue is empty, sleep briefly
                    continue

                # --- Step 3: Send the message to the active cluster ---
                self._send_message(key, value, callback)

            except Exception as e:
                logger.error(f"Dispatcher error: {e}", exc_info=True)
                time.sleep(1) # Avoid busy-looping on unexpected errors
                
    def _recovery_checker_loop(self):
        """Periodically checks if the inactive primary cluster (A) has recovered."""
        while not self.shutdown_event.is_set():
            if self.shutdown_event.wait(self.check_interval):
                break
            
            with self.lock:
                # Only check for recovery if we are currently failed over to B
                if self.active_cluster_id == 'B' and self.cluster_status['A'] == ClusterStatus.UNHEALTHY:
                    logger.info("Recovery-Checker: Setting Cluster A status to PROBING.")
                    self.cluster_status['A'] = ClusterStatus.PROBING

    def _is_critical_failure(self, k_error: KafkaError) -> bool:
        """Determines if a KafkaError indicates a total cluster failure."""
        critical_codes = [
            KafkaError._MSG_TIMED_OUT,
            KafkaError._ALL_BROKERS_DOWN,
            KafkaError._TRANSPORT,
            KafkaError.REQUEST_TIMED_OUT
        ]
        return k_error is not None and k_error.code() in critical_codes

    def _probe_and_recover_cluster_a(self):
        """
        Sends a lightweight metadata request to Cluster A to check if it's fully ready.
        This is non-blocking to the main message flow.
        """
        logger.info("Dispatcher: Sending non-blocking probe to Cluster A.")
        try:
            # A lightweight metadata call is better than sending a real message
            self.prod_a.list_topics(timeout=5)
            # SUCCESS! The cluster is fully responsive.
            logger.info("✅ Dispatcher: Probe SUCCESS. Cluster A is recovered. Switching back.")
            self.active_cluster_id = 'A'
            self.cluster_status['A'] = ClusterStatus.HEALTHY
        except KafkaException as e:
            # Probe failed, still not ready. Log it and stay on B.
            logger.warning(f"Dispatcher: Probe FAILED. Cluster A not ready yet: {e}. Reverting to UNHEALTHY and waiting for next check.")
            # Set back to UNHEALTHY. The recovery checker will set it to PROBING again after the interval.
            self.cluster_status['A'] = ClusterStatus.UNHEALTHY

    def _send_message(self, key, value, callback):
        """Internal method to send a single message and handle potential failure."""
        with self.lock:
            producer = self.prod_a if self.active_cluster_id == 'A' else self.prod_b
            cluster_id = self.active_cluster_id

        try:
            producer.produce(self.topic, key=key, value=value, callback=callback)
            # By flushing here, we make the dispatch synchronous within this thread.
            # This allows us to catch critical errors immediately and trigger failover.
            # It does NOT block the main application thread.
            remaining = producer.flush(10)
            if remaining > 0:
                raise KafkaException(KafkaError(KafkaError._MSG_TIMED_OUT, f"{remaining} message(s) timed out in buffer"))

        except KafkaException as e:
            kafka_error = e.args[0]
            logger.error(f"❌ Dispatcher detected failure on Cluster {cluster_id}: {kafka_error.str()}.")
            
            # If the failure was on the primary cluster (A), trigger failover.
            if cluster_id == 'A' and self._is_critical_failure(kafka_error):
                with self.lock:
                    if self.active_cluster_id == 'A': # Double-check to prevent race conditions
                        logger.critical("🚨 CRITICAL FAILURE on Cluster A. Initiating failover to B.")
                        self.active_cluster_id = 'B'
                        self.cluster_status['A'] = ClusterStatus.UNHEALTHY
                
                # Re-queue the failed message to be tried on Cluster B.
                logger.info(f"Re-queueing message (key: {key.decode() if key else 'N/A'}) for attempt on Cluster B.")
                self._message_queue.appendleft((key, value, callback))
            # If failure is on B, or non-critical on A, the user's callback will have been
            # triggered with the error. We don't re-queue in that case.

        except BufferError:
            logger.warning(f"Producer buffer for Cluster {cluster_id} is full. Re-queueing message.")
            self._message_queue.appendleft((key, value, callback))
            time.sleep(0.5)

    def produce(self, key, value, delivery_callback):
        """
        Adds a message to the internal queue for asynchronous dispatching.
        This method is non-blocking and returns immediately.
        """
        if self.shutdown_event.is_set():
            logger.error("Producer is shutting down, message rejected.")
            return
        self._message_queue.append((key, value, delivery_callback))

    def close(self, timeout=10):
        """Flushes any buffered messages and shuts down the producer."""
        logger.info("Shutting down producer...")
        # Wait for the queue to empty before shutting down
        while len(self._message_queue) > 0:
            logger.info(f"Waiting for {len(self._message_queue)} messages in queue to be dispatched...")
            time.sleep(1)

        self.shutdown_event.set()
        logger.info(f"Flushing final messages with a {timeout}s timeout...")
        self.prod_a.flush(timeout)
        self.prod_b.flush(timeout)
        logger.info("Shutdown complete.")

# --- Example Usage ---
def delivery_report(err, msg):
    """A simple callback to report the status of each message delivery."""
    if err is not None:
        # This will be called for the final failure if both clusters are down
        # or for the initial failure on Cluster A before it's retried on B.
        logger.error(f"Delivery report: FAILED - {err}")
    else:
        topic, partition, offset = msg.topic(), msg.partition(), msg.offset()
        logger.info(f"Delivery report: SUCCESS to {topic} [{partition}] @ {offset}")

if __name__ == "__main__":
    cluster_a_conf = {
        'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    }
    cluster_b_conf = {
        'bootstrap.servers': 'localhost:19091,localhost:29091,localhost:39091',
    }

    producer = SmoothFailoverProducer(
        conf_a=cluster_a_conf,
        conf_b=cluster_b_conf,
        topic="topic-a",
        check_interval=120 # Check every 120 seconds for faster testing
    )

    try:
        i = 0
        while True:
            key = f"{i}".encode('utf-8')
            value = json.dumps({'id': i, 'ts': time.time()}).encode('utf-8')
            
            # This call is now non-blocking
            producer.produce(key, value, delivery_report)
            i += 1
            time.sleep(0) # Send a message every second
            
    except KeyboardInterrupt:
        logger.info("Shutdown signal received.")
    finally:
        producer.close()