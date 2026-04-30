using System.Security.Cryptography;

namespace MyStagePass.Services.Helpers
{
	public static class PasswordHelper
	{
		private const int SaltSize = 32;
		private const int HashSize = 32;
		private const int Iterations = 100_000;
		private static readonly HashAlgorithmName Algorithm = HashAlgorithmName.SHA256;

		public static string GenerateSalt()
		{
			var saltBytes = new byte[SaltSize];
			RandomNumberGenerator.Fill(saltBytes);
			return Convert.ToBase64String(saltBytes);
		}

		public static string GenerateHash(string salt, string password)
		{
			byte[] saltBytes = Convert.FromBase64String(salt);
			byte[] hashBytes = Rfc2898DeriveBytes.Pbkdf2(
				password,
				saltBytes,
				Iterations,
				Algorithm,
				HashSize
			);
			return Convert.ToBase64String(hashBytes);
		}

		public static bool VerifyPassword(string enteredPassword, string storedPasswordHash, string storedSalt)
		{
			string enteredHash = GenerateHash(storedSalt, enteredPassword);
			return CryptographicOperations.FixedTimeEquals(
				Convert.FromBase64String(enteredHash),
				Convert.FromBase64String(storedPasswordHash)
			);
		}
	}
}