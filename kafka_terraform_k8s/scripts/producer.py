from confluent_kafka import Producer
import json
import logging
import sys
import time

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

conf = {
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'client.id': 'python-producer'
}

def delivery_callback(err, msg):
    """Callback function to handle delivery reports."""
    if err:
        logger.error(f'Message delivery failed: {err}')
    else:
        logger.info(f'Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}')

def produce_messages(topic_name='cagri', num_messages=5):
    """Produce messages to the specified Kafka topic."""
    try:
        producer = Producer(conf)
        
        for i in range(num_messages):
            message = {
                "message_id": i,
                "content": f"Test message {i}"
            }
            
            producer.produce(
                topic=topic_name,
                key=str(i),
                value=json.dumps(message),
                callback=delivery_callback
            )
            producer.poll(0.1)
        
        logger.info(f'Produced {num_messages} messages to topic {topic_name}')
        producer.flush(timeout=5)
            
    except Exception as e:
        logger.error(f'An error occurred while producing messages: {e}')
        sys.exit(1)

if __name__ == '__main__':
    produce_messages()
