from confluent_kafka import Producer
import json
from time import sleep

producer_conf = {
    # Connection
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'client.id': 'cagri-producer',

    # Performance
    'batch.size': 16384,
    'linger.ms': 0,

    # Reliability
    'acks': 'all',
    'retries': 10,
    'transaction.timeout.ms': 60000,
    'request.timeout.ms': 10000,
    'max.in.flight.requests.per.connection': 1,
    'delivery.timeout.ms': 5000,

    # Partitioning
    'partitioner': 'consistent_random',
    'message.max.bytes': 1000000,
}

producer = Producer(producer_conf)
topic = "couchbase-topic"

def delivery_report(err, msg):
    if err is not None:
        print(f'Message delivery failed: {err}')
    else:
        key = msg.key().decode("utf-8") if msg.key() else None
        print(f'Message delivered to topic:{msg.topic()}, key:{key}, partition:[{msg.partition()}] at offset {msg.offset()}')

try:
    for i in range(10000000):
        key = str(i)
        value = json.dumps({
            "id": f"public_{i}",
            "name": f"Public User {i}",
            "age": i
        })
        producer.produce(topic, key=key, value=value, callback=delivery_report)
        producer.poll(0)
        sleep(1)
except KeyboardInterrupt:
    print("Producer interrupted by user.")
finally:
    producer.flush()
