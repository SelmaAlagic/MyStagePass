using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CustomerData
	{
		public static void SeedData(this EntityTypeBuilder<Customer> entity)
		{
			entity.HasData(
				new Customer { CustomerID = 1, UserID = 11 },
				new Customer { CustomerID = 2, UserID = 12 },
				new Customer { CustomerID = 3, UserID = 13 },
				new Customer { CustomerID = 4, UserID = 14 },
				new Customer { CustomerID = 5, UserID = 15 },
				new Customer { CustomerID = 6, UserID = 16 }
			);
		}
	}
}