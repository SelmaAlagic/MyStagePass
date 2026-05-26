using System;

namespace MyStagePass.Model.DTOs
{
	public class CancelledEventItem
	{
		public string EventName { get; set; }
		public string LocationName { get; set; }
		public DateTime EventDate { get; set; }
		public int TicketsSold { get; set; }
		public int RefundsNeeded { get; set; }
		public decimal TotalRefundAmount { get; set; }
	}
}
