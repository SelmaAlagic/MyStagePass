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
					LocationID = 1,
					TicketsSold = 50,
					TicketsAvailable = 200,
					PerformerID = 1,
					EventDate = new DateTime(2025, 11, 15, 18, 0, 0), // 15.11.2025 u 18:00
					StatusID = 1
				},
				new Event
				{
					EventID = 2,
					EventName = "Jazz Night",
					LocationID = 1,
					TicketsSold = 30,
					TicketsAvailable = 100,
					PerformerID = 2,
					EventDate = new DateTime(2025, 11, 15, 21, 0, 0), // 15.11.2025 u 21:00
					StatusID = 1
				},
				new Event
				{
					EventID = 3,
					EventName = "Pop Festival",
					Description = "Outdoor pop music festival",
					TicketsSold = 300,
					TicketsAvailable = 1000,
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
					TicketsSold = 50,
					TicketsAvailable = 150,
					PerformerID = 4,
					EventDate = new DateTime(2026, 1, 10, 19, 0, 0),
					LocationID = 4,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0
				}
			);
		}
	}
}