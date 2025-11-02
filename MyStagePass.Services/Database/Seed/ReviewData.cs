using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class ReviewData
	{
		public static void SeedData(this EntityTypeBuilder<Review> entity)
		{
			entity.HasData(
				new Review
				{
					ReviewID = 1,
					CustomerID = 1,
					EventID = 1,
					RatingValue = 5,
					CreatedAt = new DateTime(2025, 10, 01)
				},
				new Review
				{
					ReviewID = 2,
					CustomerID = 1,
					EventID = 2,
					RatingValue = 4,
					CreatedAt = new DateTime(2025, 10, 03)
				},
				new Review
				{
					ReviewID = 3,
					CustomerID = 2,
					EventID = 1,
					RatingValue = 3,
					CreatedAt = new DateTime(2025, 10, 05)
				},
				new Review
				{
					ReviewID = 4,
					CustomerID = 2,
					EventID = 3,
					RatingValue = 5,
					CreatedAt = new DateTime(2025, 10, 07)
				},
				new Review
				{
					ReviewID = 5,
					CustomerID = 3,
					EventID = 2,
					RatingValue = 4,
					CreatedAt = new DateTime(2025, 10, 09)
				},
				new Review
				{
					ReviewID = 6,
					CustomerID = 3,
					EventID = 3,
					RatingValue = 2,
					CreatedAt = new DateTime(2025, 10, 11)
				}
			);
		}
	}
}
