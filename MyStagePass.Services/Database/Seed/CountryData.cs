using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CountryData
	{
		public static void SeedData(this EntityTypeBuilder<Country> entity)
		{
			entity.HasData(
				new Country { CountryID = 1, Name = "Bosnia and Herzegovina" },
				new Country { CountryID = 2, Name = "Croatia" },
				new Country { CountryID = 3, Name = "North Macedonia" },
				new Country { CountryID = 4, Name = "Montenegro" },
				new Country { CountryID = 5, Name = "Serbia" }
			);
		}
	}
}
