-- Fixed checkpointing config
SET 'execution.checkpointing.mode' = 'EXACTLY_ONCE';
SET 'execution.checkpointing.interval' = '30s';
SET 'execution.checkpointing.min-pause' = '30s';
SET 'execution.checkpointing.unaligned' = 'true';
SET 'execution.checkpointing.max-concurrent-checkpoints' = '1';
SET 'execution.checkpointing.timeout' = '30s';

-- Step 1: Source table with process_in timestamp
CREATE TABLE raw_data (
    `key` INT,
    user_id STRING,
    item_id STRING,
    `timestamp` TIMESTAMP(3),
    process_in TIMESTAMP(3),
    WATERMARK FOR `timestamp` AS `timestamp` - INTERVAL '5' SECOND
) WITH (
    'connector' = 'kafka',
    'topic' = 'raw-data',
    'properties.bootstrap.servers' = 'kafka1:9092,kafka2:9092,kafka3:9092',
    'properties.group.id' = 'flink-job1-raw-data-reader',
    'scan.startup.mode' = 'group-offsets',

    -- Consumer tuning
    'properties.enable.auto.commit' = 'false',
    'properties.auto.offset.reset' = 'earliest',
    'properties.fetch.min.bytes' = '1',
    'properties.fetch.max.wait.ms' = '100',
    'properties.max.poll.records' = '5000',
    'properties.receive.buffer.bytes' = '8388608',
    'properties.max.partition.fetch.bytes' = '1048576',
    'properties.session.timeout.ms' = '30000',
    'properties.request.timeout.ms' = '40000',

    -- Format
    'format' = 'json',
    'json.fail-on-missing-field' = 'false',
    'json.ignore-parse-errors' = 'true'
);

-- Step 2: Clean output table
CREATE TABLE clean_data (
    `key` INT,
    user_id INT,
    item_id INT,
    process_out TIMESTAMP(3),
    `timestamp` TIMESTAMP(3)
) WITH (
    'connector' = 'kafka',
    'topic' = 'clean-data',
    'properties.bootstrap.servers' = 'kafka1:9092,kafka2:9092,kafka3:9092',
    'properties.client.id' = 'flink-job1-clean-data-writer',

    -- Format
    'format' = 'json',
    'json.fail-on-missing-field' = 'false',
    'json.ignore-parse-errors' = 'true'
);

-- Step 3: DLQ output table
CREATE TABLE raw_data_dlq (
    `key` INT,
    original_user_id STRING,
    original_item_id STRING,
    original_timestamp TIMESTAMP(3),
    error_message STRING
) WITH (
    'connector' = 'kafka',
    'topic' = 'raw-data-dlq',
    'properties.bootstrap.servers' = 'kafka1:9092,kafka2:9092,kafka3:9092',
    'sink.parallelism' = '4',

    -- Producer tuning
    'properties.batch.size' = '32768',
    'properties.linger.ms' = '10',
    'properties.compression.type' = 'lz4',
    'properties.buffer.memory' = '67108864',

    -- Format
    'format' = 'json',
    'json.fail-on-missing-field' = 'false',
    'json.ignore-parse-errors' = 'true'
);

-- Step 4: Transformation and validation logic
CREATE TEMPORARY VIEW processed_data AS
SELECT
    `key`,
    user_id AS original_user_id,
    item_id AS original_item_id,
    `timestamp` AS original_timestamp,
    process_in,
    REGEXP_EXTRACT(user_id, '([0-9]+)', 1) AS extracted_user_id,
    REGEXP_EXTRACT(item_id, '([0-9]+)', 1) AS extracted_item_id,
    CASE
        WHEN REGEXP_EXTRACT(user_id, '([0-9]+)', 1) IS NULL THEN 'User ID format invalid'
        WHEN REGEXP_EXTRACT(item_id, '([0-9]+)', 1) IS NULL THEN 'Item ID format invalid'
        ELSE NULL
    END AS error_message
FROM raw_data;

-- Step 5: Write valid data
INSERT INTO clean_data /*+ OPTIONS('sink.parallelism'='12') */
SELECT
    `key`,
    CAST(extracted_user_id AS INT) AS user_id,   -- Cast to INT
    CAST(extracted_item_id AS INT) AS item_id,   -- Cast to INT
    CURRENT_TIMESTAMP AS process_out,            -- Added output timestamp
    original_timestamp AS `timestamp`            -- Original event time
FROM processed_data
WHERE error_message IS NULL
  AND extracted_user_id IS NOT NULL
  AND extracted_item_id IS NOT NULL;

-- Step 6: Write invalid records
INSERT INTO raw_data_dlq
SELECT
    `key`,
    original_user_id,
    original_item_id,
    original_timestamp,
    COALESCE(
        error_message,
        CASE
            WHEN extracted_user_id IS NULL THEN 'User ID extraction failed'
            WHEN extracted_item_id IS NULL THEN 'Item ID extraction failed'
            ELSE 'Unknown transformation error'
        END
    ) AS error_message
FROM processed_data
WHERE error_message IS NOT NULL 
   OR extracted_user_id IS NULL 
   OR extracted_item_id IS NULL;