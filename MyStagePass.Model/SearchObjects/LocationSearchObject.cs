namespace MyStagePass.Model.SearchObjects
{
	public class LocationSearchObject : BaseSearchObject
	{
		public string? LocationName {  get; set; }
		public string? Address {  get; set; }
		public int? CityID { get; set; }
		public bool? IsActive { get; set; }
	}
}
