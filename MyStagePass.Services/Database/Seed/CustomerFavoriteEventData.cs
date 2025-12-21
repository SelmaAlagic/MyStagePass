using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CustomerFavoriteEventData
	{
		public static void SeedData(this EntityTypeBuilder<CustomerFavoriteEvent> entity)
		{
			entity.HasData(
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 1, CustomerID = 1, EventID = 9 },  
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 2, CustomerID = 1, EventID = 14 }, 
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 3, CustomerID = 1, EventID = 19 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 4, CustomerID = 2, EventID = 12 }, 
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 5, CustomerID = 2, EventID = 17 }, 
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 6, CustomerID = 3, EventID = 13 }, 
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 7, CustomerID = 5, EventID = 11 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 8, CustomerID = 5, EventID = 20 }, 
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 9, CustomerID = 6, EventID = 18 } 
			);
		}
	}
}