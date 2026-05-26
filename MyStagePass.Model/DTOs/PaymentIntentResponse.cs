namespace MyStagePass.Model.DTOs
{
	public class PaymentIntentResponse
	{
		public string PaymentIntentId { get; set; } = string.Empty;
		public string ClientSecret { get; set; } = string.Empty;
		public long AmountInEur { get; set; }
	}
}