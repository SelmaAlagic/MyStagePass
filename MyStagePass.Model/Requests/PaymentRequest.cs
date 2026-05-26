using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class PaymentRequest
	{
		public int EventId { get; set; }

		[Range(1, int.MaxValue, ErrorMessage = "Number of tickets must be at least 1.")]
		public int NumberOfTickets { get; set; }

		[Range(1, 3, ErrorMessage = "TicketType must be 1 (Regular), 2 (Vip) or 3 (Premium).")]
		public int TicketType { get; set; }
	}
}