using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
    public class CountryInsertRequest
    {
		[Required]
		[MinLength(3)]
		public string Name { get; set; }
    }
}