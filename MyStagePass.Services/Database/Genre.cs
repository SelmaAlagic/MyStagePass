namespace MyStagePass.Services.Database
{
	public class Genre
	{
		public int GenreID {  get; set; }
		public string? Name { get; set; }
		public virtual ICollection<PerformerGenre> Performers { get; set; } = new List<PerformerGenre>();
	}
}
