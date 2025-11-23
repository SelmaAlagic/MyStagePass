using System;
using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class LocationInsertRequest
	{
		[Required]
		[MinLength(5)]
		public string LocationName { get; set; }

		[Required]
		[Range(1, 100000, ErrorMessage = "Capacity must be between 1 and 100000.")]
		public int Capacity { get; set; }

		[Required]
		[MinLength(5)]
		public string Address { get; set; }

		[Required]
		public int CityID { get; set; }
	}
}