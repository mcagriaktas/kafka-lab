from confluent_kafka import Producer, KafkaError
import logging
import socket
import time
import sys
import traceback

# --- Logging setup ---
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
MESSAGE_INTERVAL = 1  # seconds

# Global flags
auth_failed = False
delivery_errors = []


def get_config():
    return {
        "bootstrap.servers": "broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092",
        "security.protocol": "SASL_SSL",
        "sasl.mechanism": "SCRAM-SHA-256",
        "sasl.username": SCRAM_USER,
        "sasl.password": SCRAM_PASSWORD,
        "ssl.ca.location": "/mnt/jks/client_chain.pem",
        "ssl.endpoint.identification.algorithm": "none",
        "client.id": f"python-producer-{socket.gethostname()}",
        "socket.timeout.ms": 30000,
        "message.timeout.ms": 30000,
        "request.timeout.ms": 30000,
        "retries": 3,
        "retry.backoff.ms": 500,
        # Enable detailed error callbacks
        "error_cb": error_callback,
        # Increase metadata request timeout
        "metadata.max.age.ms": 30000,
    }


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


def delivery_callback(err, msg):
    """Per-message delivery callback"""
    if err is not None:
        logger.error(f"❌ Delivery failed for message: {err}")
        delivery_errors.append(err)
        
        # Check for auth-related delivery failures
        err_str = str(err)
        if "SASL" in err_str or "authentication" in err_str.lower():
            global auth_failed
            auth_failed = True
    else:
        logger.info(
            f"✅ Delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}"
        )


def verify_connection(producer):
    """Verify broker connectivity before sending messages"""
    logger.info("Verifying broker connection...")
    
    # Request cluster metadata to force connection
    try:
        metadata = producer.list_topics(timeout=10)
        logger.info(f"✅ Connected to cluster with {len(metadata.brokers)} brokers")
        
        # Check if our topic exists
        if TOPIC_NAME in metadata.topics:
            topic_metadata = metadata.topics[TOPIC_NAME]
            logger.info(f"✅ Topic '{TOPIC_NAME}' found with {len(topic_metadata.partitions)} partitions")
            return True
        else:
            logger.warning(f"⚠️  Topic '{TOPIC_NAME}' not found, but connection successful")
            return True
            
    except Exception as e:
        logger.error(f"❌ Connection verification failed: {e}")
        return False


def main():
    global auth_failed, delivery_errors
    
    config = get_config()
    logger.info(f"Creating producer for topic: {TOPIC_NAME}")

    try:
        producer = Producer(config)
        
        # Give time for initial connection and check for auth errors
        logger.info("Waiting for initial connection...")
        time.sleep(2)
        producer.poll(0)
        
        if auth_failed:
            logger.error("❌ Authentication failed during initialization. Exiting.")
            sys.exit(1)
        
        # Verify connection before proceeding
        if not verify_connection(producer):
            logger.error("❌ Could not verify broker connection. Exiting.")
            sys.exit(1)
        
        # Main produce loop
        successful_sends = 0
        for i in range(1, MESSAGE_COUNT + 1):
            if auth_failed:
                logger.error("❌ Authentication failed. Stopping producer.")
                break

            message = f"cagri-{i}"
            try:
                producer.produce(
                    topic=TOPIC_NAME, 
                    value=message.encode("utf-8"), 
                    callback=delivery_callback
                )
                
                # Poll to trigger callbacks and check for errors
                events = producer.poll(0.5)
                
                if auth_failed:
                    logger.error("❌ Authentication error detected during poll. Stopping.")
                    break
                
                logger.info(f"📤 Queued {i}/{MESSAGE_COUNT}: {message}")
                successful_sends += 1
                
                time.sleep(MESSAGE_INTERVAL)
                
            except BufferError:
                logger.warning("⚠️  Producer queue full, waiting...")
                producer.poll(2)
                continue
            except KafkaError as e:
                logger.error(f"❌ Kafka error during produce: {e}")
                if "SASL" in str(e) or "authentication" in str(e).lower():
                    auth_failed = True
                    break
                continue

        logger.info(f"Flushing {successful_sends} queued messages...")
        remaining = producer.flush(timeout=30)
        
        if remaining > 0:
            logger.error(f"❌ {remaining} messages failed to flush")
        else:
            logger.info("✅ All messages flushed successfully")

    except Exception as e:
        logger.error(f"💥 Fatal error: {e}")
        traceback.print_exc()
        sys.exit(1)
    finally:
        if auth_failed:
            logger.error("🚫 Producer stopped due to invalid SCRAM credentials.")
            logger.error(f"   Username: {SCRAM_USER}")
            logger.error("   Please verify credentials in Kafka ACLs")
            sys.exit(1)
        elif delivery_errors:
            logger.error(f"⚠️  Completed with {len(delivery_errors)} delivery errors")
            sys.exit(1)
        else:
            logger.info("✅ Producer finished cleanly.")


if __name__ == "__main__":
    main()