using Microsoft.EntityFrameworkCore.Metadata.Builders;
namespace MyStagePass.Services.Database.Seed
{
	public static class ReviewData
	{
		public static void SeedData(this EntityTypeBuilder<Review> entity)
		{
			entity.HasData(
				new Review { ReviewID = 1, CustomerID = 1, EventID = 9, RatingValue = 5, CreatedAt = new DateTime(2025, 4, 13, 10, 0, 0) },
				new Review { ReviewID = 2, CustomerID = 2, EventID = 9, RatingValue = 4, CreatedAt = new DateTime(2025, 4, 13, 14, 30, 0) },
				new Review { ReviewID = 3, CustomerID = 3, EventID = 9, RatingValue = 5, CreatedAt = new DateTime(2025, 4, 14, 9, 0, 0) },
				new Review { ReviewID = 4, CustomerID = 4, EventID = 20, RatingValue = 5, CreatedAt = new DateTime(2025, 8, 26, 11, 0, 0) },
				new Review { ReviewID = 5, CustomerID = 5, EventID = 20, RatingValue = 4, CreatedAt = new DateTime(2025, 8, 26, 15, 20, 0) },
				new Review { ReviewID = 6, CustomerID = 6, EventID = 20, RatingValue = 5, CreatedAt = new DateTime(2025, 8, 27, 18, 0, 0) }
			);
		}
	}
}