using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class StatusUpdateRequest
	{
		[Required]
		[MinLength(3)]
		public string? StatusName { get; set; }
	}
}
