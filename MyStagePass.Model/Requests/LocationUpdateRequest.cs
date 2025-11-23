using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class LocationUpdateRequest
	{
		[MinLength(5)]
		public string? LocationName { get; set; }

		[Range(1, 100000, ErrorMessage = "Capacity must be between 1 and 100000.")]
		public int? Capacity { get; set; }

		[MinLength(5)]
		public string? Address { get; set;}

		public int? CityID { get; set; }
	}
}