import org.apache.kafka.clients.producer.{KafkaProducer, ProducerConfig, ProducerRecord}
import org.apache.kafka.common.serialization.StringSerializer
import java.util.Properties

object Producer extends App {
  System.setProperty("java.security.krb5.conf", "/etc/krb5.conf")
  System.setProperty("java.security.auth.login.config", "/mnt/home/scala/client_jaas.conf")

  val props = new Properties()
  props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker:9092")
  props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, classOf[StringSerializer].getName)
  props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, classOf[StringSerializer].getName)
  
  // SASL configs
  props.put("security.protocol", "SASL_SSL")
  props.put("sasl.mechanism", "GSSAPI")
  props.put("sasl.kerberos.service.name", "kafka")
  props.put("ssl.truststore.location", "/mnt/home/scala/client.truststore.jks")
  props.put("ssl.truststore.password", "cagri3541")
  props.put("ssl.truststore.type", "PKCS12")
  props.put("ssl.endpoint.identification.algorithm", "")

  val producer = new KafkaProducer[String, String](props)
  val TOPIC_NAME = "cagri-a"

  try {
    for (i <- 1 to 1000000) {
      val record = new ProducerRecord[String, String](TOPIC_NAME, s"cagri$i")
      producer.send(record, (metadata, exception) => {
        if (exception != null) {
          println(s"Failed to send message: ${exception.getMessage}")
        } else if (i % 10000 == 0) {
          println(s"Sent $i messages, offset: ${metadata.offset()}")
        }
      })
      if (i % 10000 == 0) producer.flush()
    }
  } catch {
    case e: Exception =>
      println(s"Error sending messages: ${e.getMessage}")
      e.printStackTrace()
  } finally {
    producer.close()
  }
}