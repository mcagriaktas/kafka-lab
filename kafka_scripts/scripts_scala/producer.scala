//> using jar "jars/slf4j-api-2.0.17.jar"
//> using jar "jars/slf4j-simple-2.0.9.jar"
//> using jar "jars/kafka-clients-4.0.0.jar"

import org.apache.kafka.clients.producer._
import org.slf4j.LoggerFactory
import java.util.Properties

@main def main(): Unit = {
    val logger = LoggerFactory.getLogger(getClass)

    val props = new Properties()
    props.put("bootstrap.servers", "localhost:19092, localhost:29092, localhost:39092")
    props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("client.id", "cagri-producer")
    props.put("acks", "all")

    val topic = "test-topic"

    val producer = new KafkaProducer[String, String](props)

    try
        for (i <- 1 to 1000000)
            val key = s"key-$i"
            val value = s"value-$i"

            val record = new ProducerRecord[String, String](topic, key, value)

            producer.send(record, new Callback {
                override def onCompletion(metadata: RecordMetadata, exception: Exception): Unit = {
                if (exception == null)
                    logger.info(s"Successfully sent message: " +
                      s"key=$key, " +
                      s"value=$value, " +
                      s"partition=${metadata.partition}, " +
                      s"offset=${metadata.offset}")
                else
                    logger.error(s"Failed to send message: $key", exception)
                }
            })

            Thread.sleep(10)

        logger.info("Finished sending messages")
    finally

        producer.close()
}