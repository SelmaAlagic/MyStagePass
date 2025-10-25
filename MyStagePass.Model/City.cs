namespace MyStagePass.Model
{
	public class City
	{
		public int CityID { get; set; }
		public string? Name { get; set; }
		public int CountryID {  get; set; }
		public virtual Country Country { get; set; } = null!;
	}
}
