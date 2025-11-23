using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class Genre
    {
        public int GenreID { get; set; }
        public string? Name { get; set; }
        public List<string> Performers { get; set; } = new List<string>();
	}
}