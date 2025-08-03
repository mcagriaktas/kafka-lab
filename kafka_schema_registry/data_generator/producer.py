from confluent_kafka import SerializingProducer
from confluent_kafka.schema_registry import SchemaRegistryClient
from confluent_kafka.schema_registry.avro import AvroSerializer
from time import sleep

schema_registry_conf = {'url': 'http://localhost:18081'}
schema_registry_client = SchemaRegistryClient(schema_registry_conf)

user_schema_str = """
{
    "namespace": "data",
    "name": "Data",
    "type": "record",
    "fields": [
        {"name": "name", "type": "string"},
        {"name": "age", "type": "int"},
        {"name": "city", "type": "string"}
    ]
}
"""

def dict_to_user(obj, ctx):
    return obj

avro_serializer = AvroSerializer(
    schema_str=user_schema_str,
    schema_registry_client=schema_registry_client,
    to_dict=dict_to_user,
)

producer_conf = {
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'client.id': 'cagri-producer',
    'acks': 'all',
    'retries': 10,
    'transaction.timeout.ms': 60000,
    'request.timeout.ms': 10000,
    'max.in.flight.requests.per.connection': 1,
    'delivery.timeout.ms': 5000,
    'partitioner': 'consistent_random',
    'message.max.bytes': 1000000,

    'key.serializer': lambda v, ctx: v.encode('utf-8') if v is not None else None,
    'value.serializer': avro_serializer,
}

producer = SerializingProducer(producer_conf)
topic = "test-topic"

def delivery_report(err, msg):
    if err is not None:
        print(f'Message delivery failed: {err}')
    else:
        key = msg.key()
        print(f'Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()} with key {key}')

try:
    for i in range(10000000):
        key = str(i)
        value = {
            "name": f"name_{i}",
            "age": i,
            "city": f"City_{i}"
        }
        producer.produce(
            topic=topic,
            key=key,
            value=value,
            on_delivery=delivery_report
        )
        producer.poll(0)
        sleep(1)
except KeyboardInterrupt:
    print("Producer interrupted by user.")
finally:
    producer.flush()
