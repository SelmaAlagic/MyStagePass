using MyStagePass.Model.Models;

namespace MyStagePass.Model.Requests
{
	public class PurchaseInsertRequest
	{
		public int EventID { get; set; }
		public int CustomerID { get; set; } 
		public int NumberOfTickets { get; set; } 
		public TicketType TicketType { get; set; }
		public string? PaymentIntentId { get; set; }
	}
}