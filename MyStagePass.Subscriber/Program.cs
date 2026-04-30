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
	DispatchConsumersAsync = true
};
factory.ClientProvidedName = "[*] MyStagePass Email Consumer";

IConnection? connection = null;
int retries = 10;
int delaySeconds = 2;

while (retries > 0)
{
	try
	{
		connection = factory.CreateConnection();
		Console.WriteLine("[*] Connected to RabbitMQ.");
		break;
	}
	catch (Exception ex)
	{
		retries--;
		Console.WriteLine($"RabbitMQ not ready, retrying... ({retries} left). Error: {ex.Message}");
		await Task.Delay(TimeSpan.FromSeconds(delaySeconds));
		delaySeconds = Math.Min(delaySeconds * 2, 30);
	}
}

if (connection == null)
{
	Console.WriteLine("Could not connect to RabbitMQ after all retries. Exiting.");
	return;
}

using var channel = connection.CreateModel();

const string exchangeName = "EmailExchange";
const string routingKey = "email_queue";
const string queueName = "EmailQueue";

channel.ExchangeDeclare(exchangeName, ExchangeType.Direct, durable: true);
channel.QueueDeclare(queueName, durable: true, exclusive: false, autoDelete: false, arguments: null);
channel.QueueBind(queueName, exchangeName, routingKey, null);

channel.BasicQos(prefetchSize: 0, prefetchCount: 1, global: false);

var emailService = new EmailService();

var consumer = new AsyncEventingBasicConsumer(channel);
consumer.Received += async (sender, args) =>
{
	var body = args.Body.ToArray();
	string message = Encoding.UTF8.GetString(body);
	Console.WriteLine($"[*] Message received: {message}");

	int attemptDelay = 1;
	for (int attempt = 1; attempt <= 4; attempt++)
	{
		try
		{
			emailService.SendEmail(message);
			channel.BasicAck(args.DeliveryTag, multiple: false);
			Console.WriteLine("[*] Email sent and message acknowledged.");
			return;
		}
		catch (Exception ex)
		{
			Console.WriteLine($"[!] Attempt {attempt} failed: {ex.Message}");
			if (attempt < 4)
			{
				Console.WriteLine($"[!] Retrying in {attemptDelay}s...");
				await Task.Delay(TimeSpan.FromSeconds(attemptDelay));
				attemptDelay *= 2; 
			}
		}
	}

	Console.WriteLine("[!] All retry attempts failed. Rejecting message.");
	channel.BasicNack(args.DeliveryTag, multiple: false, requeue: false);
};

channel.BasicConsume(queueName, autoAck: false, consumer);
Console.WriteLine("[*] Waiting for messages. To exit press CTRL+C");

var cts = new CancellationTokenSource();
Console.CancelKeyPress += (_, e) =>
{
	e.Cancel = true;
	cts.Cancel();
};

try
{
	await Task.Delay(Timeout.Infinite, cts.Token);
}
catch (OperationCanceledException)
{
	Console.WriteLine("[*] Shutting down consumer...");
}
finally
{
	channel.Close();
	connection.Close();
	connection.Dispose();
}