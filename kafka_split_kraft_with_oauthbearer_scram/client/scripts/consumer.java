//> using jvm "21"
//> using dep "org.apache.kafka:kafka-clients:4.2.0"
//> using dep "org.slf4j:slf4j-simple:2.0.17"
//> using dep "io.strimzi:kafka-oauth-client:0.17.1"

package cagri.aktas;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;
import org.apache.kafka.common.serialization.StringDeserializer;

import java.time.Duration;
import java.util.List;
import java.util.Properties;

public class consumer {

    private static final String TOPIC_NAME  = "cagri-topic";
    private static final String GROUP_ID    = "cagri-consumer-group";
    private static final int    POLL_TIMEOUT = 500; // ms

    public static Properties configs() {
        Properties props = new Properties();
        props.put(ConsumerConfig.CLIENT_ID_CONFIG, "cagri-consumer");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, GROUP_ID);
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker1:9092,broker2:9092,broker3:9092");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "true");

        props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
        props.put(SaslConfigs.SASL_MECHANISM, "OAUTHBEARER");
        props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "/mnt/jks/client.truststore.jks");
        props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "cagri3541");
        props.put(SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG, "PKCS12");
        props.put(SslConfigs.SSL_ENDPOINT_IDENTIFICATION_ALGORITHM_CONFIG, "");

        props.put(SaslConfigs.SASL_LOGIN_CALLBACK_HANDLER_CLASS,
                "io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler");

        String jaasConfig = "org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required " +
                "oauth.client.id=\"kafka-admin\" " +
                "oauth.client.secret=\"aTCgOCh39yrevYCf60yIuo7WH1heozWN\" " +
                "oauth.token.endpoint.uri=\"https://keycloak.dahbest.kfn:8443/realms/master/protocol/openid-connect/token\" " +
                "oauth.ssl.truststore.location=\"/mnt/jks/client.truststore.jks\" " +
                "oauth.ssl.truststore.password=\"cagri3541\" " +
                "oauth.ssl.truststore.type=\"PKCS12\" " +
                "oauth.ssl.endpoint.identification.algorithm=\"\";";
        props.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig);

        return props;
    }

    public static void main(String[] args) {
        System.out.println("Consuming from topic: " + TOPIC_NAME + " | group: " + GROUP_ID);

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(configs())) {
            consumer.subscribe(List.of(TOPIC_NAME));

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(POLL_TIMEOUT));

                if (records.isEmpty()) {
                    System.out.println("[POLL] No records received, waiting...");
                    continue;
                }

                for (ConsumerRecord<String, String> record : records) {
                    System.out.printf("[RECEIVED] partition=%d | offset=%d | key=%s | value=%s%n",
                            record.partition(), record.offset(), record.key(), record.value());
                }
            }
        }
    }
}