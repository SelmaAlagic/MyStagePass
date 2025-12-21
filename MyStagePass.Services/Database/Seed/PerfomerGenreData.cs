using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class PerformerGenreData
	{
		public static void SeedData(this EntityTypeBuilder<PerformerGenre> entity)
		{
			entity.HasData(
				new PerformerGenre { PerformerGenreID = 1, PerformerID = 2, GenreID = 2 },
				new PerformerGenre { PerformerGenreID = 2, PerformerID = 2, GenreID = 9 },
				new PerformerGenre { PerformerGenreID = 3, PerformerID = 3, GenreID = 2 },
				new PerformerGenre { PerformerGenreID = 4, PerformerID = 4, GenreID = 2 },
				new PerformerGenre { PerformerGenreID = 5, PerformerID = 4, GenreID = 8 },
				new PerformerGenre { PerformerGenreID = 6, PerformerID = 5, GenreID = 1 },
				new PerformerGenre { PerformerGenreID = 7, PerformerID = 5, GenreID = 2 },
				new PerformerGenre { PerformerGenreID = 8, PerformerID = 6, GenreID = 2 },
				new PerformerGenre { PerformerGenreID = 9, PerformerID = 6, GenreID = 9 },
				new PerformerGenre { PerformerGenreID = 10, PerformerID = 7, GenreID = 2 },
				new PerformerGenre { PerformerGenreID = 11, PerformerID = 8, GenreID = 2 },
				new PerformerGenre { PerformerGenreID = 12, PerformerID = 8, GenreID = 9 },
				new PerformerGenre { PerformerGenreID = 13, PerformerID = 9, GenreID = 2 }
			);
		}
	}
}