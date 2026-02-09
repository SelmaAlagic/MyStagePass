using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class AdminUpdateRequest
	{
		[MinLength(3)]
		public string? FirstName { get; set; }

		[MinLength(3)]
		public string? LastName { get; set; }

		[EmailAddress]
		public string? Email { get; set; }

		[MinLength(5)]
		public string? Username { get; set; }

		[MinLength(6)]
		public string? CurrentPassword { get; set; }

		[MinLength(6)]
		public string? Password { get; set; }

		[MinLength(6)]
		public string? PasswordConfirm { get; set; }

		[RegularExpression(@"^\+?0?\d{8,14}$", ErrorMessage = "Invalid phone number.")]
		public string? PhoneNumber { get; set; }
		public string? Image { get; set; } 
	}
}