import org.apache.kafka.clients.producer.{KafkaProducer, ProducerRecord}
import java.util.Properties
import scala.util.Random
import org.json4s.native.JsonMethods._
import org.json4s.JsonDSL._

object KafkaNameAgeProducer {
  def main(args: Array[String]): Unit = {
    // Kafka configuration
    val props = new Properties()
    props.put("bootstrap.servers", "localhost:19092,localhost:29092,localhost:39092")
    props.put("key.serializer", "org.apache.kafka.common.serialization.StringSerializer")
    props.put("value.serializer", "org.apache.kafka.common.serialization.StringSerializer")

    // Create Kafka producer
    val producer = new KafkaProducer[String, String](props)
    
    // Sample data
    val names = List("cagri", "can", "ali", "veli", "ayse")
    val topic = "cagri-test"

    try {
      while(true) {
        // Generate random name and age
        val name = names(Random.nextInt(names.size))
        val age = Random.nextInt(63) + 18  // age between 18-80
        
        // Create JSON message
        val json = compact(render(
          ("name" -> name) ~
          ("age" -> age)
        ))

        // Create and send the record
        val record = new ProducerRecord[String, String](topic, json)
        producer.send(record)
        
        println(s"Sent: name=$name, age=$age")
        
        Thread.sleep(500)
      }
    } catch {
      case e: Exception => e.printStackTrace()
    } finally {
      producer.close()
    }
  }
}