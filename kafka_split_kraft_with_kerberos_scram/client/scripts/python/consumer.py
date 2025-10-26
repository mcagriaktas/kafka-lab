import logging
from confluent_kafka import Consumer, KafkaError, KafkaException
import signal
import sys
import time

logging.basicConfig(
    level=logging.INFO, 
    format='%(asctime)s %(levelname)s %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

# --- Global Config ---
SCRAM_USER = "kafka"
SCRAM_PASSWORD = "cagri3541"
TOPIC_NAME = "cagri-topic"
MESSAGE_COUNT = 1000

# Global state
run = True
auth_failed = False


def error_callback(err):
    """Global error callback for connection-level errors"""
    global auth_failed
    err_str = str(err)
    logger.error(f"🔥 Kafka error callback: {err}")
    
    # Detect authentication failures
    if (err.code() in [KafkaError._AUTHENTICATION, KafkaError._ALL_BROKERS_DOWN] or
        "SASL" in err_str or 
        "authentication" in err_str.lower() or
        "invalid credentials" in err_str.lower()):
        auth_failed = True
        logger.error("❌ AUTHENTICATION FAILURE DETECTED - Invalid SCRAM credentials")


def configs():
    return {
        'bootstrap.servers': 'broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092',
        'security.protocol': 'SASL_SSL',
        'sasl.mechanism': 'SCRAM-SHA-256',
        'sasl.username': SCRAM_USER,
        'sasl.password': SCRAM_PASSWORD,
        'ssl.ca.location': '/mnt/jks/client_chain.pem',
        'ssl.endpoint.identification.algorithm': 'none',
        'group.id': 'cagri-consumer',
        'auto.offset.reset': 'earliest',
        'enable.partition.eof': True,
        'session.timeout.ms': 30000,
        'heartbeat.interval.ms': 10000,
        'max.poll.interval.ms': 300000,
        'socket.timeout.ms': 30000,
        'request.timeout.ms': 30000,
        # Enable error callback
        'error_cb': error_callback,
        # Enable auto-commit for proper offset management
        'enable.auto.commit': True,
        'auto.commit.interval.ms': 5000,
    }


def sig_handler(sig, frame):
    """Signal handler for graceful shutdown"""
    logger.info(f"⚠️  Caught signal {sig}, initiating graceful shutdown...")
    global run
    run = False


def verify_connection(consumer):
    """Verify broker connectivity and topic existence"""
    logger.info("Verifying broker connection...")
    
    try:
        # Request cluster metadata
        metadata = consumer.list_topics(timeout=10)
        logger.info(f"✅ Connected to cluster with {len(metadata.brokers)} brokers")
        
        # Check if our topic exists
        if TOPIC_NAME in metadata.topics:
            topic_metadata = metadata.topics[TOPIC_NAME]
            logger.info(f"✅ Topic '{TOPIC_NAME}' found with {len(topic_metadata.partitions)} partitions")
            
            # Log partition details
            for partition_id, partition in topic_metadata.partitions.items():
                logger.info(f"   Partition {partition_id}: leader={partition.leader}, replicas={len(partition.replicas)}")
            return True
        else:
            logger.error(f"❌ Topic '{TOPIC_NAME}' not found in cluster")
            available_topics = list(metadata.topics.keys())[:10]  # Show first 10
            logger.error(f"   Available topics (sample): {available_topics}")
            return False
            
    except Exception as e:
        logger.error(f"❌ Connection verification failed: {e}")
        return False


def main():
    global run, auth_failed
    
    # Register signal handlers
    signal.signal(signal.SIGINT, sig_handler)
    signal.signal(signal.SIGTERM, sig_handler)

    config = configs()
    logger.info(f"Starting consumer for topic: {TOPIC_NAME}")
    logger.info(f"Consumer group: {config['group.id']}")
    
    consumer = None
    
    try:
        logger.info("Creating consumer...")
        consumer = Consumer(config)
        
        # Give time for initial connection and check for auth errors
        logger.info("Waiting for initial connection...")
        time.sleep(2)
        
        if auth_failed:
            logger.error("❌ Authentication failed during initialization. Exiting.")
            sys.exit(1)
        
        # Verify connection before subscribing
        if not verify_connection(consumer):
            logger.error("❌ Could not verify broker connection or topic. Exiting.")
            sys.exit(1)
        
        # Subscribe to topic
        consumer.subscribe([TOPIC_NAME])
        logger.info(f"✅ Subscribed to topic: {TOPIC_NAME}")
        
        # Wait for partition assignment
        logger.info("Waiting for partition assignment...")
        assignment_timeout = time.time() + 30
        while not consumer.assignment() and time.time() < assignment_timeout and run:
            consumer.poll(1.0)
            if auth_failed:
                logger.error("❌ Authentication failed during subscription. Exiting.")
                sys.exit(1)
        
        if consumer.assignment():
            logger.info(f"✅ Assigned partitions: {consumer.assignment()}")
        else:
            logger.warning("⚠️  No partitions assigned yet, will retry during consumption")
        
        # Main consumption loop
        message_count = 0
        eof_partitions = set()
        poll_timeout = 1.0
        
        logger.info("🚀 Starting consumption loop...")
        while run:
            if auth_failed:
                logger.error("❌ Authentication failed. Stopping consumer.")
                break
            
            try:
                msg = consumer.poll(poll_timeout)
                
                if msg is None:
                    # No message within timeout
                    continue
                    
                if msg.error():
                    error = msg.error()
                    
                    if error.code() == KafkaError._PARTITION_EOF:
                        partition_key = (msg.topic(), msg.partition())
                        if partition_key not in eof_partitions:
                            logger.info(f"📭 Reached end of partition {msg.partition()} at offset {msg.offset()}")
                            eof_partitions.add(partition_key)
                        continue
                        
                    elif error.code() == KafkaError._UNKNOWN_TOPIC_OR_PART:
                        logger.error(f"❌ Unknown topic or partition: {error}")
                        break
                        
                    elif error.code() in [KafkaError._AUTHENTICATION, KafkaError._ALL_BROKERS_DOWN]:
                        logger.error(f"❌ Authentication/connection error: {error}")
                        auth_failed = True
                        break
                        
                    else:
                        logger.error(f"❌ Consumer error: {error}")
                        # Continue on transient errors
                        continue
                else:
                    # Successfully received message
                    message_count += 1
                    partition_key = (msg.topic(), msg.partition())
                    
                    # Remove from EOF set since we got a new message
                    eof_partitions.discard(partition_key)
                    
                    logger.info(
                        f"📨 Message #{message_count}: "
                        f"topic={msg.topic()}, partition={msg.partition()}, "
                        f"offset={msg.offset()}, timestamp={msg.timestamp()}"
                    )
                    
                    try:
                        value = msg.value().decode('utf-8')
                        logger.info(f"   Value: {value}")
                    except UnicodeDecodeError:
                        logger.warning(f"   ⚠️  Could not decode as UTF-8, raw bytes: {msg.value()[:100]}")
                    except Exception as e:
                        logger.error(f"   ❌ Error processing message: {e}")
                        
            except KeyboardInterrupt:
                logger.info("⚠️  Keyboard interrupt received")
                break
                
    except KafkaException as e:
        logger.error(f"💥 Kafka exception: {e}")
        sys.exit(1)
    except Exception as e:
        logger.error(f"💥 Unexpected error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        if consumer is not None:
            try:
                logger.info("Closing consumer...")
                # Get final position before closing
                try:
                    assignment = consumer.assignment()
                    if assignment:
                        logger.info("Final consumer positions:")
                        for tp in assignment:
                            position = consumer.position([tp])[0]
                            logger.info(f"  {tp.topic}[{tp.partition}]: offset {position.offset}")
                except Exception as e:
                    logger.warning(f"Could not retrieve final positions: {e}")
                
                consumer.close()
                logger.info("✅ Consumer closed cleanly")
            except Exception as e:
                logger.error(f"❌ Error closing consumer: {e}")
        
        if auth_failed:
            logger.error("🚫 Consumer stopped due to authentication failure.")
            logger.error(f"   Username: {config['sasl.username']}")
            logger.error("   Please verify SCRAM credentials in Kafka cluster")
            sys.exit(1)
        else:
            logger.info(f"✅ Consumer finished. Total messages consumed: {message_count}")


if __name__ == "__main__":
    main()