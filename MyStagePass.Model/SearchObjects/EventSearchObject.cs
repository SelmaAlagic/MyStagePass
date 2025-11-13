using System;

namespace MyStagePass.Model.SearchObjects
{
	public class EventSearchObject : BaseSearchObject
	{
		public string? Location { get; set; }
		public string? EventName { get; set; }
		public DateTime? EventDateFrom { get; set; }
		public DateTime? EventDateTo { get; set; }
		public bool? IsUpcoming { get; set; }
		public float? MaxPrice { get; set; }
		public float? MinPrice { get; set; }

	}
}
