using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class LocationData
	{
		public static void SeedData(this EntityTypeBuilder<Location> entity)
		{
			entity.HasData(
				new Location { LocationID = 1, LocationName = "Arena Sarajevo", Capacity = 15000, Address = "Titova 1, Sarajevo", CityID = 1 },
				new Location { LocationID = 2, LocationName = "Skenderija Hall", Capacity = 5000, Address = "Skenderija 3, Sarajevo", CityID = 1 },
				new Location { LocationID = 3, LocationName = "Zetra Olympic Hall", Capacity = 12000, Address = "Zetra 10, Sarajevo", CityID = 1 },
				new Location { LocationID = 4, LocationName = "Banja Luka Arena", Capacity = 8000, Address = "Trg Krajine 5, Banja Luka", CityID = 2 },
				new Location { LocationID = 5, LocationName = "Tuzla Stadium", Capacity = 7000, Address = "Stadionska 1, Tuzla", CityID = 3 },
				new Location { LocationID = 6, LocationName = "Mostar Music Hall", Capacity = 4000, Address = "Mostarska 15, Mostar", CityID = 4 },
				new Location { LocationID = 7, LocationName = "Split Arena", Capacity = 12000, Address = "Dom Sportova 1, Split", CityID = 7 },
				new Location { LocationID = 8, LocationName = "Zagreb Arena", Capacity = 16000, Address = "Avenija Dubrovnik 15, Zagreb", CityID = 8 },
				new Location { LocationID = 9, LocationName = "Podgorica Sports Center", Capacity = 9000, Address = "Trg Republike 2, Podgorica", CityID = 9 },
				new Location { LocationID = 10, LocationName = "Belgrade Arena", Capacity = 18000, Address = "Ušće 5, Beograd", CityID = 10 }
			);
		}
	}
}