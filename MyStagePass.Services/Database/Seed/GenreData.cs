using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class GenreData
	{
		public static void SeedData(this EntityTypeBuilder<Genre> entity)
		{
			entity.HasData(
				new Genre { GenreID = 1, Name = "Rock" },
				new Genre { GenreID = 2, Name = "Pop" },
				new Genre { GenreID = 3, Name = "Jazz" },
				new Genre { GenreID = 4, Name = "Classical" },
				new Genre { GenreID = 5, Name = "Electronic" },
				new Genre { GenreID = 6, Name = "Hip-Hop" },
				new Genre { GenreID = 7, Name = "Metal" },
				new Genre { GenreID = 8, Name = "Folk" }
			);
		}
	}
}
