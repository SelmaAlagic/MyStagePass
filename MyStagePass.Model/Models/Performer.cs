using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;

namespace MyStagePass.Model.Models
{
    public class Performer
    {
        public int PerformerID { get; set; }
        public string? ArtistName { get; set; }
        public string? Bio { get; set; }
		public int UserID { get; set; }
		public virtual User User { get; set; } = null!;
		public List<string> Genres { get; set; } = new List<string>();
		public virtual ICollection<Event> Events { get; set; } = new List<Event>();
		public bool IsApproved { get; set; } = false;

		[NotMapped]
		public float AverageRating { get; set; }
	}
}