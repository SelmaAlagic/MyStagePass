using System;

namespace MyStagePass.Model.Models
{
    public class Notification
    {
        public int NotificationID { get; set; }
        public int UserID { get; set; }
        public virtual User User { get; set; } = null!;
        public string Message { get; set; }
        public DateTime CreatedAt { get; set; }
	    public bool isRead {  get; set; }
        public bool IsDeleted { get; set; } = false;
	}
}