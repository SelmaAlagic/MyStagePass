using Microsoft.EntityFrameworkCore.Metadata.Builders;
namespace MyStagePass.Services.Database.Seed
{
	public static class PurchaseData
	{
		public static void SeedData(this EntityTypeBuilder<Purchase> entity)
		{
			entity.HasData(
				new Purchase { PurchaseID = 1, CustomerID = 1, PurchaseDate = new DateTime(2025, 2, 1, 10, 0, 0) },
				new Purchase { PurchaseID = 2, CustomerID = 1, PurchaseDate = new DateTime(2025, 11, 20, 10, 0, 0) },
				new Purchase { PurchaseID = 3, CustomerID = 1, PurchaseDate = new DateTime(2025, 10, 20, 10, 0, 0) },
				new Purchase { PurchaseID = 4, CustomerID = 1, PurchaseDate = new DateTime(2026, 3, 1, 12, 0, 0) },
				new Purchase { PurchaseID = 5, CustomerID = 1, PurchaseDate = new DateTime(2025, 12, 5, 14, 30, 0) },
				new Purchase { PurchaseID = 6, CustomerID = 1, PurchaseDate = new DateTime(2025, 7, 10, 9, 15, 0) },
				new Purchase { PurchaseID = 7, CustomerID = 2, PurchaseDate = new DateTime(2025, 12, 10, 11, 30, 0) },
				new Purchase { PurchaseID = 8, CustomerID = 2, PurchaseDate = new DateTime(2025, 10, 20, 15, 45, 0) },
				new Purchase { PurchaseID = 9, CustomerID = 2, PurchaseDate = new DateTime(2025, 12, 1, 10, 0, 0) },
				new Purchase { PurchaseID = 10, CustomerID = 2, PurchaseDate = new DateTime(2025, 8, 1, 11, 45, 0) },
				new Purchase { PurchaseID = 11, CustomerID = 3, PurchaseDate = new DateTime(2025, 11, 25, 14, 20, 0) },
				new Purchase { PurchaseID = 12, CustomerID = 3, PurchaseDate = new DateTime(2025, 11, 25, 9, 30, 0) },
				new Purchase { PurchaseID = 13, CustomerID = 3, PurchaseDate = new DateTime(2026, 3, 11, 16, 20, 0) },
				new Purchase { PurchaseID = 14, CustomerID = 5, PurchaseDate = new DateTime(2025, 12, 15, 13, 10, 0) },
				new Purchase { PurchaseID = 15, CustomerID = 5, PurchaseDate = new DateTime(2026, 1, 30, 12, 0, 0) },
				new Purchase { PurchaseID = 16, CustomerID = 5, PurchaseDate = new DateTime(2025, 5, 12, 15, 10, 0) },
				new Purchase { PurchaseID = 17, CustomerID = 6, PurchaseDate = new DateTime(2025, 12, 5, 16, 0, 0) },
				new Purchase { PurchaseID = 18, CustomerID = 6, PurchaseDate = new DateTime(2025, 12, 10, 18, 0, 0) },
				new Purchase { PurchaseID = 19, CustomerID = 1, PurchaseDate = new DateTime(2025, 3, 1, 10, 0, 0) },  
				new Purchase { PurchaseID = 20, CustomerID = 2, PurchaseDate = new DateTime(2025, 3, 5, 11, 0, 0) },  
				new Purchase { PurchaseID = 21, CustomerID = 3, PurchaseDate = new DateTime(2025, 3, 10, 12, 0, 0) }, 
				new Purchase { PurchaseID = 22, CustomerID = 4, PurchaseDate = new DateTime(2024, 6, 1, 10, 0, 0) },  
				new Purchase { PurchaseID = 23, CustomerID = 5, PurchaseDate = new DateTime(2024, 6, 5, 14, 0, 0) },  
				new Purchase { PurchaseID = 24, CustomerID = 6, PurchaseDate = new DateTime(2024, 6, 10, 9, 0, 0) },
				new Purchase { PurchaseID = 25, CustomerID = 1, PurchaseDate = new DateTime(2025, 4, 1, 10, 0, 0) },
				new Purchase { PurchaseID = 26, CustomerID = 2, PurchaseDate = new DateTime(2025, 4, 2, 11, 0, 0) });
		}
	}
}