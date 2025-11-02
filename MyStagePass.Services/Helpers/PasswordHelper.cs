using System.Security.Cryptography;
using System.Text;

namespace MyStagePass.Services.Helpers
{
	public static class PasswordHelper
	{
		public static string GenerateSalt()
		{
			using var rng = RandomNumberGenerator.Create();
			var saltBytes = new byte[32];
			rng.GetBytes(saltBytes);
			return Convert.ToBase64String(saltBytes);
		}

		public static string GenerateHash(string salt, string password)
		{
			byte[] saltBytes = Convert.FromBase64String(salt);
			byte[] passwordBytes = Encoding.Unicode.GetBytes(password);
			byte[] combinedBytes = new byte[saltBytes.Length + passwordBytes.Length];

			Buffer.BlockCopy(saltBytes, 0, combinedBytes, 0, saltBytes.Length);
			Buffer.BlockCopy(passwordBytes, 0, combinedBytes, saltBytes.Length, passwordBytes.Length);

			using var sha256 = SHA256.Create();
			byte[] hashBytes = sha256.ComputeHash(combinedBytes);
			return Convert.ToBase64String(hashBytes);
		}

		public static bool VerifyPassword(string enteredPassword, string storedPasswordHash, string storedSalt)
		{
			string enteredHash = GenerateHash(storedSalt, enteredPassword);
			return enteredHash == storedPasswordHash;
		}
	}
}
