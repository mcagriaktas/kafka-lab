import java.util.Properties
import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}

object ScalaKafkaProducer {

  def main(args: Array[String]): Unit = {

    val props = new Properties()
    props.put("bootstrap.servers", "kafka1:19192,kafka2:29192,kafka3:39192") 
    props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("acks", "all")
    props.put("retries", "0")
    props.put("linger.ms", "1")
    props.put("max.block.ms", "60000")  
    props.put("request.timeout.ms", "30000")  

    val producer = new KafkaProducer[String, String](props)

    try {
      for (i <- 1 to 1000000) {
        val key = s"key-$i"
        val value = s"message-$i"
        val record = new ProducerRecord[String, String]("cagri", key, value)

        producer.send(record, (metadata, exception) => {
          if (exception == null) {
            println(s"Sent message with key: $key to partition: ${metadata.partition()}, offset: ${metadata.offset()}")
          } else {
            println(s"Error sending message with key: $key")
            exception.printStackTrace()
          }
        })
      }
    } finally {
      producer.close()
    }
  }
}