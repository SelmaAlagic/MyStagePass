namespace MyStagePass.Model.SearchObjects
{
	public class LocationSearchObject : BaseSearchObject
	{
		public string? LocationName {  get; set; }
		public string? Address {  get; set; }
		public int? CapacityFrom { get; set; }
		public int? CapacityTo { get; set; }
	}
}
