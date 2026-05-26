using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class GenreInsertRequest
	{
		[Required]
		[MinLength(3)]
		public string Name { get; set; }
	}
}