using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CustomerFavoriteEventData
	{
		public static void SeedData(this EntityTypeBuilder<CustomerFavoriteEvent> entity)
		{
			entity.HasData(
				new CustomerFavoriteEvent { CustomerFavoriteEventID=1, CustomerID = 1, EventID = 1 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID=2, CustomerID = 1, EventID = 2 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID=3, CustomerID = 2, EventID = 1 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID=4, CustomerID = 2, EventID = 3 }
			);
		}
	}
}
