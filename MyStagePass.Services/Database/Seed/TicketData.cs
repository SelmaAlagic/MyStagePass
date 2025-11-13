using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class TicketData
	{
		public static void SeedData(this EntityTypeBuilder<Ticket> entity)
		{
			entity.HasData(
				// kupovina 1
				new Ticket { TicketID = 1, EventID = 1, TicketType=Event.TicketType.Vip, PurchaseID = 1, Price = 40 },
				new Ticket { TicketID = 2, EventID = 1, TicketType=Event.TicketType.Vip, PurchaseID = 1, Price = 40 },

				// kupovina 2
				new Ticket { TicketID = 3, EventID = 3, TicketType = Event.TicketType.Regular, PurchaseID = 2, Price = 25 },
				new Ticket { TicketID = 4, EventID = 3, TicketType = Event.TicketType.Regular, PurchaseID = 2, Price = 25 }
			);
		}
	}
}
