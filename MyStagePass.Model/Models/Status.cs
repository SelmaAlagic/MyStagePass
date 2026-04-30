using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class Status 
    {
		public const int PendingID = 1;
		public const int ApprovedID = 2;
		public const int RejectedID = 3;
		public const int CancelledID = 4;
		public int StatusID { get; set; }
        public string? StatusName { get; set; }
		public ICollection<Event> Events { get; set; } = new List<Event>();
	}
}