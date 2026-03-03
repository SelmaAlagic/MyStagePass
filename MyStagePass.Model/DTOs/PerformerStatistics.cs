namespace MyStagePass.Model.DTOs
{
	public class PerformerStatistics
	{
		public int TotalTicketsSold { get; set; }
		public decimal TotalRevenue { get; set; }
		public decimal RegularRevenue { get; set; }
		public decimal VipRevenue { get; set; }
		public decimal PremiumRevenue { get; set; }
		public int RegularTicketsSold { get; set; }
		public int VipTicketsSold { get; set; }
		public int PremiumTicketsSold { get; set; }

	}
}
