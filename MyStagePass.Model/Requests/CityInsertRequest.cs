using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class CityInsertRequest
	{
		[Required]
		[MinLength(2)]
		public string Name { get; set; }

		[Required]
		public int CountryID { get; set; }
	}
}