using System;
using System.Collections.Generic;

namespace MyStagePass.Model
{
	public class Event
	{
		public int EventID { get; set; }
		public string? EventName { get; set; }
		public string? Description { get; set; }
		public int TicketsSold { get; set; }
		public int TicketsAvailable { get; set; }
		public byte[]? Image { get; set; }
		public int PerformerID { get; set; }
		public virtual Performer Performer { get; set; } = null!;
		public DateTime EventDate { get; set; }
		public int LocationID { get; set; }
		public virtual Location Location { get; set; } = null!;
		public int StatusID { get; set; }
		public virtual Status Status { get; set; } = null!;

	}
}
