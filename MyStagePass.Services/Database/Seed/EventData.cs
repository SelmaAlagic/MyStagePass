using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class EventData
	{
		public static void SeedData(this EntityTypeBuilder<Event> entity)
		{
			entity.HasData(
				new Event
				{
					EventID = 1,
					EventName = "Rock Concert",
					Description = "Rock Concert 2025",
					TotalTickets = 15000,
					TicketsSold = 200,
					RegularPrice=30,
					VipPrice=40,
					PremiumPrice=50,
					PerformerID = 1,
					EventDate = new DateTime(2025, 11, 15, 18, 0, 0), // 15.11.2025 u 18:00
					LocationID = 1,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0
				},
				new Event
				{
					EventID = 2,
					EventName = "Jazz Night",
					Description = "Jazz Night 2525",
					TotalTickets = 15000,
					TicketsSold = 370,
					RegularPrice=25,
					VipPrice=30,
					PremiumPrice=50,
					PerformerID = 2,
					EventDate = new DateTime(2025, 11, 15, 21, 0, 0), // 15.11.2025 u 21:00
					LocationID = 1,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0
				},
				new Event
				{
					EventID = 3,
					EventName = "Pop Festival",
					Description = "Outdoor pop music festival",
					TotalTickets = 12000,
					TicketsSold = 700,
					RegularPrice=25,
					VipPrice=30,
					PremiumPrice=50,
					PerformerID = 3,
					EventDate = new DateTime(2025, 12, 20, 18, 0, 0),
					LocationID = 3,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0
				},
				new Event
				{
					EventID = 4,
					EventName = "Classical Evening",
					Description = "Symphony orchestra live performance",
					TotalTickets = 8000,
					TicketsSold = 50,
					RegularPrice=25,
					VipPrice=30,
					PremiumPrice=50,
					PerformerID = 4,
					EventDate = new DateTime(2026, 1, 10, 19, 0, 0),
					LocationID = 4,
					StatusID = 3,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0
				}
			);
		}
	}
}