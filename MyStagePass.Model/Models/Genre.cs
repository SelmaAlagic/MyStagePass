using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class Genre
    {
        public int GenreID { get; set; }
        public string? Name { get; set; }
		public ICollection<PerformerGenre> Performers { get; set; } = new List<PerformerGenre>();

	}
}
