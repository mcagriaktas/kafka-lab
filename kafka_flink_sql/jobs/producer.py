from confluent_kafka import Producer, KafkaError, KafkaException
import json
import time
from datetime import datetime
import random

# Comprehensive configuration for the Kafka producer
conf = {
    # Essential Configs
    'bootstrap.servers': 'localhost:19092',     # Kafka broker address
    'client.id': 'python-producer',             # Client ID for the producer

    # Message Delivery
    'acks': 'all',                              # Ensure all replicas acknowledge
    'message.timeout.ms': 30000,                # Timeout for message delivery
    'request.timeout.ms': 30000,                # Timeout for requests to the broker
    'max.in.flight.requests.per.connection': 5, # Maximum in-flight requests
    'enable.idempotence': True,                 # Ensure exactly-once delivery
    'retries': 2147483647,                      # Number of retries on failure
    'retry.backoff.ms': 100,                    # Delay between retries

    # Batching & Compression
    'compression.type': 'none',                 # Compression type (none, gzip, snappy, lz4, zstd)
    'linger.ms': 0,                             # Delay in milliseconds to wait for batching
    'batch.num.messages': 10000,                # Maximum number of messages per batch
    'batch.size': 16384,                        # Maximum batch size in bytes

    # Memory & Buffers
    'message.max.bytes': 1000000,               # Maximum message size
    'queue.buffering.max.messages': 100000,     # Maximum number of messages in the queue
    'queue.buffering.max.kbytes': 1048576,      # Maximum size of the queue in KB
    'queue.buffering.max.ms': 0,                # Maximum time to buffer messages

    # Network & Timeouts
    'socket.timeout.ms': 60000,                 # Socket timeout
    'socket.keepalive.enable': True,            # Enable TCP keep-alive
    'socket.send.buffer.bytes': 0,              # Socket send buffer size (0 = OS default)
    'socket.receive.buffer.bytes': 0,           # Socket receive buffer size (0 = OS default)
    'socket.max.fails': 3,                      # Maximum socket connection failures

    # Security - Basic
    'security.protocol': 'PLAINTEXT',           # Security protocol (PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL)
    'ssl.ca.location': None,                    # Path to CA certificate
    'ssl.certificate.location': None,           # Path to client certificate
    'ssl.key.location': None,                   # Path to client private key
    'ssl.key.password': None,                   # Password for the private key

    # SASL Authentication
    'sasl.mechanism': 'PLAIN',                  # SASL mechanism (PLAIN, GSSAPI, SCRAM-SHA-256, SCRAM-SHA-512)
    'sasl.username': None,                      # SASL username
    'sasl.password': None,                      # SASL password

    # Monitoring & Metrics
    'statistics.interval.ms': 0,                # Interval for statistics reporting
    'api.version.request': True,                # Request broker API version
    'broker.address.family': 'v4',              # Broker address family (v4, v6, any)

    # Logging
    'log.connection.close': True,               # Log connection close events
    'log_level': 6,                             # Log level (0 = no logging, 7 = debug)

    # Transactional Producer
    'transactional.id': None,                   # Transactional ID for exactly-once semantics
    'transaction.timeout.ms': 60000            # Timeout for transactions
}

# Create a Kafka producer instance
producer = Producer(conf)

# Counter for message keys
key_counter = 1

# Callback function to handle delivery reports
def delivery_report(err, msg):
    if err is not None:
        print(f'Message delivery failed: {err}')
    else:
        print(f'Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}')

# Function to generate a random message
def generate_message():
    global key_counter
    message = {
        "key": key_counter,
        "user_id": f"cagri{random.randint(1, 5)}",
        "item_id": f"item{random.randint(100, 999)}",
        "timestamp": datetime.now().strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    }
    key_counter += 1
    return message

# Main function to produce messages
def main():
    try:
        while True:
            # Generate a message
            message = generate_message()
            
            # Convert the message to a JSON string
            message_str = json.dumps(message)
            
            # Produce the message to the Kafka topic
            producer.produce(
                topic='cagri',  # Kafka topic name
                key=str(message['key']),  # Message key
                value=message_str,  # Message value
                callback=delivery_report  # Callback for delivery reports
            )
            
            # Poll for events (trigger delivery reports)
            producer.poll(0)
            
            # Print the sent message
            print(f"Sent: {message_str}")
            
            # Wait for a short time before sending the next message
            time.sleep(0.2)
            
    except KeyboardInterrupt:
        print("Stopping producer...")
    finally:
        # Flush any remaining messages
        producer.flush()

# Entry point of the script
if __name__ == "__main__":
    main()