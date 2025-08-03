# consumer.py
from confluent_kafka import Consumer, TopicPartition
import json

consumer_conf = {
    # Connection
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'group.id': 'cagri-consumer',
    
    # Offset Management
    'auto.offset.reset': 'earliest',              # Where to start if no offset (earliest/latest)
}

consumer = Consumer(consumer_conf)
topic = "cagri"
partition = None
start_offset = None
end_offset = None
tp = TopicPartition(topic, partition, start_offset)
consumer.assign([tp])
consumer.seek(tp)

try:
    while True:
        msg = consumer.poll(1.0)
        
        if msg is None:
            continue
        if msg.error():
            continue
            
        current_offset = msg.offset()
        if current_offset > end_offset:
            break
            
        print(f"""
        Topic: {msg.topic()}
        Partition: {msg.partition()}
        Offset: {current_offset}
        Key: {msg.key().decode() if msg.key() else None}
        Value: {json.loads(msg.value().decode())}
        """)
        
        consumer.commit(msg)
except KeyboardInterrupt:
    pass
finally:
    consumer.close()
