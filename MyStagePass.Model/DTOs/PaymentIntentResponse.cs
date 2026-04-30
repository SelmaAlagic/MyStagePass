namespace MyStagePass.Model.DTOs
{
	public class PaymentIntentResponse
	{
		public string ClientSecret { get; set; } = string.Empty;
		public long AmountInKM { get; set; }
		public long AmountInCents { get; set; }
	}
}