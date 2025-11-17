using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CustomerData
	{
		public static void SeedData(this EntityTypeBuilder<Customer> entity)
		{
			entity.HasData(
				new Customer { CustomerID = 1, UserID = 7 },
				new Customer { CustomerID = 2, UserID = 8 },
				new Customer { CustomerID = 3, UserID = 9 }
			);
		}
	}
}
