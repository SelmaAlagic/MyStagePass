using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class CustomerUpdateRequest
	{
		
		[EmailAddress]
		public string? Email { get; set; }

		[MinLength(5)]
		public string? Username { get; set; }

		[MinLength(6)]
		public string? Password { get; set; }
		[MinLength(6)]
		public string? PasswordConfirm { get; set; }
		public byte[]? Image { get; set; }
	}
}