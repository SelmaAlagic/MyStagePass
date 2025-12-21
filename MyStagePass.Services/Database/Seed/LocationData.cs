using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class LocationData
	{
		public static void SeedData(this EntityTypeBuilder<Location> entity)
		{
			entity.HasData(
				new Location { LocationID = 1, LocationName = "Arena Sarajevo", Capacity = 15000, Address = "Titova 1", CityID = 1 },
				new Location { LocationID = 2, LocationName = "Skenderija Hall", Capacity = 5000, Address = "Skenderija 3", CityID = 1 },
				new Location { LocationID = 3, LocationName = "Zetra Olympic Hall", Capacity = 12000, Address = "Zetra 10", CityID = 1 },
				new Location { LocationID = 4, LocationName = "Banja Luka Arena", Capacity = 8000, Address = "Trg Krajine 5", CityID = 2 },
				new Location { LocationID = 11, LocationName = "Kastel Fortress", Capacity = 10000, Address = "Teodora Kolokotronisa", CityID = 2 },
				new Location { LocationID = 5, LocationName = "Tuzla Stadium", Capacity = 7000, Address = "Stadionska 1", CityID = 3 },
				new Location { LocationID = 12, LocationName = "Mejdan Hall", Capacity = 5000, Address = "Bosne Srebrene", CityID = 3 },
				new Location { LocationID = 13, LocationName = "Bilino Polje", Capacity = 15000, Address = "Bulevar Kulina bana", CityID = 4 },
				new Location { LocationID = 14, LocationName = "Arena Zenica", Capacity = 6200, Address = "Aleja šehida", CityID = 4 },
				new Location { LocationID = 6, LocationName = "Mostar Music Hall", Capacity = 4000, Address = "Mostarska 15", CityID = 5 },
				new Location { LocationID = 15, LocationName = "Stadion pod Bijelim Brijegom", Capacity = 9000, Address = "Bijeli Brijeg", CityID = 5 },
				new Location { LocationID = 16, LocationName = "Dvorana Luke", Capacity = 3000, Address = "Luke bb", CityID = 6 },
				new Location { LocationID = 17, LocationName = "Stadion pod Borićima", Capacity = 8000, Address = "Borići", CityID = 6 },
				new Location { LocationID = 8, LocationName = "Zagreb Arena", Capacity = 16000, Address = "Avenija Dubrovnik 15", CityID = 7 },
				new Location { LocationID = 18, LocationName = "Dom Sportova", Capacity = 7000, Address = "Trg sportova 11", CityID = 7 },
				new Location { LocationID = 7, LocationName = "Split Arena", Capacity = 12000, Address = "Dom Sportova 1", CityID = 8 },
				new Location { LocationID = 19, LocationName = "Stadion Poljud", Capacity = 34000, Address = "8. Mediteranskih igara 2", CityID = 8 },
				new Location { LocationID = 20, LocationName = "Boris Trajkovski Arena", Capacity = 10000, Address = "Bulevar 8. Septemvri", CityID = 9 },
				new Location { LocationID = 21, LocationName = "National Arena Toshe Proeski", Capacity = 33000, Address = "Aminta Treti", CityID = 9 },
				new Location { LocationID = 9, LocationName = "Podgorica Sports Center", Capacity = 9000, Address = "Trg Republike 2", CityID = 10 },
				new Location { LocationID = 22, LocationName = "Stadion pod Goricom", Capacity = 15000, Address = "Vaka Đurovića", CityID = 10 },
				new Location { LocationID = 23, LocationName = "Top Hill", Capacity = 5000, Address = "Topliš bb", CityID = 11 },
				new Location { LocationID = 24, LocationName = "Jaz Beach Arena", Capacity = 30000, Address = "Plaža Jaz", CityID = 11 },
				new Location { LocationID = 25, LocationName = "Velika Plaža Stage", Capacity = 20000, Address = "Velika Plaža", CityID = 12 },
				new Location { LocationID = 26, LocationName = "Ulcinj Open Hall", Capacity = 3000, Address = "Bulevar Teuta", CityID = 12 },
				new Location { LocationID = 10, LocationName = "Belgrade Arena", Capacity = 18000, Address = "Ušće 5", CityID = 13 },
				new Location { LocationID = 27, LocationName = "Sava Centar", Capacity = 4000, Address = "Milentija Popovića 9", CityID = 13 },
				new Location { LocationID = 28, LocationName = "SPENS Hall", Capacity = 11000, Address = "Sutjeska 2", CityID = 14 },
				new Location { LocationID = 29, LocationName = "Petrovaradin Fortress", Capacity = 40000, Address = "Petrovaradin", CityID = 14 }
			);
		}
	}
}