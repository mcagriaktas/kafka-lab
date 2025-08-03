using Confluent.Kafka;
using System;
using System.Threading.Tasks;

namespace KafkaKeytabProducer
{
    class Program
    {
        static async Task Main(string[] args)
        {
            Console.WriteLine("Starting Kafka Producer with SASL/SSL and Keytab Authentication");

            // Configuration
            string bootstrapServers = "broker:9092";
            string topicName = "test-topic";
            string keytabPath = "/mnt/keytabs/client-client.keytab";
            string principal = "client/client@EXAMPLE.COM";
            string sslCaLocation = "/mnt/home/dotnet/client.pem";
            string saslKerberosServiceName = "kafka";

            // Setup Kerberos environment
            Environment.SetEnvironmentVariable("KRB5_CLIENT_KTNAME", keytabPath);
            
            try
            {
                // Configure the producer
                var config = new ProducerConfig
                {
                    BootstrapServers = bootstrapServers,
                    SecurityProtocol = SecurityProtocol.SaslSsl,
                    SaslMechanism = SaslMechanism.Gssapi,
                    SaslKerberosServiceName = saslKerberosServiceName,
                    SaslKerberosPrincipal = principal,
                    SaslKerberosKeytab = keytabPath,
                    SslCaLocation = sslCaLocation,
                    EnableDeliveryReports = true
                };

                // Create and use the producer
                using (var producer = new ProducerBuilder<string, string>(config).Build())
                {
                    Console.WriteLine("Producer initialized. Sending message...");

                    string key = "message-key";
                    string value = $"Hello from .NET Producer at {DateTime.Now}";

                    try
                    {
                        var deliveryResult = await producer.ProduceAsync(
                            topicName,
                            new Message<string, string> { Key = key, Value = value }
                        );

                        Console.WriteLine($"Message delivered to: {deliveryResult.TopicPartitionOffset}");
                    }
                    catch (ProduceException<string, string> ex)
                    {
                        Console.WriteLine($"Failed to deliver message: {ex.Message}");
                    }
                }

                Console.WriteLine("Producer completed successfully");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"An error occurred: {ex.Message}");
            }
        }
    }
}
