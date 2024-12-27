from confluent_kafka import Consumer, KafkaError
import json

conf = {
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'group.id': 'my_group',
    'auto.offset.reset': 'earliest',  
    'enable.auto.commit': True
}

consumer = Consumer(conf)

consumer.subscribe(['cagri'])

try:
    print("Consuming messages from the 'cagri' topic...")
    while True:
        msg = consumer.poll(1.0) 
        
        if msg is None:
            continue 
        
        if msg.error():
            if msg.error().code() == KafkaError._PARTITION_EOF:
                continue
            else:
                print(f"Error: {msg.error()}")
                break

        try:
            value = json.loads(msg.value().decode('utf-8'))
            print(f"Consumed record with key: {msg.key()}, value: {value}, from partition: {msg.partition()} at offset: {msg.offset()}")
        except json.JSONDecodeError as e:
            print(f"Failed to decode message: {msg.value()}. Error: {str(e)}")
        
except KeyboardInterrupt:
    print("Consumer interrupted by user.")
    
finally:
    print("Closing consumer...")
    consumer.close()
