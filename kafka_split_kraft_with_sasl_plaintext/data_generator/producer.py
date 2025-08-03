from confluent_kafka import Producer
import logging
from time import sleep

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)

config = {
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'security.protocol': 'SASL_PLAINTEXT',
    'sasl.mechanism': 'PLAIN',
    'sasl.username': 'clientproducer',
    'sasl.password': 'cagri3541',
    'ssl.endpoint.identification.algorithm': 'none',
    'client.id': 'cagri-client',
    'socket.timeout.ms': 30000,
    'retry.backoff.ms': 500
}

TOPIC_NAME = 'cagri-topic'

def delivery_callback(err, msg):
    if err is not None:
        logger.error(f"Failed to send message: {err}")
    else:
        key = msg.key().decode('utf-8') if msg.key() is not None else None
        value = msg.value().decode('utf-8') if msg.value() is not None else None
        logger.info(f"key: {key}, value: {value}, partition: {msg.partition()}, offset: {msg.offset()}")

try:
    producer = Producer(config)
    logger.info(f"Created producer, sending messages to {TOPIC_NAME}")

    for i in range(1, 100000001):
        message = f"cagri{i}"
        key = f"key{i}"
        producer.produce(
            topic=TOPIC_NAME,
            key=key.encode('utf-8'),
            value=message.encode('utf-8'),
            callback=delivery_callback
        )

        producer.poll(0)

        if i % 10000 == 0:
            producer.flush()
        
        sleep(1)

except Exception as e:
    logger.error(f"Error sending messages: {e}")
    import traceback
    traceback.print_exc()
finally:
    logger.info("Flushing and closing producer")
    producer.flush()
