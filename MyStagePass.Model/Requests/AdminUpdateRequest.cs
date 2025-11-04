using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class AdminUpdateRequest
	{
		[Required]
		[EmailAddress]
		public string Email { get; set; }

		[Required]
		[MinLength(5)]
		public string Username { get; set; }

		[Required]
		[MinLength(6)]
		public string Password { get; set; }
	}
}
