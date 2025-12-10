namespace MyStagePass.Services.Interfaces
{
	public interface IRabbitMQProducer
	{
		public void SendMessage<T>(T message);
	}
}