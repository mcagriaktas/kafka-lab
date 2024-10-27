val scala3Version = "2.12.18"

lazy val root = project
  .in(file("."))
  .settings(
    name := "kafka_scala",
    version := "0.1.0-SNAPSHOT",

    scalaVersion := scala3Version,

    libraryDependencies += "org.scalameta" %% "munit" % "1.0.0" % Test,
    libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.2.11",
    libraryDependencies += "org.apache.logging.log4j" % "log4j-slf4j-impl" % "2.17.1",
    libraryDependencies += "org.apache.kafka" % "kafka-clients" % "3.8.0"

  )
