using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class ReviewData
	{
		public static void SeedData(this EntityTypeBuilder<Review> entity)
		{
			entity.HasData(
				new Review { ReviewID = 1, CustomerID = 1, EventID = 1, RatingValue = 5, CreatedAt = new DateTime(2024, 10, 11) },
					new Review { ReviewID = 2, CustomerID = 2, EventID = 1, RatingValue = 5, CreatedAt = new DateTime(2024, 10, 11) },
					new Review { ReviewID = 3, CustomerID = 3, EventID = 1, RatingValue = 4, CreatedAt = new DateTime(2024, 10, 12) },
					new Review { ReviewID = 4, CustomerID = 1, EventID = 2, RatingValue = 5, CreatedAt = new DateTime(2024, 11, 06) },
					new Review { ReviewID = 5, CustomerID = 4, EventID = 2, RatingValue = 5, CreatedAt = new DateTime(2024, 11, 06) },
					new Review { ReviewID = 6, CustomerID = 2, EventID = 3, RatingValue = 5, CreatedAt = new DateTime(2024, 11, 26) },
					new Review { ReviewID = 7, CustomerID = 5, EventID = 3, RatingValue = 4, CreatedAt = new DateTime(2024, 11, 26) },
					new Review { ReviewID = 8, CustomerID = 6, EventID = 4, RatingValue = 4, CreatedAt = new DateTime(2024, 12, 21) },
					new Review { ReviewID = 9, CustomerID = 3, EventID = 4, RatingValue = 3, CreatedAt = new DateTime(2024, 12, 22) },
					new Review { ReviewID = 10, CustomerID = 1, EventID = 5, RatingValue = 5, CreatedAt = new DateTime(2025, 01, 01) },
					new Review { ReviewID = 11, CustomerID = 5, EventID = 5, RatingValue = 4, CreatedAt = new DateTime(2025, 01, 02) },
					new Review { ReviewID = 12, CustomerID = 2, EventID = 6, RatingValue = 5, CreatedAt = new DateTime(2025, 01, 11) },
					new Review { ReviewID = 13, CustomerID = 4, EventID = 6, RatingValue = 4, CreatedAt = new DateTime(2025, 01, 11) },
					new Review { ReviewID = 14, CustomerID = 3, EventID = 7, RatingValue = 5, CreatedAt = new DateTime(2025, 02, 06) },
					new Review { ReviewID = 15, CustomerID = 6, EventID = 7, RatingValue = 5, CreatedAt = new DateTime(2025, 02, 06) },
					new Review { ReviewID = 16, CustomerID = 1, EventID = 8, RatingValue = 5, CreatedAt = new DateTime(2025, 02, 11) },
					new Review { ReviewID = 17, CustomerID = 2, EventID = 8, RatingValue = 5, CreatedAt = new DateTime(2025, 02, 11) }
			);
		}
	}
}