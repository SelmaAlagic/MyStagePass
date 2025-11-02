using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class TicketData
	{
		public static void SeedData(this EntityTypeBuilder<Ticket> entity)
		{
			entity.HasData(
				// kupovina 1
				new Ticket { TicketID = 1, EventID = 1, TicketTypeID = 1, PurchaseID = 1, Price = 50 },
				new Ticket { TicketID = 2, EventID = 2, TicketTypeID = 2, PurchaseID = 1, Price = 30 },

				// kupovina 2
				new Ticket { TicketID = 3, EventID = 3, TicketTypeID = 1, PurchaseID = 2, Price = 60 },
				new Ticket { TicketID = 4, EventID = 1, TicketTypeID = 3, PurchaseID = 2, Price = 40 }
			);
		}
	}
}
