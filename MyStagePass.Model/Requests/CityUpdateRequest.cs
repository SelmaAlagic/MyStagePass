using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class CityUpdateRequest
	{
		[MinLength(2)]
		public string? Name { get; set; }
		public int? CountryID { get; set; }
		public bool? IsActive { get; set; }
	}
}