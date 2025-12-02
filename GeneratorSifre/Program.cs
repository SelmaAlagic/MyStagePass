using System;
using MyStagePass.Services.Helpers;
class Program
{
	static void Main()
	{
		var users = new (string Username, string PlainPassword)[]
		{
			("admin", "admin123"),
			("dzejla", "dzejla123"),
			("ilma", "ilma1234"),
			("jelena", "jelena123"),
			("toni", "toni1234"),
			("zeljko", "zeljko123"),
			("selmica", "selma123"),
			("eda", "eda12345"),
			("tess", "tesa1234")
		};

		foreach (var user in users)
		{
			string salt = PasswordHelper.GenerateSalt();
			string hash = PasswordHelper.GenerateHash(salt, user.PlainPassword);

			Console.WriteLine($"// Username: {user.Username}, PlainPassword: {user.PlainPassword}");
			Console.WriteLine($"Salt: \"{salt}\"");
			Console.WriteLine($"Hash: \"{hash}\"");
			Console.WriteLine();
		}

		Console.WriteLine("Press any key to exit...");
		Console.ReadKey();
	}
}
