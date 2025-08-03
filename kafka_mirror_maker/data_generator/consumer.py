from confluent_kafka import Consumer, KafkaException
from collections import defaultdict
import json
import time

TOPIC = "topic-a"
BOOTSTRAP_SERVERS = "localhost:19091,localhost:29091,localhost:39091"

conf = {
    'bootstrap.servers': BOOTSTRAP_SERVERS,
    'group.id': 'sequence-checker',
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False
}

consumer = Consumer(conf)
consumer.subscribe([TOPIC])

seen_keys = defaultdict(int)
seen_ids = defaultdict(int)
max_key = 0
max_id = 0
start_time = time.time()
run_duration = 5

try:
    while time.time() - start_time < run_duration:
        msg = consumer.poll(timeout=1.0)
        
        if msg is None:
            continue
        if msg.error():
            if msg.error().code() == KafkaException._PARTITION_EOF:
                continue
            else:
                print(f"Consumer error: {msg.error()}")
                break

        # Process key
        key_str = msg.key().decode('utf-8') if msg.key() else None
        if key_str:
            try:
                key_num = int(key_str)
                seen_keys[key_num] += 1
                max_key = max(max_key, key_num)
                print(f"Key: {key_num:4d} | ", end="")
            except ValueError:
                print(f"❗ Invalid key format: {key_str}")
                key_num = None
        else:
            key_num = None
            print("No key | ", end="")

        try:
            value = json.loads(msg.value().decode('utf-8'))
            msg_id = value.get('id')
            timestamp = value.get('ts')
            
            if msg_id is not None:
                seen_ids[msg_id] += 1
                max_id = max(max_id, msg_id)
                print(f"ID: {msg_id:4d} | Timestamp: {timestamp}")
            else:
                print("No ID in message value")
                
        except (json.JSONDecodeError, AttributeError) as e:
            print(f"❗ Error parsing message value: {e}")

finally:
    consumer.close()
    print("\n=== 🔍 Analysis Results ===")
    
    # Key analysis
    if seen_keys:
        sorted_keys = sorted(seen_keys.keys())
        print(f"\n🔑 Key Analysis (from message keys)")
        print(f"Total keyed messages: {sum(seen_keys.values())}")
        print(f"Unique keys: {len(seen_keys)}")
        print(f"Max key: {max_key}")
        
        missing_keys = [k for k in range(min(seen_keys), max_key + 1) 
                      if k not in seen_keys]
        duplicate_keys = {k: v for k, v in seen_keys.items() if v > 1}
        
        if missing_keys:
            print(f"\n❌ Missing keys ({len(missing_keys)}): {missing_keys}")
        else:
            print("\n✅ No missing keys in sequence")
            
        if duplicate_keys:
            print("\n⚠️ Duplicate keys:")
            for k, count in duplicate_keys.items():
                print(f"  Key {k} appeared {count} times")
        else:
            print("\n✅ No duplicate keys")
    else:
        print("\n⚠️ No keys found in messages")
    
    # ID analysis
    if seen_ids:
        sorted_ids = sorted(seen_ids.keys())
        print(f"\n🆔 ID Analysis (from message values)")
        print(f"Total messages with IDs: {sum(seen_ids.values())}")
        print(f"Unique IDs: {len(seen_ids)}")
        print(f"Max ID: {max_id}")
        
        missing_ids = [i for i in range(min(seen_ids), max_id + 1) 
                      if i not in seen_ids]
        duplicate_ids = {i: v for i, v in seen_ids.items() if v > 1}
        
        if missing_ids:
            print(f"\n❌ Missing IDs ({len(missing_ids)}): {missing_ids}")
        else:
            print("\n✅ No missing IDs in sequence")
            
        if duplicate_ids:
            print("\n⚠️ Duplicate IDs:")
            for i, count in duplicate_ids.items():
                print(f"  ID {i} appeared {count} times")
        else:
            print("\n✅ No duplicate IDs")
    else:
        print("\n⚠️ No IDs found in message values")