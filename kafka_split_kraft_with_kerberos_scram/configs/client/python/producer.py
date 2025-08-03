from confluent_kafka import Producer
import logging
import socket
import time

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
    'client.id': f'python-producer-{socket.gethostname()}',
    'socket.timeout.ms': 30000,
    'retry.backoff.ms': 500
}

TOPIC_NAME = 'cagri-a'

def delivery_callback(err, msg):
    """Callback function for message delivery reports"""
    if err is not None:
        logger.error(f"Failed to send message: {err}")
    else:
        msg_count = int(msg.value().decode('utf-8').replace('cagri', ''))
        if msg_count % 10000 == 0:
            logger.info(f"Sent {msg_count} messages, offset: {msg.offset()}")

try:
    producer = Producer(config)
    logger.info(f"Created producer, sending messages to {TOPIC_NAME}")

    for i in range(1, 100000001):
        message = f"cagri{i}"
        producer.produce(
            topic=TOPIC_NAME,
            value=message.encode('utf-8'),
            callback=delivery_callback
        )

        producer.poll(0)

        if i % 10000 == 0:
            producer.flush()
            
except Exception as e:
    logger.error(f"Error sending messages: {e}")
    import traceback
    traceback.print_exc()
finally:
    logger.info("Flushing and closing producer")
    producer.flush()