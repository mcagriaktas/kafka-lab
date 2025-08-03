from confluent_kafka import Producer, KafkaException
import json
import time
import random
import threading
from datetime import datetime

class LaggingKafkaProducer:
    def __init__(self, config):
        self.producer = Producer(config)
        self.running = False
        self.threads = []
        
    def delivery_report(self, err, msg):
        """Delivery callback for message reports"""
        if err is not None:
            print(f'Message delivery failed: {err}')
        else:
            key = msg.key().decode("utf-8") if msg.key() else None
            timestamp = datetime.fromtimestamp(msg.timestamp()[1]/1000).strftime('%H:%M:%S.%f')[:-3]
            print(f'[{timestamp}] Delivered to {msg.topic()}, key:{key}, partition:[{msg.partition()}] offset:{msg.offset()}')

    def produce_messages(self, topic, burst_size, min_delay, max_delay, total_messages=None):
        """Produce messages with configurable lag"""
        message_count = 0
        try:
            while self.running and (total_messages is None or message_count < total_messages):
                start_time = time.time()
                for i in range(burst_size):
                    key = str(message_count)
                    value = json.dumps({
                        "id": f"user_{message_count}",
                        "name": f"User {message_count}",
                        "age": random.randint(18, 65),
                        "timestamp": datetime.now().isoformat()
                    })
                    
                    self.producer.produce(
                        topic,
                        key=key,
                        value=value,
                        callback=self.delivery_report
                    )
                    message_count += 1
                    if total_messages is not None and message_count >= total_messages:
                        break
                
                self.producer.poll(0)
                
                burst_duration = time.time() - start_time
                delay = max(0, random.uniform(min_delay, max_delay) - burst_duration)
                
                if delay > 0:
                    print(f"Sent {burst_size} messages (total: {message_count}). Sleeping for {delay:.2f}s...")
                    time.sleep(delay)
                
        except Exception as e:
            print(f"Exception in producer thread: {e}")
        finally:
            print("Producer thread exiting")

    def start(self, topic, burst_size=10, min_delay=1, max_delay=5, threads=1, total_messages=None):
        """Start producer threads"""
        self.running = True
        for i in range(threads):
            thread = threading.Thread(
                target=self.produce_messages,
                args=(topic, burst_size, min_delay, max_delay, total_messages),
                name=f"Producer-{i}"
            )
            thread.daemon = True
            thread.start()
            self.threads.append(thread)
            print(f"Started producer thread {i}")

    def stop(self):
        """Stop all producer threads"""
        self.running = False
        for thread in self.threads:
            thread.join(timeout=2)
        self.producer.flush()
        print("All producer threads stopped")

if __name__ == "__main__":
    config = {
        'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
        'client.id': 'laggy-producer',

        'batch.size': 16384,
        'linger.ms': 0,

        'acks': 'all',
        'retries': 10,
        'transaction.timeout.ms': 60000,
        'request.timeout.ms': 10000,
        'max.in.flight.requests.per.connection': 1,
        'delivery.timeout.ms': 5000,

        'partitioner': 'consistent_random',
        'message.max.bytes': 1000000,
    }

    producer = LaggingKafkaProducer(config)
    
    try:
        producer.start(
            topic="lag-test-topic",
            burst_size=20,
            min_delay=0.5,
            max_delay=3,
            threads=3,
            total_messages=1000
        )
        
        while True:
            time.sleep(0)
            
    except KeyboardInterrupt:
        print("Received keyboard interrupt, shutting down...")
    finally:
        producer.stop()