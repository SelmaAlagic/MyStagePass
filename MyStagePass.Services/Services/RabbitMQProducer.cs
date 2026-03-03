using Microsoft.Extensions.Configuration;
using MyStagePass.Services.Interfaces;
using Newtonsoft.Json;
using RabbitMQ.Client;
using System.Text;

namespace MyStagePass.Services.Services
{
	public class RabbitMQProducer : IRabbitMQProducer
	{
		private readonly IConfiguration _configuration;

		public RabbitMQProducer(IConfiguration configuration)
		{
			_configuration = configuration;
		}

		public void SendMessage<T>(T message)
		{
			var factory = new ConnectionFactory
			{
				HostName = _configuration["RabbitMQ:Host"],
				Port = int.Parse(_configuration["RabbitMQ:Port"]),
				UserName = _configuration["RabbitMQ:Username"],
				Password = _configuration["RabbitMQ:Password"],
			};

			factory.ClientProvidedName = "Rabbit Test Producer";
			var connection = factory.CreateConnection();
			var channel = connection.CreateModel();

			string exchangeName = "EmailExchange";
			string routingKey = "email_queue";
			string queueName = "EmailQueue";

			channel.ExchangeDeclare(exchangeName, ExchangeType.Direct);
			channel.QueueDeclare(queueName, true, false, false, null);
			channel.QueueBind(queueName, exchangeName, routingKey, null);

			string emailModelJson = JsonConvert.SerializeObject(message);
			byte[] messageBodyBytes = Encoding.UTF8.GetBytes(emailModelJson);
			channel.BasicPublish(exchangeName, routingKey, null, messageBodyBytes);
		}
	}
}