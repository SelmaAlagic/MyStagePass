using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using MyStagePass.Services.Interfaces;
using Newtonsoft.Json;
using RabbitMQ.Client;
using System.Text;

namespace MyStagePass.Services.Services
{
	public class RabbitMQProducer : IRabbitMQProducer, IDisposable
	{
		private IConnection? _connection;
		private IModel? _channel;
		private readonly ILogger<RabbitMQProducer> _logger;

		public RabbitMQProducer(IConfiguration configuration, ILogger<RabbitMQProducer> logger)
		{
			_logger = logger;
			try
			{
				var factory = new ConnectionFactory
				{
					HostName = configuration["RabbitMQ:Host"],
					Port = int.Parse(configuration["RabbitMQ:Port"]),
					UserName = configuration["RabbitMQ:Username"],
					Password = configuration["RabbitMQ:Password"],
				};
				_connection = factory.CreateConnection();
				_channel = _connection.CreateModel();
				_channel.ExchangeDeclare("EmailExchange", ExchangeType.Direct);
				_channel.QueueDeclare("EmailQueue", true, false, false, null);
				_channel.QueueBind("EmailQueue", "EmailExchange", "email_queue", null);
			}
			catch (Exception ex)
			{
				_logger.LogWarning(ex, "RabbitMQ connection failed. Messaging will be unavailable.");
			}
		}

		public void SendMessage<T>(T message)
		{
			if (_channel == null)
			{
				_logger.LogWarning("RabbitMQ channel is not available. Message not sent.");
				return;
			}

			string json = JsonConvert.SerializeObject(message);
			byte[] body = Encoding.UTF8.GetBytes(json);
			_channel.BasicPublish("EmailExchange", "email_queue", null, body);
		}

		public void Dispose()
		{
			_channel?.Close();
			_connection?.Close();
		}
	}
}