//> using jar "jars/slf4j-api-2.0.17.jar"
//> using jar "jars/slf4j-simple-2.0.9.jar"
//> using jar "jars/kafka-clients-4.0.0.jar"

import org.apache.kafka.clients.consumer._
import org.apache.kafka.common.TopicPartition
import org.slf4j.LoggerFactory
import java.util.{Properties, Collections}
import java.time.Duration
import scala.jdk.CollectionConverters._

@main def main(): Unit = {
    val logger = LoggerFactory.getLogger(getClass)

    val props = new Properties()
    props.put("bootstrap.servers", "localhost:19092, localhost:29092, localhost:39092")
    props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer")
    props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer")
    props.put("group.id", "cagri-consumer")
    props.put("auto.offset.reset", "earliest")
    props.put("enable.auto.commit", "true")
    props.put("auto.commit.interval.ms", "1000")
    props.put("session.timeout.ms", "30000")
    props.put("heartbeat.interval.ms", "10000")

    val topic = "test-topic"

    val consumer = new KafkaConsumer[String, String](props)

    try {
        consumer.subscribe(Collections.singletonList(topic))
        logger.info(s"Subscribed to topic: $topic")

        while (true) {
            val records = consumer.poll(Duration.ofMillis(1000))
            
            if (!records.isEmpty) {
                logger.info(s"Polled ${records.count()} records")
                
                for (record <- records.asScala) {
                    messageCount += 1
                    
                    logger.info(
                        s"key=${record.key()}, " +
                        s"value=${record.value()}, " +
                        s"partition=${record.partition()}, " +
                        s"offset=${record.offset()}, " +
                        s"timestamp=${record.timestamp()}"
                    )
                    
                    if (messageCount % 1000 == 0) {
                        val rate = messageCount / elapsed
                        logger.info(s"Processed $messageCount messages in ${elapsed}s (${rate.formatted("%.2f")} msg/s)")
                    }
                }
            } else {
                if (messageCount % 10 == 0) {
                    logger.info("No new messages, waiting...")
                }
            }
        }
    } catch {
        case e: Exception =>
            logger.error("Error occurred while consuming messages", e)
    } finally {
        logger.info(s"Closing consumer. Total messages consumed: $messageCount")
        consumer.close()
    }
}