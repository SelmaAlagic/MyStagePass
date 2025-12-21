using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class TicketData
	{
		public static void SeedData(this EntityTypeBuilder<Ticket> entity)
		{
			entity.HasData(
				new Ticket { TicketID = 1, EventID = 9, TicketType = Event.TicketType.Vip, PurchaseID = 1, Price = 50 },
				new Ticket { TicketID = 2, EventID = 9, TicketType = Event.TicketType.Vip, PurchaseID = 1, Price = 50 },
				new Ticket { TicketID = 3, EventID = 9, TicketType = Event.TicketType.Vip, PurchaseID = 1, Price = 50 },
				new Ticket { TicketID = 4, EventID = 14, TicketType = Event.TicketType.Premium, PurchaseID = 2, Price = 110 },
				new Ticket { TicketID = 5, EventID = 19, TicketType = Event.TicketType.Regular, PurchaseID = 3, Price = 25 },
				new Ticket { TicketID = 6, EventID = 19, TicketType = Event.TicketType.Regular, PurchaseID = 3, Price = 25 },
				new Ticket { TicketID = 7, EventID = 12, TicketType = Event.TicketType.Regular, PurchaseID = 4, Price = 20 },
				new Ticket { TicketID = 8, EventID = 12, TicketType = Event.TicketType.Regular, PurchaseID = 4, Price = 20 },
				new Ticket { TicketID = 9, EventID = 17, TicketType = Event.TicketType.Vip, PurchaseID = 5, Price = 45 },
				new Ticket { TicketID = 10, EventID = 13, TicketType = Event.TicketType.Premium, PurchaseID = 6, Price = 160 },
				new Ticket { TicketID = 11, EventID = 13, TicketType = Event.TicketType.Premium, PurchaseID = 6, Price = 160 },
				new Ticket { TicketID = 12, EventID = 11, TicketType = Event.TicketType.Regular, PurchaseID = 7, Price = 20 },
				new Ticket { TicketID = 13, EventID = 19, TicketType = Event.TicketType.Vip, PurchaseID = 8, Price = 55 },
				new Ticket { TicketID = 14, EventID = 19, TicketType = Event.TicketType.Vip, PurchaseID = 8, Price = 55 },
				new Ticket { TicketID = 15, EventID = 20, TicketType = Event.TicketType.Regular, PurchaseID = 9, Price = 40 },
				new Ticket { TicketID = 16, EventID = 20, TicketType = Event.TicketType.Regular, PurchaseID = 9, Price = 40 },
				new Ticket { TicketID = 17, EventID = 20, TicketType = Event.TicketType.Regular, PurchaseID = 9, Price = 40 }
			);
		}
	}
}