using Microsoft.EntityFrameworkCore.Metadata.Builders;
namespace MyStagePass.Services.Database.Seed
{
	public static class ReviewData
	{
		public static void SeedData(this EntityTypeBuilder<Review> entity)
		{
			entity.HasData(
				new Review { ReviewID = 1, CustomerID = 3, EventID = 2, RatingValue = 5, CreatedAt = new DateTime(2024, 7, 23, 10, 0, 0) },
				new Review { ReviewID = 3, CustomerID = 1, EventID = 2, RatingValue = 4, CreatedAt = new DateTime(2024, 7, 24, 9, 15, 0) },
				new Review { ReviewID = 4, CustomerID = 1, EventID = 5, RatingValue = 5, CreatedAt = new DateTime(2024, 8, 6, 11, 0, 0) },
				new Review { ReviewID = 5, CustomerID = 2, EventID = 5, RatingValue = 5, CreatedAt = new DateTime(2024, 8, 6, 15, 20, 0) },
				new Review { ReviewID = 6, CustomerID = 3, EventID = 5, RatingValue = 4, CreatedAt = new DateTime(2024, 8, 7, 18, 45, 0) },
				new Review { ReviewID = 7, CustomerID = 5, EventID = 6, RatingValue = 5, CreatedAt = new DateTime(2025, 2, 15, 20, 10, 0) },
				new Review { ReviewID = 9, CustomerID = 1, EventID = 9, RatingValue = 4, CreatedAt = new DateTime(2024, 10, 13, 16, 0, 0) },
				new Review { ReviewID = 11, CustomerID = 2, EventID = 12, RatingValue = 5, CreatedAt = new DateTime(2024, 7, 8, 22, 15, 0) },
				new Review { ReviewID = 13, CustomerID = 1, EventID = 14, RatingValue = 5, CreatedAt = new DateTime(2024, 11, 19, 21, 0, 0) },
				new Review { ReviewID = 14, CustomerID = 2, EventID = 17, RatingValue = 4, CreatedAt = new DateTime(2025, 1, 1, 15, 45, 0) },
				new Review { ReviewID = 16, CustomerID = 1, EventID = 19, RatingValue = 5, CreatedAt = new DateTime(2024, 11, 16, 23, 10, 0) },
				new Review { ReviewID = 18, CustomerID = 5, EventID = 20, RatingValue = 4, CreatedAt = new DateTime(2024, 8, 26, 20, 15, 0) }
			);
		}
	}
}