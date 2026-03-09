using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using MyStagePass.Subscriber;

var factory = new ConnectionFactory
{
	HostName = Environment.GetEnvironmentVariable("RABBITMQ_HOST"),
	Port = int.Parse(Environment.GetEnvironmentVariable("RABBITMQ_PORT") ?? "5672"),
	UserName = Environment.GetEnvironmentVariable("RABBITMQ_USERNAME"),
	Password = Environment.GetEnvironmentVariable("RABBITMQ_PASSWORD"),
};
factory.ClientProvidedName = " [*] Rabbit Test Consumer";

IConnection connection = null;
int retries = 10;
while (retries > 0)
{
	try
	{
		connection = factory.CreateConnection();
		break;
	}
	catch (Exception ex)
	{
		retries--;
		Console.WriteLine($"RabbitMQ not ready, retrying... ({retries} left). Error: {ex.Message}");
		await Task.Delay(5000);
	}
}

if (connection == null)
{
	Console.WriteLine("Could not connect to RabbitMQ. Exiting.");
	return;
}

IModel channel = connection.CreateModel();
string exchangeName = "EmailExchange";
string routingKey = "email_queue";
string queueName = "EmailQueue";
channel.ExchangeDeclare(exchangeName, ExchangeType.Direct);
channel.QueueDeclare(queueName, true, false, false, null);
channel.QueueBind(queueName, exchangeName, routingKey, null);
var consumer = new EventingBasicConsumer(channel);
consumer.Received += (sender, args) =>
{
	var body = args.Body.ToArray();
	string message = Encoding.UTF8.GetString(body);
	Console.WriteLine($" [*] Message received: {message}");
	EmailService emailService = new EmailService();
	emailService.SendEmail(message);
	channel.BasicAck(args.DeliveryTag, false);
};
channel.BasicConsume(queueName, false, consumer);
Console.WriteLine(" [*] Waiting for messages...");
await Task.Delay(Timeout.Infinite);
channel.Close();
connection.Close();