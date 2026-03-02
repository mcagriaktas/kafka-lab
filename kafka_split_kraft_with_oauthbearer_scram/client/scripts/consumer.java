//> using jvm "17"
//> using dep "org.apache.kafka:kafka-clients:4.0.0"
//> using dep "org.slf4j:slf4j-simple:2.0.9"

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

// DÜZELTME 1: Class ismi dosya ismiyle (Consumer.java) aynı yapıldı.
public class consumer {

    private static final String TOPIC_NAME = "test-data";

    // 1. The Worker Thread Class
    public static class ClusterConsumerThread implements Runnable {

        private final String name;
        private final String topic;
        private final Properties props;
        private volatile boolean running = true;

        public ClusterConsumerThread(String name, String bootstrapUrl, String topic) {
            this.name = name;
            this.topic = topic;

            this.props = new Properties();
            props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapUrl);
            
            // Security Configs
            props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
            props.put(SaslConfigs.SASL_MECHANISM, "SCRAM-SHA-256");
            props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "/mnt/jks/client.truststore.jks");
            props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "cagri3541");
            props.put(SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG, "JKS");
            props.put(SaslConfigs.SASL_JAAS_CONFIG, "org.apache.kafka.common.security.scram.ScramLoginModule required username=\"kafka\" password=\"cagri3541\";");

            props.put(ConsumerConfig.GROUP_ID_CONFIG, "cagri-parallel-group");
            props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
            props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());

            props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
            props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
            props.put(ConsumerConfig.SESSION_TIMEOUT_MS_CONFIG, "10000");
            props.put(ConsumerConfig.REQUEST_TIMEOUT_MS_CONFIG, "5000");
        }

        @Override
        public void run() {
            System.out.println("[" + name + "] Thread Started. Connecting...");
            KafkaConsumer<String, String> consumer = null;

            while (running) {
                try {
                    if (consumer == null) {
                        consumer = new KafkaConsumer<>(props);
                        consumer.subscribe(Collections.singletonList(topic));
                        System.out.println("[" + name + "] Connected!");
                    }

                    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));

                    if (!records.isEmpty()) {
                        for (ConsumerRecord<String, String> record : records) {
                            System.out.printf("[%s] >>> Recv: %s | Offset: %d%n", 
                                    name, record.value(), record.offset());
                        }
                        consumer.commitSync();
                    }

                } catch (Exception e) {
                    System.err.println("[" + name + "] Error: " + e.getMessage());
                    if (consumer != null) {
                        try { consumer.close(); } catch (Exception ignored) { }
                    }
                    consumer = null;
                    try { Thread.sleep(2000); } catch (InterruptedException ie) { Thread.currentThread().interrupt(); }
                }
            }

            if (consumer != null) consumer.close();
            System.out.println("[" + name + "] Thread Stopped.");
        }

        public void shutdown() {
            this.running = false;
        }
    }

    // 2. Main Entry Point
    public static void main(String[] args) {
        String topic = TOPIC_NAME;
        System.out.println("--- Starting PARALLEL Consumers on " + topic + " ---");

        ClusterConsumerThread workerA = new ClusterConsumerThread("Cluster-A", "cluster-a.dahbest.kfn:9192", topic);
        Thread t1 = new Thread(workerA);
        t1.start();

        ClusterConsumerThread workerB = new ClusterConsumerThread("Cluster-B", "cluster-b.dahbest.kfn:9192", topic);
        Thread t2 = new Thread(workerB);
        t2.start();

        try {
            t1.join();
            t2.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
    }

}