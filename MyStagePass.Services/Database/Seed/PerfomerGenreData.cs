using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class PerformerGenreData
	{
		public static void SeedData(this EntityTypeBuilder<PerformerGenre> entity)
		{
			entity.HasData(
			   // Dzejla Ramovic
			   new PerformerGenre { PerformerGenreID=1, PerformerID = 1, GenreID = 2 }, // Pop
			   new PerformerGenre { PerformerGenreID=21, PerformerID = 1, GenreID = 3 }, // Jazz
			   new PerformerGenre { PerformerGenreID=13, PerformerID = 1, GenreID = 8 }, // Folk

			   // Ilma Karahmet
			   new PerformerGenre { PerformerGenreID=4, PerformerID = 2, GenreID = 2 }, // Pop
			   new PerformerGenre { PerformerGenreID=5, PerformerID = 2, GenreID = 8 }, // Folk

			   // Jelena Rozga
			   new PerformerGenre { PerformerGenreID=6, PerformerID = 3, GenreID = 2 }, // Pop
			   new PerformerGenre { PerformerGenreID=7, PerformerID = 3, GenreID = 5 }, // Electronic

			   // Toni Cetinski
			   new PerformerGenre { PerformerGenreID=8, PerformerID = 4, GenreID = 2 }, // Pop
			   new PerformerGenre { PerformerGenreID=9, PerformerID = 4, GenreID = 1 }, // Rock

			   // Zeljko Samardzic
			   new PerformerGenre { PerformerGenreID=10, PerformerID = 5, GenreID = 8 });  // Folk
		}
	}
}
