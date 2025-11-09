using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class Performer
    {
        public int PerformerID { get; set; }
        public string? ArtistName { get; set; }
        public string? Bio { get; set; }
		public int UserID { get; set; }
		public virtual User User { get; set; } = null!;
		public ICollection<PerformerGenre> Genres { get; set; } = new List<PerformerGenre>();

		public bool IsApproved { get; set; }
	}
}
