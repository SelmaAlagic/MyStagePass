using System.Collections.Generic;

namespace MyStagePass.Model.DTOs
{
	public class SalesReportDto
	{
		public int TotalTicketsSold { get; set; }
		public int TotalRevenue { get; set; }
		public string? TopPerformer { get; set; }
		public string? TopLocation { get; set; }
		public List<ChartItemDto> PerformerSales { get; set; } = new List<ChartItemDto>();
		public List<ChartItemDto> LocationSales { get; set; } = new List<ChartItemDto>();
	}
}