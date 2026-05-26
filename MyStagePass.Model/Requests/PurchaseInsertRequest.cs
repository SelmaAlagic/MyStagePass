using MyStagePass.Model.Models;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace MyStagePass.Model.Requests
{
	public class PurchaseInsertRequest
	{
		[Required]
		public int EventID { get; set; }

		[JsonIgnore]
		public int CustomerID { get; set; }

		[Required]
		[Range(1, int.MaxValue, ErrorMessage = "Number of tickets must be at least 1.")]
		public int NumberOfTickets { get; set; }

		[Required]
		public TicketType TicketType { get; set; }

		[JsonIgnore]
		public string? PaymentIntentId { get; set; }
	}
}