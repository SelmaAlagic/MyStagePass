using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class Status //kod eventa rejected/approved/pending
    {
        public int StatusID { get; set; }
        public string? StatusName { get; set; }
		public ICollection<Event> Events { get; set; } = new List<Event>();
	}
}