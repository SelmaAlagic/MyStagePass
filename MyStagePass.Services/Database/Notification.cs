namespace MyStagePass.Services.Database
{
	public class Notification
	{
		public int NotificationID {  get; set; }
		public int UserID {  get; set; }
		public string Message { get; set; }
		public DateTime CreatedAt {  get; set; }
		public bool isRead {  get; set; }

	}
}