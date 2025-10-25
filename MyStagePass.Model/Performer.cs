using System.Collections.Generic;

namespace MyStagePass.Model
{
	public class Performer
	{
		public int PerformerID { get; set; }
		public string? ArtistName { get; set; }
		public string? Bio { get; set; }
		public virtual User User { get; set; } = null!;
		public int GenreID {  get; set; }
		public virtual Genre Genre { get; set; } = null!;
		public ICollection<Genre> Genres { get; set; } = new List<Genre>();
		public bool IsApproved { get; set; }


	}
}
