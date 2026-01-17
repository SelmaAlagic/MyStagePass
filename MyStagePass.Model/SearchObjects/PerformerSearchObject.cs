namespace MyStagePass.Model.SearchObjects
{
	public class PerformerSearchObject : BaseSearchObject
	{
		public bool isUserIncluded { get; set; }
		public string? searchTerm {  get; set; }
		public bool? IsApproved { get; set; }
		public bool? IsPending { get; set; }
		public int? GenreID { get; set; }
	}
}