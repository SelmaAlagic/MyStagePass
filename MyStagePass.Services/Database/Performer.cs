namespace MyStagePass.Services.Database
{
	public class Performer
	{
		public int PerformerID { get; set; }
		public string? ArtistName { get; set; }
		public string? Bio { get; set; }
		public int UserID {  get; set; }
		public virtual User User { get; set; } = null!;
		public virtual ICollection<PerformerGenre> Genres { get; set; } = new List<PerformerGenre>();
		public virtual ICollection<Event> Events { get; set; } = new List<Event>();
		public bool? IsApproved { get; set; } = null;
	}
}