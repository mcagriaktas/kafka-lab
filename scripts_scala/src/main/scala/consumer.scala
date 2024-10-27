import java.util.Properties
import org.apache.kafka.clients.consumer.{KafkaConsumer, ConsumerConfig}
import org.apache.kafka.common.serialization.StringDeserializer
import java.time.Duration
import java.util.Collections

object ScalaKafkaConsumer {

  def main(args: Array[String]): Unit = {

    val props = new Properties()
    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "kafka1:19192,kafka2:29192,kafka3:39192")
    props.put(ConsumerConfig.GROUP_ID_CONFIG, "scala-consumer-group")
    props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, classOf[StringDeserializer].getName)
    props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, classOf[StringDeserializer].getName)
    props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest") 

    val consumer = new KafkaConsumer[String, String](props)

    consumer.subscribe(Collections.singletonList("cagri"))

    try {
      println("Consuming messages from the 'cagri' topic...")
      while (true) {
        val records = consumer.poll(Duration.ofMillis(1000))
        records.forEach { record =>
          println(s"Consumed record with key: ${record.key()}, value: ${record.value()}, from partition: ${record.partition()} at offset: ${record.offset()}")
        }
      }
    } catch {
      case e: Exception => e.printStackTrace()
    } finally {
      consumer.close()
    }
  }
}