namespace MyStagePass.Model.Requests
{
	public class PaymentRequest
	{
		public long Amount { get; set; }
		public int EventId { get; set; }
		public int NumberOfTickets { get; set; }
		public int TicketType { get; set; }
	}
}