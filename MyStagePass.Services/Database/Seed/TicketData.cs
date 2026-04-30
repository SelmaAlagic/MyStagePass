using Microsoft.EntityFrameworkCore.Metadata.Builders;
namespace MyStagePass.Services.Database.Seed
{
	public static class TicketData
	{
		public static void SeedData(this EntityTypeBuilder<Ticket> entity)
		{
			entity.HasData(
				new Ticket { TicketID = 1, EventID = 1, TicketType = TicketType.Regular, PurchaseID = 1, Price = 25 },
				new Ticket { TicketID = 2, EventID = 1, TicketType = TicketType.Regular, PurchaseID = 1, Price = 25 },
				new Ticket { TicketID = 3, EventID = 13, TicketType = TicketType.Regular, PurchaseID = 2, Price = 30 },
				new Ticket { TicketID = 4, EventID = 21, TicketType = TicketType.Vip, PurchaseID = 3, Price = 75 },
				new Ticket { TicketID = 5, EventID = 21, TicketType = TicketType.Regular, PurchaseID = 3, Price = 30 },
				new Ticket { TicketID = 6, EventID = 12, TicketType = TicketType.Regular, PurchaseID = 4, Price = 45 },
				new Ticket { TicketID = 7, EventID = 12, TicketType = TicketType.Regular, PurchaseID = 4, Price = 45 },
				new Ticket { TicketID = 8, EventID = 13, TicketType = TicketType.Premium, PurchaseID = 5, Price = 130 },
				new Ticket { TicketID = 9, EventID = 13, TicketType = TicketType.Regular, PurchaseID = 5, Price = 30 },
				new Ticket { TicketID = 10, EventID = 14, TicketType = TicketType.Vip, PurchaseID = 6, Price = 60 },
				new Ticket { TicketID = 11, EventID = 14, TicketType = TicketType.Vip, PurchaseID = 6, Price = 60 },
				new Ticket { TicketID = 12, EventID = 14, TicketType = TicketType.Regular, PurchaseID = 6, Price = 25 },
				new Ticket { TicketID = 13, EventID = 17, TicketType = TicketType.Vip, PurchaseID = 7, Price = 100 },
				new Ticket { TicketID = 14, EventID = 21, TicketType = TicketType.Regular, PurchaseID = 8, Price = 30 },
				new Ticket { TicketID = 15, EventID = 21, TicketType = TicketType.Regular, PurchaseID = 8, Price = 30 },
				new Ticket { TicketID = 16, EventID = 1, TicketType = TicketType.Regular, PurchaseID = 9, Price = 25 },
				new Ticket { TicketID = 17, EventID = 14, TicketType = TicketType.Vip, PurchaseID = 10, Price = 60 },
				new Ticket { TicketID = 18, EventID = 14, TicketType = TicketType.Regular, PurchaseID = 10, Price = 25 },
				new Ticket { TicketID = 19, EventID = 13, TicketType = TicketType.Premium, PurchaseID = 11, Price = 130 },
				new Ticket { TicketID = 20, EventID = 13, TicketType = TicketType.Premium, PurchaseID = 11, Price = 130 },
				new Ticket { TicketID = 21, EventID = 14, TicketType = TicketType.Regular, PurchaseID = 12, Price = 25 },
				new Ticket { TicketID = 22, EventID = 12, TicketType = TicketType.Regular, PurchaseID = 13, Price = 45 },
				new Ticket { TicketID = 23, EventID = 12, TicketType = TicketType.Regular, PurchaseID = 13, Price = 45 },
				new Ticket { TicketID = 24, EventID = 17, TicketType = TicketType.Vip, PurchaseID = 14, Price = 100 },
				new Ticket { TicketID = 25, EventID = 17, TicketType = TicketType.Vip, PurchaseID = 14, Price = 100 },
				new Ticket { TicketID = 26, EventID = 21, TicketType = TicketType.Regular, PurchaseID = 15, Price = 30 },
				new Ticket { TicketID = 27, EventID = 1, TicketType = TicketType.Regular, PurchaseID = 16, Price = 25 },
				new Ticket { TicketID = 28, EventID = 1, TicketType = TicketType.Regular, PurchaseID = 16, Price = 25 },
				new Ticket { TicketID = 29, EventID = 13, TicketType = TicketType.Regular, PurchaseID = 17, Price = 30 },
				new Ticket { TicketID = 30, EventID = 17, TicketType = TicketType.Vip, PurchaseID = 18, Price = 100 },
				new Ticket { TicketID = 31, EventID = 9, TicketType = TicketType.Regular, PurchaseID = 19, Price = 25 },
				new Ticket { TicketID = 32, EventID = 9, TicketType = TicketType.Regular, PurchaseID = 20, Price = 25 },
				new Ticket { TicketID = 33, EventID = 9, TicketType = TicketType.Regular, PurchaseID = 21, Price = 25 },
				new Ticket { TicketID = 34, EventID = 20, TicketType = TicketType.Regular, PurchaseID = 22, Price = 35 },
				new Ticket { TicketID = 35, EventID = 20, TicketType = TicketType.Regular, PurchaseID = 23, Price = 35 },
				new Ticket { TicketID = 36, EventID = 20, TicketType = TicketType.Regular, PurchaseID = 24, Price = 35 },
				new Ticket { TicketID = 37, EventID = 15, TicketType = TicketType.Regular, PurchaseID = 25, Price = 20 },
				new Ticket { TicketID = 38, EventID = 15, TicketType = TicketType.Regular, PurchaseID = 26, Price = 20 }
			);
		}
	}
}