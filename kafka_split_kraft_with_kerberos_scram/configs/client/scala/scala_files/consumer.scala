import org.apache.kafka.clients.consumer.{ConsumerConfig, KafkaConsumer}
import org.apache.kafka.common.serialization.StringDeserializer
import java.time.Duration
import java.util.{Collections, Properties}
import scala.collection.JavaConverters._

object Consumer extends App {
  // Set Kerberos configuration
  System.setProperty("java.security.krb5.conf", "/etc/krb5.conf")
  System.setProperty("java.security.auth.login.config", "/mnt/home/scala/client_jaas.conf")

  // Consumer properties
  val props = new Properties()
  props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker:9092")
  props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, classOf[StringDeserializer].getName)
  props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, classOf[StringDeserializer].getName)
  props.put(ConsumerConfig.GROUP_ID_CONFIG, "client-consumer")
  props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest")
  props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true")
  
  // SASL configs for Kerberos
  props.put("security.protocol", "SASL_SSL")
  props.put("sasl.mechanism", "GSSAPI")
  props.put("sasl.kerberos.service.name", "kafka")
  props.put("ssl.truststore.location", "/mnt/home/scala/client.truststore.jks")
  props.put("ssl.truststore.password", "cagri3541")
  props.put("ssl.truststore.type", "PKCS12")
  props.put("ssl.endpoint.identification.algorithm", "")

  val TOPIC_NAME = "cagri-a"
  val consumer = new KafkaConsumer[String, String](props)
  
  try {
    // Subscribe to the topic
    consumer.subscribe(Collections.singletonList(TOPIC_NAME))
    println(s"Started consumer, subscribed to $TOPIC_NAME")
    
    // Poll for messages
    var messageCount = 0
    val startTime = System.currentTimeMillis()
    
    while (true) {
      val records = consumer.poll(Duration.ofMillis(100))
      
      for (record <- records.asScala) {
        messageCount += 1
        if (messageCount % 10000 == 0) {
          val elapsedSeconds = (System.currentTimeMillis() - startTime) / 1000.0
          val recordsPerSecond = messageCount / elapsedSeconds
          
          println(s"Consumed $messageCount messages (${recordsPerSecond.toInt} msg/sec)")
          println(s"Last record: Topic=${record.topic()}, Partition=${record.partition()}, Offset=${record.offset()}, Key=${record.key()}, Value=${record.value()}")
        }
      }
    }
  } catch {
    case e: Exception =>
      println(s"Error consuming messages: ${e.getMessage}")
      e.printStackTrace()
  } finally {
    consumer.close()
  }
}