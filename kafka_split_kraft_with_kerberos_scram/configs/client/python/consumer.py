import logging
from confluent_kafka import Consumer, KafkaError, KafkaException
import signal

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)

config = {
    'bootstrap.servers': 'broker:9092',
    'security.protocol': 'SASL_SSL',
    'sasl.mechanism': 'SCRAM-SHA-256',
    'sasl.username': 'cagri',
    'sasl.password': 'cagri3541',
    'ssl.ca.location': '/mnt/home/python/client.pem',
    'ssl.endpoint.identification.algorithm': 'none',
    'group.id': 'cagri-consumer',
    'auto.offset.reset': 'earliest',
    'enable.partition.eof': True
}

topic = 'cagri-a'

def sig_handler(sig, frame):
    logger.info("Caught signal {}, terminating...".format(sig))
    global run
    run = False

signal.signal(signal.SIGINT, sig_handler)
signal.signal(signal.SIGTERM, sig_handler)

logger.info(f"Starting consumer with config: {config}")

try:
    logger.info("Creating consumer...")
    consumer = Consumer(config)
    consumer.subscribe([topic])
    logger.info(f"Subscribed to topic: {topic}")
    
    run = True
    
    timeout = 1.0
    
    message_count = 0
    
    logger.info("Starting consumption loop...")
    while run:
        msg = consumer.poll(timeout)
        
        if msg is None:
            continue
            
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                logger.info(f"Reached end of partition {msg.partition()}")
            else:
                logger.error(f"Consumer error: {msg.error()}")
                break
        else:
            message_count += 1
            logger.info(f"Message received [#{message_count}]: topic={msg.topic()}, partition={msg.partition()}, offset={msg.offset()}")
            try:
                value = msg.value().decode('utf-8')
                logger.info(f"Message value: {value}")
            except Exception as e:
                logger.error(f"Error decoding message: {e}")
                logger.info(f"Raw message value: {msg.value()}")

except KafkaException as e:
    logger.error(f"Kafka error: {e}")
except Exception as e:
    logger.error(f"Unexpected error: {e}")
finally:
    try:
        if 'consumer' in locals():
            logger.info("Closing consumer...")
            consumer.close()
            logger.info("Consumer closed")
    except Exception as e:
        logger.error(f"Error closing consumer: {e}")