using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class UserData
	{
		public static void SeedData(this EntityTypeBuilder<User> entity)
		{
			// Minimalni validni PNG 1x1 pixel bijele boje
			string sampleBase64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/wIAAgUBAO+f4LkAAAAASUVORK5CYII=";

			entity.HasData(
				new User { UserID = 1, FirstName = "Admin", LastName = "User", Username = "admin", Email = "admin@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "000000000", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				// Performeri
				new User { UserID = 2, FirstName = "Dzejla", LastName = "Ramovic", Username = "dzejla", Email = "dzejla@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "111222333", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				new User { UserID = 3, FirstName = "Ilma", LastName = "Karahmet", Username = "ilma", Email = "ilma@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "222333444", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				new User { UserID = 4, FirstName = "Jelena", LastName = "Rozga", Username = "jelena", Email = "jelena@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "333444555", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				new User { UserID = 5, FirstName = "Toni", LastName = "Cetinski", Username = "toni", Email = "toni@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "444555666", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				new User { UserID = 6, FirstName = "Zeljko", LastName = "Samardzic", Username = "zeljko", Email = "zeljko@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "555666777", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				// Customeri
				new User { UserID = 7, FirstName = "Selma", LastName = "Alagic", Username = "selmica", Email = "selma@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "666777888", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				new User { UserID = 8, FirstName = "Eda", LastName = "Erdem", Username = "eda", Email = "eda@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "777888999", IsActive = true, Image = Convert.FromBase64String(sampleBase64) },
				new User { UserID = 9, FirstName = "Tesa", LastName = "Zahirovic", Username = "tess", Email = "tesa@example.com", Password = "hashed_password", Salt = "salt", PhoneNumber = "888999000", IsActive = true, Image = Convert.FromBase64String(sampleBase64) }
			);
		}
	}
}
