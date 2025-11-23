using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyStagePass.Model.Models
{
	public class Event
	{
		public enum TicketType
		{
			Regular = 1,
			Vip = 2,
			Premium = 3
		}
		public int EventID { get; set; }
		public string? EventName { get; set; }
		public string? Description { get; set; }
		public int TotalTickets { get; set; }
		public int TicketsSold { get; set; }
		public int RegularPrice { get; set; }
		public int VipPrice { get; set; }
		public int PremiumPrice { get; set; }
		public int PerformerID { get; set; }
		public virtual Performer Performer { get; set; } = null!;
		public DateTime EventDate { get; set; }
		public int LocationID { get; set; }
		public virtual Location Location { get; set; } = null!;
		public int StatusID { get; set; }
		public virtual Status Status { get; set; } = null!;
		public int TotalScore { get; set; } //ukupan zbir ocjena iz recenzija
		public int RatingCount { get; set; } //broj ocjena recenzija
		public float RatingAverage { get; set; } //prosjecne ocjena svih recenzija
		public virtual ICollection<CustomerFavoriteEvent> FavoritedByCustomers { get; set; } = new List<CustomerFavoriteEvent>();
		public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
		public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();

		[NotMapped]
		public int TicketsAvailable => TotalTickets - TicketsSold;
		public bool HasAvailableTickets(int requestedAmount)
		{
			return TicketsAvailable >= requestedAmount;
		}

		[NotMapped]
		public string TimeStatus
		{
			get
			{
				if (EventDate < DateTime.Now)
					return "Ended";
				else
					return "Upcoming";
			}
		}
	}
}