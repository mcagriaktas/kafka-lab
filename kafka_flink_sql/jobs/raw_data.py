from confluent_kafka import Producer
import json
import time
from datetime import datetime
import random

# Comprehensive configuration for the Kafka producer
conf = {
    # Essential Configs
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',     # Kafka broker address
    'client.id': 'python-producer',             # Client ID for the producer

    # Message Delivery
    'acks': 'all',                              # Ensure all replicas acknowledge
    'message.timeout.ms': 120000,               # Timeout for message delivery
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
    'transaction.timeout.ms': 60000             # Timeout for transactions
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

# Function to generate different types of messages, including invalid ones
def generate_message(force_invalid=False):
    global key_counter
    
    # Generate error types based on counter or forced invalid flag
    error_type = None
    if force_invalid or key_counter % 10 == 0:  # Every 10th message will be invalid
        error_type = random.choice([
            "invalid_user_id_format",
            "invalid_item_id_format",
            "non_numeric_user_id",
            "non_numeric_item_id",
            "null_value"
        ])

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

# Function to generate different types of messages, including invalid ones
def generate_message(force_invalid=False):
    global key_counter
    
    # Generate error types based on counter or forced invalid flag
    error_type = None
    if force_invalid or key_counter % 10 == 0:  # Every 10th message will be invalid
        error_type = random.choice([
            "invalid_user_id_format",
            "invalid_item_id_format",
            "non_numeric_user_id",
            "non_numeric_item_id",
            "null_value"
        ])
    
    # Create base message with process_in timestamp
    current_time = datetime.now()
    message = {
        "key": key_counter,
        "user_id": f"user{random.randint(1, 5)}",
        "item_id": f"item{random.randint(100, 999)}",
        "timestamp": current_time.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3],
        "process_in": current_time.strftime("%Y-%m-%d %H:%M:%S.%f")[:-3]
    }
    
    # Apply error modifications based on error type
    if error_type == "invalid_user_id_format":
        message["user_id"] = f"user-with-invalid-format-{random.randint(1, 100)}"
        print(f"Generating invalid user_id format: {message['user_id']}")
    
    elif error_type == "invalid_item_id_format":
        message["item_id"] = f"product/with/slashes/{random.randint(1, 100)}"
        print(f"Generating invalid item_id format: {message['item_id']}")
    
    elif error_type == "non_numeric_user_id":
        message["user_id"] = f"user-abc{random.choice('abcdefghijklmnopqrstuvwxyz')}"
        print(f"Generating non-numeric user_id: {message['user_id']}")
    
    elif error_type == "non_numeric_item_id":
        message["item_id"] = f"item-xyz{random.choice('abcdefghijklmnopqrstuvwxyz')}"
        print(f"Generating non-numeric item_id: {message['item_id']}")
    
    elif error_type == "null_value":
        if random.choice([True, False]):
            message["user_id"] = None
            print("Generating null user_id")
        else:
            message["item_id"] = None
            print("Generating null item_id")
    
    key_counter += 1
    return message, error_type is not None

# Main function to run the script
def main():
    try:
        message_count = 0
        error_count = 0
        
        print("Starting Kafka producer with DLQ test data generation...")
        print("Every 10th message will be intentionally invalid for DLQ testing")
        print("Press Ctrl+C to stop the producer")
        
        while True:
            message, is_error = generate_message()
            message_count += 1
            if is_error:
                error_count += 1
            
            message_str = json.dumps(message)
            
            producer.produce(
                topic='raw-data',
                key=str(message['key']),
                value=message_str,
                callback=delivery_report
            )
            
            producer.poll(0)
            
            if message_count % 10 == 0:
                print(f"-- Status: Sent {message_count} messages, {error_count} invalid ({error_count/message_count:.1%}) --")
            else:
                print(f"Sent: {message_str}")
                
            time.sleep(0.5)
            
    except KeyboardInterrupt:
        print("Stopping producer...")
    finally:
        print(f"Final stats: Sent {message_count} messages, {error_count} invalid ({error_count/message_count:.1%})")
        producer.flush()

# Entry point of the script
if __name__ == "__main__":
    main()