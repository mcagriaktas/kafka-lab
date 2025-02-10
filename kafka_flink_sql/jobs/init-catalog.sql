CREATE CATALOG persistent_catalog WITH (
    'type' = 'generic_in_memory'
);

USE CATALOG persistent_catalog;

CREATE DATABASE IF NOT EXISTS my_database;
USE my_database;

CREATE TABLE IF NOT EXISTS kafka_source (
    `key` BIGINT,
    user_id STRING,
    item_id STRING,
    `timestamp` TIMESTAMP(3),
    WATERMARK FOR `timestamp` AS `timestamp` - INTERVAL '5' SECONDS
) WITH (
    'connector' = 'kafka',
    'topic' = 'cagri',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id' = 'flink-sql-group',
    'scan.startup.mode' = 'earliest-offset',
    'format' = 'json',
    'json.fail-on-missing-field' = 'false',
    'json.ignore-parse-errors' = 'true'
);