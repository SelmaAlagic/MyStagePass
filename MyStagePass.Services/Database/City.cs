namespace MyStagePass.Services.Database
{
	public class City
	{
		public int CityID { get; set; }
		public string? Name { get; set; }
		public int CountryID {  get; set; }
		public virtual Country Country { get; set; } = null!;
		public virtual ICollection<Location> Locations { get; set; } = new List<Location>();
	}
}