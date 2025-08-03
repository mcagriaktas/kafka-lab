# producer.py
from confluent_kafka import Producer
import json
from time import sleep

producer_conf = {
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

producer = Producer(producer_conf)
topic = "test-topic"

def delivery_report(err, msg):
    if err:
        print(f'Message delivery failed: {err}')
    else:
        print(f'Message delivered to topic:{msg.topic()}, key:{msg.key().decode("utf-8")}, msg: {msg}, partition:[{msg.partition()}] at offset {msg.offset()}')

for i in range(10000000):
    key = str(i)
    value = json.dumps({'id': i, 'message': f'Message {i}'})
    
    producer.produce(topic, key=key, value=value, callback=delivery_report)
    producer.poll(0)
    sleep(0.5)

producer.flush()