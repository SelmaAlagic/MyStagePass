namespace MyStagePass.Model.Models
{
	public class PerformerGenre
	{
		public int PerformerGenreID { get; set; }
		public int PerformerID { get; set; }
		public virtual Performer Performer { get; set; } = null!;

		public int GenreID { get; set; }
		public virtual Genre Genre { get; set; } = null!;
	}
}
