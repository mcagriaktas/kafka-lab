from confluent_kafka import Consumer
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s %(message)s')
logger = logging.getLogger(__name__)

config = {
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'security.protocol': 'SASL_SSL',
    'sasl.mechanism': 'SCRAM-SHA-256',
    'sasl.username': 'client-consumer',
    'sasl.password': 'cagri3541',
    'ssl.ca.location': 'data_generator/client.pem',
    'ssl.endpoint.identification.algorithm': 'none',
    'group.id': 'client-consumer',
    'auto.offset.reset': 'earliest',
    'enable.partition.eof': False
}

topic = 'test'

try:
    consumer = Consumer(config)
    consumer.subscribe([topic])

    while True:
        msg = consumer.poll(1.0)

        if msg is None:
            continue

        key = msg.key().decode('utf-8') if msg.key() else None
        value = msg.value().decode('utf-8') if msg.value() else None

        logger.info(f"key={key}, value={value}, topic={msg.topic()}, partition={msg.partition()}, offset={msg.offset()}")

except Exception as e:
    logger.error(f"Unexpected error: {e}")