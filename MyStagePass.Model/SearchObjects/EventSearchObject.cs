using System;

namespace MyStagePass.Model.SearchObjects
{
	public class EventSearchObject : BaseSearchObject
	{
		public int? PerformerID { get; set; }
		public string? searchTerm {  get; set; }
		public int? LocationID{  get; set; }
		public string? Status { get; set; }
		public DateTime? EventDateFrom { get; set; }
		public DateTime? EventDateTo { get; set; }
		public bool? IsUpcoming { get; set; }
		public float? MaxPrice { get; set; }
		public float? MinPrice { get; set; }
	}
}
