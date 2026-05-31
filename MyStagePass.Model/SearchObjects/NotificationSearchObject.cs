namespace MyStagePass.Model.SearchObjects
{
	public class NotificationSearchObject : BaseSearchObject
	{
		public bool? IsRead {  get; set; }
		public int? UserID {  get; set; }
		public bool? IncludeDeleted { get; set; }
	}
}
