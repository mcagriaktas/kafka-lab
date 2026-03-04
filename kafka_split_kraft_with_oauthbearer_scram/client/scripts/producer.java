//> using jvm "21"
//> using dep "org.apache.kafka:kafka-clients:4.2.0"
//> using dep "org.slf4j:slf4j-simple:2.0.17"
//> using dep "io.strimzi:kafka-oauth-client:0.17.1"

package cagri.aktas;

import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;
import org.apache.kafka.common.serialization.StringSerializer;

import java.time.Duration;
import java.util.Properties;

public class producer {

    private static final String TOPIC_NAME = "cagri-topic";
    private static final int MESSAGE_COUNT = 100;

    public static Properties configs() {
        Properties props = new Properties();
        props.put(ProducerConfig.CLIENT_ID_CONFIG, "cagri-producer");
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "broker1:9092,broker2:9092,broker3:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
        props.put(SaslConfigs.SASL_MECHANISM, "OAUTHBEARER");
        props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "/mnt/jks/client.truststore.jks");
        props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "cagri3541");
        props.put(SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG, "PKCS12");
        props.put(SslConfigs.SSL_ENDPOINT_IDENTIFICATION_ALGORITHM_CONFIG, "");

        props.put(SaslConfigs.SASL_LOGIN_CALLBACK_HANDLER_CLASS, "io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler");

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

    public static void main(String[] args) throws InterruptedException {
        System.out.println("Sending " + MESSAGE_COUNT + " messages to topic: " + TOPIC_NAME);

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(configs())) {
            for (int i = 0; i < MESSAGE_COUNT; i++) {
                String key   = "key-" + i;
                String value = "message-" + i;

                producer.send(new ProducerRecord<>(TOPIC_NAME, key, value), (metadata, exception) -> {
                    if (exception != null) {
                        System.err.println("[FAILED] " + exception.getMessage());
                    } else {
                        System.out.printf("[SENT] partition=%d | offset=%d | key=%s | value=%s%n",
                                metadata.partition(), metadata.offset(), key, value);
                    }
                });

                Thread.sleep(1000); // <-- sleep 1s between messages
            }
            producer.flush();
        }

        System.out.println("Done.");
    }
}