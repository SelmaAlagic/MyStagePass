namespace MyStagePass.Services.Database
{
	public class Ticket
	{
		public int TicketID { get; set; }
		public int Price {  get; set; }
		public int EventID {  get; set; }
		public TicketType TicketType { get; set; }
		public virtual Event Event { get; set; } = null!;
		public int PurchaseID { get; set; }
		public virtual Purchase Purchase { get; set; } = null!;
		public bool IsDeleted { get; set; } = false;
	}
}