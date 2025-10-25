using System.Collections.Generic;

namespace MyStagePass.Model
{
	public class TicketType //VIP, regular, premium
	{
		public int TicketTypeID {  get; set; }
		public string? TicketTypeName {  get; set; }
		public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
	}
}
