from confluent_kafka import Consumer, KafkaException, KafkaError
import json

bootstrap_servers = 'localhost:19092'
consumer_config = {
    'bootstrap.servers': bootstrap_servers,
    'group.id': 'my_consumer_group',
    'auto.offset.reset': 'earliest' 
}

consumer = Consumer(consumer_config)
topic = 'cagri'
consumer.subscribe([topic])

def consume_messages():
    print(f"Consuming messages from topic '{topic}'...")
    try:
        while True:
            msg = consumer.poll(timeout=1.0)
            if msg is None:
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    print(f"End of partition reached {msg.topic()} [{msg.partition()}] at offset {msg.offset()}")
                elif msg.error():
                    raise KafkaException(msg.error())
            else:
                message_value = json.loads(msg.value().decode('utf-8'))
                print(f"Received message: {message_value}")
    except KeyboardInterrupt:
        print("Consumer interrupted. Exiting...")
    finally:
        consumer.close()
        print("Consumer closed.")

consume_messages()