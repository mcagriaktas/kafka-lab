from confluent_kafka import Producer, KafkaError
from confluent_kafka.admin import AdminClient, NewTopic
import json
import time

bootstrap_servers = 'localhost:19092,localhost:29092,localhost:39092'
producer_config = {
    'bootstrap.servers': bootstrap_servers,
    'api.version.request': True
}
topic = 'cagri'

admin_client = AdminClient({'bootstrap.servers': bootstrap_servers})

def create_topic_if_not_exists(topic_name):
    topic_metadata = admin_client.list_topics(timeout=5)
    if topic_name not in topic_metadata.topics:
        new_topic = NewTopic(topic_name, num_partitions=3, replication_factor=1)
        admin_client.create_topics([new_topic])
        print(f"Topic '{topic_name}' created.")
    else:
        print(f"Topic '{topic_name}' already exists.")

create_topic_if_not_exists(topic)

producer = Producer(producer_config)

def delivery_report(err, msg):
    if err is not None:
        print(f"Failed to deliver message: {err}")
    else:
        print(f"Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")

for i in range(1000000):
    message = {'number': i, 'timestamp': time.time()}
    try:
        producer.produce(
            topic=topic,
            value=json.dumps(message),
            callback=delivery_report
        )
        producer.poll(0) 
    except Exception as e:
        print(f"An error occurred: {e}")
    time.sleep(1)

producer.flush()