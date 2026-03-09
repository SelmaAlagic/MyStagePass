using QRCoder;

namespace MyStagePass.Model.Models
{
	public class Ticket
	{
		public int TicketID { get; set; }
		public int Price { get; set; }
		public int EventID { get; set; }
		public virtual Event Event { get; set; } = null!;
		public int PurchaseID { get; set; }
		public virtual Purchase Purchase { get; set; } = null!;
		public Event.TicketType TicketType { get; set; }
		public bool IsDeleted { get; set; } = false;
		public string GetTicketTypeName()
		{
			return TicketType switch
			{
				Event.TicketType.Regular => "Regular",
				Event.TicketType.Vip => "VIP",
				Event.TicketType.Premium => "Premium",
				_ => "Unknown"
			};
		}
	}
}