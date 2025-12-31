//> using dep "org.slf4j:slf4j-api:2.0.17"
//> using dep "org.slf4j:slf4j-simple:2.0.9"
//> using dep "org.apache.kafka:kafka-clients:4.0.0"

import org.apache.kafka.clients.producer._
import org.slf4j.LoggerFactory
import java.util.Properties
import java.time.Duration
import scala.util.Random

@main def main(): Unit = {
  val logger = LoggerFactory.getLogger("KafkaProducer")

  // Enable debug (optional)
  System.setProperty("sun.security.krb5.debug", "true")
  System.setProperty("java.security.debug", "gssloginconfig,configparser,logincontext")
  System.setProperty("java.security.krb5.conf", "/etc/krb5.conf")
  System.setProperty("java.security.auth.login.config", "/mnt/scripts/scala/client_jaas.conf")

  val props = new Properties()
  props.put("bootstrap.servers", "broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092")
  props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
  props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")
  props.put("security.protocol", "SASL_SSL")
  props.put("sasl.mechanism", "GSSAPI")
  props.put("sasl.kerberos.service.name", "kafka")

  props.put("ssl.truststore.location", "/mnt/jks/client.truststore.jks")
  props.put("ssl.truststore.password", "cagri3541")
  props.put("ssl.truststore.type", "JKS")

  props.put("sasl.kerberos.min.time.before.relogin", "60000")
  props.put("enable.idempotence", "false")
  props.put("ssl.endpoint.identification.algorithm", "HTTPS")

  val topic = "cagri-topic"
  val list = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
  val producer = new KafkaProducer[String, String](props)

  try {
    for (i <- 1 to 10000000) {
      val value = s"value-$i"
      val key = Random.shuffle(list).head.toString
      val record = new ProducerRecord[String, String](topic, key, value)

      producer.send(record, new Callback {
        override def onCompletion(metadata: RecordMetadata, exception: Exception): Unit = {
          if (exception == null) {
            logger.info(s"Sent: $value to partition ${metadata.partition()} offset ${metadata.offset()}")
          } else {
            logger.error(s"Failed to send $value", exception)
          }
        }
      })
      Thread.sleep(5000)
    }
    producer.flush()
  } finally {
    producer.close(Duration.ofSeconds(10))
    logger.info("Producer closed")
  }
}