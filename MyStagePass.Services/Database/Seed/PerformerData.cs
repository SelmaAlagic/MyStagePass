using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class PerformerData
	{
		public static void SeedData(this EntityTypeBuilder<Performer> entity)
		{
			entity.HasData(
				new Performer { PerformerID = 1, ArtistName = "Dzejlica", Bio = "Pop singer from BiH", IsApproved = true, UserID=2 },
				new Performer { PerformerID = 2, ArtistName = "Ilmica", Bio = "Rising pop artist", IsApproved = true, UserID = 3 },
				new Performer { PerformerID = 3, ArtistName = "Jelena R", Bio = "Famous Croatian pop singer", IsApproved = true, UserID=4 },
				new Performer { PerformerID = 4, ArtistName = "Toni", Bio = "Popular Croatian pop singer", IsApproved = true, UserID=5 },
				new Performer { PerformerID = 5, ArtistName = "Zeljko", Bio = "Serbian pop-folk singer", IsApproved = true, UserID=6 }
			);
		}
	}
}