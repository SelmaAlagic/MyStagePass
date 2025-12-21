using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class PerformerData
	{
		public static void SeedData(this EntityTypeBuilder<Performer> entity)
		{
			entity.HasData(
				new Performer { PerformerID = 1, ArtistName = "Dzejla Ramovic", Bio = "Pop singer from BiH", IsApproved = true, UserID = 2 },
				new Performer { PerformerID = 2, ArtistName = "Ilma Karahmet", Bio = "Rising pop artist", IsApproved = true, UserID = 3 },
				new Performer { PerformerID = 3, ArtistName = "Jelena Rozga", Bio = "Famous Croatian pop singer", IsApproved = true, UserID = 4 },
				new Performer { PerformerID = 4, ArtistName = "Toni Cetinski", Bio = "Popular Croatian pop singer", IsApproved = true, UserID = 5 },
				new Performer { PerformerID = 5, ArtistName = "Zeljko Samardzic", Bio = "Serbian pop-folk singer", IsApproved = true, UserID = 6 },
				new Performer { PerformerID = 6, ArtistName = "Adi Sose", Bio = "Vocalist known for unique style", IsApproved = true, UserID = 7 },
				new Performer { PerformerID = 7, ArtistName = "Mirza Selimovic", Bio = "Pop-folk singer from BiH", IsApproved = true, UserID = 8 },
				new Performer { PerformerID = 8, ArtistName = "Marija Serifovic", Bio = "Eurovision winner and pop star", IsApproved = true, UserID = 9 },
				new Performer { PerformerID = 9, ArtistName = "Breskvica", Bio = "Modern pop and trap artist", IsApproved = true, UserID = 10 }
			);
		}
	}
}