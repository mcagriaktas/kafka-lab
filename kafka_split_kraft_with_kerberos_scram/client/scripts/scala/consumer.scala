//> using dep "org.slf4j:slf4j-api:2.0.17"
//> using dep "org.slf4j:slf4j-simple:2.0.9"
//> using dep "org.apache.kafka:kafka-clients:4.0.0"

import org.apache.kafka.clients.consumer._
import org.apache.kafka.common.errors.WakeupException
import org.slf4j.LoggerFactory
import java.util.Properties
import java.time.Duration
import java.util

@main def main(): Unit = {
  val logger = LoggerFactory.getLogger("KafkaConsumer")

  // Enable debug (optional)
  System.setProperty("sun.security.krb5.debug", "true")
  System.setProperty("java.security.debug", "gssloginconfig,configparser,logincontext")
  System.setProperty("java.security.krb5.conf", "/etc/krb5.conf")
  System.setProperty("java.security.auth.login.config", "/mnt/keytabs/client_jaas.conf")

  val props = new Properties()
  props.put("bootstrap.servers", "broker1.dahbest.kfn:9092,broker2.dahbest.kfn:9092,broker3.dahbest.kfn:9092")
  props.put("group.id", "scala-consumer-group")
  props.put("enable.auto.commit", "true")
  props.put("auto.commit.interval.ms", "1000")
  props.put("auto.offset.reset", "earliest")
  props.put("key.deserializer", "org.apache.kafka.common.serialization.StringDeserializer")
  props.put("value.deserializer", "org.apache.kafka.common.serialization.StringDeserializer")
  props.put("security.protocol", "SASL_SSL")
  props.put("sasl.mechanism", "GSSAPI")
  props.put("sasl.kerberos.service.name", "broker")
  props.put("ssl.truststore.location", "/mnt/jks/client.truststore.jks")
  props.put("ssl.truststore.password", "cagri3541")
  props.put("ssl.truststore.type", "PKCS12")
  props.put("ssl.endpoint.identification.algorithm", "Https")

  val topic = "cagri-topic"
  val consumer = new KafkaConsumer[String, String](props)

  try {
      consumer.subscribe(util.Arrays.asList(topic))
      logger.info(s"Subscribed to topic: $topic")
      
      while (true) {
          val records = consumer.poll(Duration.ofMillis(100))
          
          if (!records.isEmpty) {
              records.forEach { record =>
                  logger.info(
                    s"Received: key=${record.key()}, value=${record.value()}, " +
                    s"partition=${record.partition()}, offset=${record.offset()}"
                  )
              }
          }
      }
  } catch {
      case _: WakeupException =>
          logger.info("Consumer is shutting down")
      case e: Exception =>
          logger.error("Unexpected error in consumer", e)
  } finally {
      // Graceful shutdown
      consumer.wakeup()
      consumer.close(Duration.ofSeconds(30))
      logger.info("Consumer closed")
  }
}