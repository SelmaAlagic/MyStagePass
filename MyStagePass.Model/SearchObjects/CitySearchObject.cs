namespace MyStagePass.Model.SearchObjects
{
	public class CitySearchObject : BaseSearchObject
	{
		public bool? IsActive { get; set; }
		public string? CityName { get; set; }
		public int? CountryID { get; set; }
	}
}
