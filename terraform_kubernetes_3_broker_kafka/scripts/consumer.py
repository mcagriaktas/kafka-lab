from confluent_kafka import Consumer, KafkaError

def main():
    consumer_config = {
        'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',  
        'group.id': 'test_group',               
        'auto.offset.reset': 'earliest',       
    }

    consumer = Consumer(consumer_config)
    topic = 'cagri'

    consumer.subscribe([topic])

    print(f"Consuming messages from topic '{topic}'...")

    try:
        while True:
            msg = consumer.poll(timeout=5.0)

            if msg is None:
                print("No message received within timeout period.")
                continue
            if msg.error():
                if msg.error().code() == KafkaError._PARTITION_EOF:
                    print(f"Reached end of partition for topic {msg.topic()}, partition {msg.partition()}")
                else:
                    print(f"Consumer error: {msg.error()}")
                    break
            else:
                print(f"Received message: {msg.value().decode('utf-8')} "
                      f"from topic: {msg.topic()} partition: {msg.partition()} offset: {msg.offset()}")

    except KeyboardInterrupt:
        print("Consumer interrupted by user.")

    finally:
        consumer.close()

if __name__ == "__main__":
    main()
