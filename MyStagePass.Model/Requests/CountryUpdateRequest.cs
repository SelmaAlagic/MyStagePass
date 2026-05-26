
using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class CountryUpdateRequest
	{
		[MinLength(3)]
		public string? Name {  get; set; }
		public bool? IsActive {  get; set; }
	}
}