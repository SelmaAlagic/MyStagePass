using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class PurchaseData
	{
		public static void SeedData(this EntityTypeBuilder<Purchase> entity)
		{
			entity.HasData(
			   new Purchase { PurchaseID = 1, CustomerID = 1, PurchaseDate = new DateTime(2025, 10, 27, 12, 0, 0) },
			   new Purchase { PurchaseID = 2, CustomerID = 2, PurchaseDate = new DateTime(2025, 10, 28, 15, 30, 0) }
			);
		}
	}
}