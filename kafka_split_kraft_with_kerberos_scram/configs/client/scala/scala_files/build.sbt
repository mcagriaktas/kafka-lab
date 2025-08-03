name := "scalakafka"

version := "0.1"

scalaVersion := "2.12.20"

libraryDependencies ++= Seq(
  "org.apache.kafka" % "kafka-clients" % "3.4.0"
)

mainClass in assembly := Some("Producer")

assemblyJarName in assembly := "producer.jar"