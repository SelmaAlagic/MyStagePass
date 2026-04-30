using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class CustomerFavoriteEventData
	{
		public static void SeedData(this EntityTypeBuilder<CustomerFavoriteEvent> entity)
		{
			entity.HasData(
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 1, CustomerID = 1, EventID = 14 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 2, CustomerID = 1, EventID = 21 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 3, CustomerID = 1, EventID = 12 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 4, CustomerID = 1, EventID = 13 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 5, CustomerID = 1, EventID = 17 },

				new CustomerFavoriteEvent { CustomerFavoriteEventID = 6, CustomerID = 2, EventID = 12 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 7, CustomerID = 2, EventID = 17 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 8, CustomerID = 2, EventID = 8 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 9, CustomerID = 2, EventID = 10 },

				new CustomerFavoriteEvent { CustomerFavoriteEventID = 10, CustomerID = 3, EventID = 13 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 11, CustomerID = 3, EventID = 14 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 12, CustomerID = 3, EventID = 1 },

				new CustomerFavoriteEvent { CustomerFavoriteEventID = 13, CustomerID = 4, EventID = 1 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 14, CustomerID = 4, EventID = 10 },

				new CustomerFavoriteEvent { CustomerFavoriteEventID = 15, CustomerID = 5, EventID = 21 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 16, CustomerID = 5, EventID = 12 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 17, CustomerID = 5, EventID = 8 },

				new CustomerFavoriteEvent { CustomerFavoriteEventID = 18, CustomerID = 6, EventID = 17 },
				new CustomerFavoriteEvent { CustomerFavoriteEventID = 19, CustomerID = 6, EventID = 14 }
			);
		}
	}
}