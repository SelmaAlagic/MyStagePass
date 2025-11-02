namespace MyStagePass.Services.Database
{
	public class Event
	{
		public int EventID { get; set; }
		public string? EventName { get; set; }
		public string? Description { get; set; }
		public int TicketsSold { get; set; }
		public int TicketsAvailable { get; set; }
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
		public ICollection<CustomerFavoriteEvent> FavoritedByCustomers { get; set; } = new List<CustomerFavoriteEvent>();
		public ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
		public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
	}
}
