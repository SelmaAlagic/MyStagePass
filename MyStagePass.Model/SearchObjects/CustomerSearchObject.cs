namespace MyStagePass.Model.SearchObjects
{
	public class CustomerSearchObject : BaseSearchObject
	{
		public bool isUserIncluded { get; set; }
		public string? searchTerm {  get; set; }
	}
}
