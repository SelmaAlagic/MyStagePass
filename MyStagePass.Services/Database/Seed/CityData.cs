using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CityData
	{
		public static void SeedData(this EntityTypeBuilder<City> entity)
		{
			entity.HasData(
				new City { CityID = 1, Name = "Sarajevo", CountryID = 1, IsActive=true },
				new City { CityID = 2, Name = "Banja Luka", CountryID = 1, IsActive=true },
				new City { CityID = 3, Name = "Tuzla", CountryID = 1, IsActive=true },
				new City { CityID = 4, Name = "Zenica", CountryID = 1, IsActive=true },
				new City { CityID = 5, Name = "Mostar", CountryID = 1, IsActive=true },
				new City { CityID = 6, Name = "Bihać", CountryID = 1, IsActive=true },
				new City { CityID = 7, Name = "Zagreb", CountryID = 2, IsActive=true },
				new City { CityID = 8, Name = "Split", CountryID = 2, IsActive=true },
				new City { CityID = 9, Name = "Skoplje", CountryID = 3, IsActive=true },
				new City { CityID = 10, Name = "Podgorica", CountryID = 4, IsActive=true },
				new City { CityID = 11, Name = "Budva", CountryID = 4, IsActive=true },
				new City { CityID = 12, Name = "Ulcinj", CountryID = 4, IsActive=true },
				new City { CityID = 13, Name = "Beograd", CountryID = 5, IsActive=true },
				new City { CityID = 14, Name = "Novi Sad", CountryID = 5, IsActive=true }
			);
		}
	}
}