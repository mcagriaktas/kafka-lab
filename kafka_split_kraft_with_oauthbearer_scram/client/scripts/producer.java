//> using jvm "21"
//> using dep "org.apache.kafka:kafka-clients:4.2.0"
//> using dep "org.slf4j:slf4j-simple:2.0.17"
//> using dep "io.strimzi:kafka-oauth-client:0.17.1"

package cagri.aktas;

import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpHandler;
import com.sun.net.httpserver.HttpServer;
import org.apache.kafka.clients.CommonClientConfigs;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.config.SaslConfigs;
import org.apache.kafka.common.config.SslConfigs;
import org.apache.kafka.common.serialization.StringSerializer;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.time.Instant;
import java.util.Properties;
import java.util.UUID;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

public class producer {

    private static final String TOPIC_NAME = "topic-a";
    private static final int HTTP_PORT = 5050;
    private static final int QUEUE_CAPACITY = 10000;            // Max pending messages
    private static final int OFFER_TIMEOUT_SECONDS = 1;         // Time to wait if queue is full
    private static volatile boolean running = true;

    // Failure threshold: after this many consecutive failed sends, close & rebuild the producer.
    // This forces Kroxylicious to re-resolve bootstrap and connect to the alive cluster.
    private static final int FAILURE_THRESHOLD = 3;

    // Track consecutive send failures (incremented by callbacks, read/reset by sender thread)
    private static final AtomicInteger consecutiveFailures = new AtomicInteger(0);

    // Holder for the current producer – allows the sender thread to swap it on rebuild
    private static final AtomicReference<KafkaProducer<String, String>> producerRef = new AtomicReference<>();

    // Queue to decouple HTTP handler from Kafka sender
    private static final BlockingQueue<QueueItem> queue = new LinkedBlockingQueue<>(QUEUE_CAPACITY);

    // Simple container for a message with its reception time
    private static class QueueItem {
        final String key;
        final String value;
        final Instant receivedTime;

        QueueItem(String key, String value, Instant receivedTime) {
            this.key = key;
            this.value = value;
            this.receivedTime = receivedTime;
        }
    }

    public static Properties configs() {
        Properties props = new Properties();
        props.put(ProducerConfig.CLIENT_ID_CONFIG, "cagri-producer");
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "cluster-a.dahbest.kfn:9192,cluster-b.dahbest.kfn:9192");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // Security & Authentication
        props.put(CommonClientConfigs.SECURITY_PROTOCOL_CONFIG, "SASL_SSL");
        props.put(SaslConfigs.SASL_MECHANISM, "OAUTHBEARER");
        props.put(SslConfigs.SSL_TRUSTSTORE_LOCATION_CONFIG, "/home/cagri/project/test/kafka-kroxylicious/client/jks/client.truststore.jks");
        props.put(SslConfigs.SSL_TRUSTSTORE_PASSWORD_CONFIG, "cagri3541");
        props.put(SslConfigs.SSL_TRUSTSTORE_TYPE_CONFIG, "PKCS12");
        props.put(SslConfigs.SSL_ENDPOINT_IDENTIFICATION_ALGORITHM_CONFIG, "");

        // OAuth callback
        props.put(SaslConfigs.SASL_LOGIN_CALLBACK_HANDLER_CLASS, "io.strimzi.kafka.oauth.client.JaasClientOauthLoginCallbackHandler");

        // JAAS config (using kafka-admin user as you had)
        String jaasConfig = "org.apache.kafka.common.security.oauthbearer.OAuthBearerLoginModule required " +
                "oauth.client.id=\"kafka-admin\" " +
                "oauth.client.secret=\"aTCgOCh39yrevYCf60yIuo7WH1heozWN\" " +
                "oauth.token.endpoint.uri=\"https://keycloak.dahbest.kfn:8443/realms/master/protocol/openid-connect/token\" " +
                "oauth.ssl.truststore.location=\"/home/cagri/project/test/kafka-kroxylicious/client/jks/client.truststore.jks\" " +
                "oauth.ssl.truststore.password=\"cagri3541\" " +
                "oauth.ssl.truststore.type=\"PKCS12\" " +
                "oauth.ssl.endpoint.identification.algorithm=\"\";";
        props.put(SaslConfigs.SASL_JAAS_CONFIG, jaasConfig);

        // Producer tuning
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, "5");
        props.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, "14100");
        props.put(ProducerConfig.SOCKET_CONNECTION_SETUP_TIMEOUT_MS_CONFIG, "5000");
        props.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, "3000");
        props.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, "1000");
        props.put(ProducerConfig.RETRIES_CONFIG, "10");

        return props;
    }

    /**
     * Creates a fresh KafkaProducer instance and stores it in the AtomicReference.
     */
    private static KafkaProducer<String, String> buildProducer() {
        KafkaProducer<String, String> p = new KafkaProducer<>(configs());
        producerRef.set(p);
        System.out.println("[Producer] New KafkaProducer instance created");
        return p;
    }

    public static void main(String[] args) throws IOException {
        // Create the initial Kafka producer
        buildProducer();

        // Start the background sender thread
        Thread senderThread = new Thread(() -> runSender(), "kafka-sender");
        senderThread.start();

        // Setup HTTP server
        HttpServer server = HttpServer.create(new InetSocketAddress(HTTP_PORT), 0);
        server.createContext("/", new HttpHandler() {
            @Override
            public void handle(HttpExchange exchange) throws IOException {
                // Only accept POST
                if (!"POST".equalsIgnoreCase(exchange.getRequestMethod())) {
                    exchange.sendResponseHeaders(405, -1); // Method Not Allowed
                    return;
                }

                // Read request body
                InputStream is = exchange.getRequestBody();
                String body = new String(is.readAllBytes(), StandardCharsets.UTF_8);
                is.close();

                // Create a queue item with a unique key and the reception timestamp
                QueueItem item = new QueueItem(
                        UUID.randomUUID().toString(),
                        body,
                        Instant.now()
                );

                // Try to enqueue the item; if the queue is full, wait up to OFFER_TIMEOUT_SECONDS
                boolean offered;
                try {
                    offered = queue.offer(item, OFFER_TIMEOUT_SECONDS, TimeUnit.SECONDS);
                } catch (InterruptedException e) {
                    Thread.currentThread().interrupt();
                    sendErrorResponse(exchange, 503, "Server is shutting down");
                    return;
                }

                if (!offered) {
                    // Queue is full – reject the request with 503 Service Unavailable
                    sendErrorResponse(exchange, 503, "Too many pending messages, try again later");
                    return;
                }

                // Successfully queued – acknowledge immediately
                String response = "Accepted\n";
                exchange.sendResponseHeaders(202, response.length());
                try (OutputStream os = exchange.getResponseBody()) {
                    os.write(response.getBytes());
                }
            }
        });

        server.setExecutor(Executors.newCachedThreadPool());
        server.start();
        System.out.println("HTTP server listening on port " + HTTP_PORT);

        // Shutdown hook for graceful exit
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\nShutting down...");
            running = false;
            server.stop(0);

            // Wait for sender thread to finish processing remaining queue items
            try {
                senderThread.interrupt(); // wake up if it's polling
                senderThread.join(10_000); // wait up to 10 seconds
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }

            // Finally close the current producer
            KafkaProducer<String, String> p = producerRef.get();
            if (p != null) {
                p.close(Duration.ofSeconds(5));
            }
            System.out.println("Shutdown complete");
        }));

        // Keep main thread alive until shutdown
        while (running) {
            try {
                //noinspection BusyWait
                Thread.sleep(1);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            }
        }
    }

    // Background task that takes items from the queue and sends them to Kafka.
    // After each send, it checks whether the failure threshold has been reached.
    // If so, it closes the old producer, builds a new one, and resets the counter.
    // This forces Kroxylicious to re-resolve the bootstrap and failover to the alive cluster.
    private static void runSender() {
        System.out.println("Kafka sender thread started");

        while (running) {
            try {
                // --- Check if we need to rebuild the producer due to persistent failures ---
                if (consecutiveFailures.get() >= FAILURE_THRESHOLD) {
                    System.out.println("[Producer] Failure threshold reached (" + FAILURE_THRESHOLD +
                            " consecutive failures). Closing connection and rebuilding producer for failover...");

                    KafkaProducer<String, String> oldProducer = producerRef.get();
                    if (oldProducer != null) {
                        try {
                            oldProducer.close(Duration.ofSeconds(5));
                            System.out.println("[Producer] Old producer closed successfully");
                        } catch (Exception closeEx) {
                            System.err.println("[Producer] Error closing old producer: " + closeEx.getMessage());
                        }
                    }

                    // Small delay before reconnecting to let Kroxylicious detect the cluster state
                    Thread.sleep(2000);

                    // Build a fresh producer – Kroxylicious will route to the alive cluster
                    buildProducer();
                    consecutiveFailures.set(0);
                    System.out.println("[Producer] Producer rebuilt. Kroxylicious will route to the alive cluster.");
                }

                // --- Poll the queue ---
                QueueItem item = queue.poll(1, TimeUnit.SECONDS);
                if (item == null) {
                    continue; // nothing to do, check running flag again
                }

                // Get the current producer instance
                KafkaProducer<String, String> currentProducer = producerRef.get();

                // Send asynchronously with a callback that tracks success/failure
                currentProducer.send(
                        new ProducerRecord<>(TOPIC_NAME, item.key, item.value),
                        new SendCallback(item)
                );
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
                break;
            } catch (Exception e) {
                // Unexpected error (e.g. producer already closed) – log and continue
                System.err.println("[Sender] Unexpected error: " + e.getMessage());
                e.printStackTrace();
            }
        }
        System.out.println("Kafka sender thread stopped");
    }

    // Callback that logs send outcomes and tracks consecutive failures for rebuild logic
    private static class SendCallback implements Callback {
        private final QueueItem item;

        SendCallback(QueueItem item) {
            this.item = item;
        }

        @Override
        public void onCompletion(RecordMetadata metadata, Exception exception) {
            if (exception != null) {
                // Send failed after all internal retries / delivery timeout exhausted
                int failures = consecutiveFailures.incrementAndGet();
                System.err.printf("[Kafka] FAILED to send (key=%s, value=%.20s..., consecutiveFailures=%d): %s%n",
                        item.key, item.value, failures, exception.getMessage());

                // Re-queue the message so it can be retried on the new producer after rebuild
                boolean requeued = queue.offer(item);
                if (requeued) {
                    System.out.println("[Kafka] Message re-queued for retry after producer rebuild");
                } else {
                    System.err.println("[Kafka] Could not re-queue message (queue full), message dropped");
                }
            } else {
                // Success – reset the failure counter
                consecutiveFailures.set(0);

                // Calculate total time from reception to broker ack
                Instant now = Instant.now();
                double elapsedSeconds = (now.toEpochMilli() - item.receivedTime.toEpochMilli()) / 1000.0;
                System.out.printf("[Kafka] Sent | partition=%d | offset=%d | time=%.3fs | value=%.20s...%n",
                        metadata.partition(), metadata.offset(), elapsedSeconds, item.value);
            }
        }
    }

    // Helper to send a plain text error response
    private static void sendErrorResponse(HttpExchange exchange, int statusCode, String message) throws IOException {
        String response = message + "\n";
        exchange.sendResponseHeaders(statusCode, response.length());
        try (OutputStream os = exchange.getResponseBody()) {
            os.write(response.getBytes());
        }
    }
}