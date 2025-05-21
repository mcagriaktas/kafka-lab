from confluent_kafka import Consumer
import json
import datetime

conf = {
    'bootstrap.servers': 'localhost:19092,localhost:29092,localhost:39092',
    'group.id': 'cdc-change-tracker',
    'auto.offset.reset': 'earliest'
}

consumer = Consumer(conf)
consumer.subscribe(['dbserver1.public.high_customers'])

def format_timestamp(ts_ms):
    return datetime.datetime.fromtimestamp(ts_ms/1000).strftime('%Y-%m-%d %H:%M:%S')

try:
    while True:
        msg = consumer.poll(1.0)
        if msg is None:
            continue
        if msg.error():
            print(f"Consumer error: {msg.error()}")
            continue
            
        if msg.value() is None:
            print(f"[{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] TOMBSTONE: Key={msg.key().decode('utf-8') if msg.key() else 'None'}")
            continue
            
        try:
            data = json.loads(msg.value().decode('utf-8'))
            
            op = data.get('__op') or data.get('op')
            if not op and '__deleted' in data:
                op = 'c' if data['__deleted'] == 'false' else 'd'
                
            ts = data.get('__source_ts_ms') or data.get('source', {}).get('ts_ms')
            timestamp = format_timestamp(int(ts)) if ts else 'unknown'
            
            if op == 'r':
                print(f"[{timestamp}] SNAPSHOT: ID={data.get('id')} {data.get('name')} ({data.get('email')})")
            elif op == 'c':
                print(f"[{timestamp}] INSERT: ID={data.get('id')} {data.get('name')} ({data.get('email')})")
            elif op == 'u':
                print(f"[{timestamp}] UPDATE: ID={data.get('id')} {data.get('name')} ({data.get('email')})")
                if 'before' in data and 'after' in data:
                    before = data['before']
                    after = data['after']
                    for key in after:
                        if key in before and before[key] != after[key]:
                            print(f"  → Changed {key}: {before[key]} → {after[key]}")
            elif op == 'd':
                print(f"[{timestamp}] DELETE: ID={data.get('id')} {data.get('name')} was removed")
            else:
                print(f"Unknown event: {json.dumps(data, indent=2)}")
        except json.JSONDecodeError:
            print(f"Failed to parse message: {msg.value().decode('utf-8')}")
            
except KeyboardInterrupt:
    consumer.close()