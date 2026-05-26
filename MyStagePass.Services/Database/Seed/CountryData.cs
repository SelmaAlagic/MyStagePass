using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CountryData
	{
		public static void SeedData(this EntityTypeBuilder<Country> entity)
		{
			entity.HasData(
				new Country { CountryID = 1, Name = "Bosnia and Herzegovina", IsActive=true },
				new Country { CountryID = 2, Name = "Croatia", IsActive=true },
				new Country { CountryID = 3, Name = "North Macedonia", IsActive=true },
				new Country { CountryID = 4, Name = "Montenegro", IsActive=true },
				new Country { CountryID = 5, Name = "Serbia", IsActive=true }
			);
		}
	}
}