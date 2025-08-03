# producer.py
from confluent_kafka import Producer
import json
from time import sleep

producer_conf = {
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'client.id': 'python-producer',
}

producer = Producer(producer_conf)
topic = "test"

def delivery_report(err, msg):
    if err:
        print(f'Message delivery failed: {err}')
    else:
        print(f'Message delivered to topic:{msg.topic()}, key:{msg.key().decode("utf-8")}, partition:[{msg.partition()}] at offset {msg.offset()}')
        
for i in range(100000000000):
    key = str(i)
    value = json.dumps({'id': i, 'message': f'Message {i}'})

    producer.produce(topic, key=key, value=value, callback=delivery_report)
    producer.poll(0)
    sleep(0.5)

producer.flush()
