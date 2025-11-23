using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class PerformerInsetRequest
	{
		[Required]
		[MinLength(3)]
		public string FirstName { get; set; }

		[Required]
		[MinLength(3)]
		public string LastName { get; set; }

		[Required]
		[EmailAddress]
		public string Email { get; set; }

		[Required]
		[MinLength(5)]
		public string Username { get; set; }

		[Required]
		[MinLength(5)]
		public string ArtistName { get; set; }

		[Required]
		[MinLength(10)]
		[MaxLength(100)]
		public string Bio { get; set; }

		[Required]
		[MinLength(6)]
		public string Password { get; set; }
		[Required]
		[MinLength(6)]
		public string PasswordConfirm { get; set; }

		[Required]
		[RegularExpression(@"^\+?0?\d{8,14}$", ErrorMessage = "Invalid phone number.")]
		public string PhoneNumber { get; set; }

		public byte[]? Image { get; set; }
	}
}