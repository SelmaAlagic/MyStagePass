using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class GenreUpdateRequest
	{
		[MinLength(3)]
		public string? Name { get; set; }
	}
}
