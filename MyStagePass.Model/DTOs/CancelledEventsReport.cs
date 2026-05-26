using System.Collections.Generic;

namespace MyStagePass.Model.DTOs
{
	public class CancelledEventsReportDto
	{
		public string CityName { get; set; }
		public int TotalCancelledEvents { get; set; }
		public int TotalTicketsSold { get; set; }
		public int TotalRefundsNeeded { get; set; }
		public List<CancelledEventItem> Events { get; set; } = new List<CancelledEventItem>();
	}

}
