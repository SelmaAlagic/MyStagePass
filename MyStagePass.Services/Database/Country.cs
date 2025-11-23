namespace MyStagePass.Services.Database
{
	public class Country
	{
		public int CountryID {  get; set; }
		public string? Name { get; set; }
		public virtual ICollection<City> Cities { get; set; } = new List<City>();
	}
}