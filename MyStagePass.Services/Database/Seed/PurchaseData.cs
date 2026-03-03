using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class PurchaseData
	{
		public static void SeedData(this EntityTypeBuilder<Purchase> entity)
		{
			entity.HasData(
				new Purchase { PurchaseID = 1, CustomerID = 1, PurchaseDate = new DateTime(2024, 10, 1, 10, 0, 0) },
				new Purchase { PurchaseID = 2, CustomerID = 1, PurchaseDate = new DateTime(2024, 11, 1, 10, 0, 0) },
				new Purchase { PurchaseID = 3, CustomerID = 1, PurchaseDate = new DateTime(2024, 12, 20, 10, 0, 0) },
				new Purchase { PurchaseID = 4, CustomerID = 1, PurchaseDate = new DateTime(2025, 2, 1, 12, 0, 0) },
				new Purchase { PurchaseID = 5, CustomerID = 1, PurchaseDate = new DateTime(2025, 2, 5, 14, 30, 0) },
				new Purchase { PurchaseID = 6, CustomerID = 1, PurchaseDate = new DateTime(2025, 2, 10, 09, 15, 0) },
				new Purchase { PurchaseID = 7, CustomerID = 2, PurchaseDate = new DateTime(2024, 9, 15, 11, 30, 0) },
				new Purchase { PurchaseID = 8, CustomerID = 2, PurchaseDate = new DateTime(2024, 11, 20, 15, 45, 0) },
				new Purchase { PurchaseID = 9, CustomerID = 2, PurchaseDate = new DateTime(2025, 1, 20, 10, 0, 0) },
				new Purchase { PurchaseID = 10, CustomerID = 2, PurchaseDate = new DateTime(2025, 2, 8, 11, 45, 0) },
				new Purchase { PurchaseID = 11, CustomerID = 3, PurchaseDate = new DateTime(2024, 10, 10, 14, 20, 0) },
				new Purchase { PurchaseID = 12, CustomerID = 3, PurchaseDate = new DateTime(2024, 12, 5, 9, 30, 0) },
				new Purchase { PurchaseID = 13, CustomerID = 3, PurchaseDate = new DateTime(2025, 2, 11, 16, 20, 0) },
				new Purchase { PurchaseID = 14, CustomerID = 5, PurchaseDate = new DateTime(2024, 12, 15, 13, 10, 0) },
				new Purchase { PurchaseID = 15, CustomerID = 5, PurchaseDate = new DateTime(2025, 1, 30, 12, 0, 0) },
				new Purchase { PurchaseID = 16, CustomerID = 5, PurchaseDate = new DateTime(2025, 2, 12, 15, 10, 0) },
				new Purchase { PurchaseID = 17, CustomerID = 6, PurchaseDate = new DateTime(2024, 11, 25, 16, 0, 0) },
				new Purchase { PurchaseID = 18, CustomerID = 6, PurchaseDate = new DateTime(2025, 2, 14, 18, 0, 0) }
			);
		}
	}
}