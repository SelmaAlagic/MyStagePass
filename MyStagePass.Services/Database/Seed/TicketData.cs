using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class TicketData
	{
		public static void SeedData(this EntityTypeBuilder<Ticket> entity)
		{
			entity.HasData(
				new Ticket { TicketID = 1, EventID = 9, TicketType = Event.TicketType.Vip, PurchaseID = 1, Price = 60 },
				new Ticket { TicketID = 2, EventID = 9, TicketType = Event.TicketType.Vip, PurchaseID = 1, Price = 60 },
				new Ticket { TicketID = 3, EventID = 9, TicketType = Event.TicketType.Vip, PurchaseID = 1, Price = 60 },
				new Ticket { TicketID = 4, EventID = 14, TicketType = Event.TicketType.Premium, PurchaseID = 2, Price = 110 },
				new Ticket { TicketID = 5, EventID = 19, TicketType = Event.TicketType.Regular, PurchaseID = 3, Price = 30 },
				new Ticket { TicketID = 6, EventID = 19, TicketType = Event.TicketType.Regular, PurchaseID = 3, Price = 30 },
				new Ticket { TicketID = 7, EventID = 5, TicketType = Event.TicketType.Regular, PurchaseID = 4, Price = 35 },
				new Ticket { TicketID = 8, EventID = 5, TicketType = Event.TicketType.Regular, PurchaseID = 4, Price = 35 },
				new Ticket { TicketID = 9, EventID = 21, TicketType = Event.TicketType.Regular, PurchaseID = 5, Price = 30 },
				new Ticket { TicketID = 10, EventID = 21, TicketType = Event.TicketType.Regular, PurchaseID = 5, Price = 30 },
				new Ticket { TicketID = 11, EventID = 21, TicketType = Event.TicketType.Regular, PurchaseID = 5, Price = 30 },
				new Ticket { TicketID = 12, EventID = 1, TicketType = Event.TicketType.Regular, PurchaseID = 6, Price = 25 },
				new Ticket { TicketID = 13, EventID = 1, TicketType = Event.TicketType.Regular, PurchaseID = 6, Price = 25 },
				new Ticket { TicketID = 14, EventID = 1, TicketType = Event.TicketType.Regular, PurchaseID = 6, Price = 25 },
				new Ticket { TicketID = 15, EventID = 1, TicketType = Event.TicketType.Regular, PurchaseID = 6, Price = 25 },
				new Ticket { TicketID = 16, EventID = 12, TicketType = Event.TicketType.Regular, PurchaseID = 7, Price = 45 },
				new Ticket { TicketID = 17, EventID = 12, TicketType = Event.TicketType.Regular, PurchaseID = 7, Price = 45 },
				new Ticket { TicketID = 18, EventID = 17, TicketType = Event.TicketType.Vip, PurchaseID = 8, Price = 100 },
				new Ticket { TicketID = 19, EventID = 17, TicketType = Event.TicketType.Vip, PurchaseID = 8, Price = 100 },
				new Ticket { TicketID = 20, EventID = 3, TicketType = Event.TicketType.Regular, PurchaseID = 9, Price = 35 },
				new Ticket { TicketID = 21, EventID = 3, TicketType = Event.TicketType.Regular, PurchaseID = 9, Price = 35 },
				new Ticket { TicketID = 22, EventID = 3, TicketType = Event.TicketType.Regular, PurchaseID = 9, Price = 35 },
				new Ticket { TicketID = 23, EventID = 8, TicketType = Event.TicketType.Regular, PurchaseID = 10, Price = 30 },
				new Ticket { TicketID = 24, EventID = 8, TicketType = Event.TicketType.Regular, PurchaseID = 10, Price = 30 },
				new Ticket { TicketID = 25, EventID = 13, TicketType = Event.TicketType.Premium, PurchaseID = 11, Price = 130 },
				new Ticket { TicketID = 26, EventID = 13, TicketType = Event.TicketType.Premium, PurchaseID = 11, Price = 130 },
				new Ticket { TicketID = 27, EventID = 2, TicketType = Event.TicketType.Regular, PurchaseID = 12, Price = 30 },
				new Ticket { TicketID = 28, EventID = 2, TicketType = Event.TicketType.Regular, PurchaseID = 12, Price = 30 },
				new Ticket { TicketID = 29, EventID = 2, TicketType = Event.TicketType.Regular, PurchaseID = 12, Price = 30 },
				new Ticket { TicketID = 30, EventID = 16, TicketType = Event.TicketType.Regular, PurchaseID = 13, Price = 25 },
				new Ticket { TicketID = 31, EventID = 16, TicketType = Event.TicketType.Regular, PurchaseID = 13, Price = 25 },
				new Ticket { TicketID = 32, EventID = 16, TicketType = Event.TicketType.Regular, PurchaseID = 13, Price = 25 },
				new Ticket { TicketID = 33, EventID = 16, TicketType = Event.TicketType.Regular, PurchaseID = 13, Price = 25 },
				new Ticket { TicketID = 34, EventID = 11, TicketType = Event.TicketType.Regular, PurchaseID = 14, Price = 20 },
				new Ticket { TicketID = 35, EventID = 11, TicketType = Event.TicketType.Regular, PurchaseID = 14, Price = 20 },
				new Ticket { TicketID = 36, EventID = 20, TicketType = Event.TicketType.Regular, PurchaseID = 15, Price = 35 },
				new Ticket { TicketID = 37, EventID = 20, TicketType = Event.TicketType.Regular, PurchaseID = 15, Price = 35 },
				new Ticket { TicketID = 38, EventID = 20, TicketType = Event.TicketType.Regular, PurchaseID = 15, Price = 35 },
				new Ticket { TicketID = 39, EventID = 6, TicketType = Event.TicketType.Regular, PurchaseID = 16, Price = 35 },
				new Ticket { TicketID = 40, EventID = 6, TicketType = Event.TicketType.Regular, PurchaseID = 16, Price = 35 },
				new Ticket { TicketID = 41, EventID = 18, TicketType = Event.TicketType.Regular, PurchaseID = 17, Price = 35 },
				new Ticket { TicketID = 42, EventID = 18, TicketType = Event.TicketType.Regular, PurchaseID = 17, Price = 35 },
				new Ticket { TicketID = 43, EventID = 18, TicketType = Event.TicketType.Regular, PurchaseID = 17, Price = 35 },
				new Ticket { TicketID = 44, EventID = 4, TicketType = Event.TicketType.Regular, PurchaseID = 18, Price = 40 },
				new Ticket { TicketID = 45, EventID = 4, TicketType = Event.TicketType.Regular, PurchaseID = 18, Price = 40 },
				new Ticket { TicketID = 46, EventID = 4, TicketType = Event.TicketType.Regular, PurchaseID = 18, Price = 40 },
				new Ticket { TicketID = 47, EventID = 4, TicketType = Event.TicketType.Regular, PurchaseID = 18, Price = 40 }
			);
		}
	}
}