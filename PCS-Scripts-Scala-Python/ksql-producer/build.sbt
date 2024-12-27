val scala2Version = "2.12.20"

lazy val root = project
  .in(file("."))
  .settings(
    name := "main",
    version := "0.1.0-SNAPSHOT",
    scalaVersion := scala2Version,

    libraryDependencies ++= Seq(
      "org.apache.kafka" % "kafka-clients" % "3.5.1",
      "org.json4s" %% "json4s-native" % "4.0.6",
      "org.scalameta" %% "munit" % "0.7.29" % Test
    ),
    
    testFrameworks += new TestFramework("munit.Framework"),

    // Add a main class
    assembly / mainClass := Some("KafkaNameAgeProducer"),
    
    // Merge strategy for duplicate files
    assembly / assemblyMergeStrategy := {
      case PathList("META-INF", xs @ _*) => MergeStrategy.discard
      case "reference.conf" => MergeStrategy.concat
      case x => MergeStrategy.first
    }
  )