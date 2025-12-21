using Microsoft.EntityFrameworkCore;
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
					EventName = "Retro Night Spectacle",
					Description = "A journey back to the golden era of music with timeless hits and spectacular production.",
					TotalTickets = 18000,
					TicketsSold = 18000,
					RegularPrice = 30,
					VipPrice = 60,
					PremiumPrice = 100,
					PerformerID = 6,
					EventDate = new DateTime(2024, 10, 10, 20, 0, 0),
					LocationID = 13,
					StatusID = 2,
					TotalScore = 480,
					RatingCount = 100,
					RatingAverage = 4.8f
				},
				new Event
				{
					EventID = 2,
					EventName = "Heartbeat Tour",
					Description = "An emotional live experience featuring the most beautiful ballads of the decade.",
					TotalTickets = 12000,
					TicketsSold = 12000,
					RegularPrice = 35,
					VipPrice = 70,
					PremiumPrice = 120,
					PerformerID = 4,
					EventDate = new DateTime(2024, 11, 05, 21, 0, 0),
					LocationID = 7,
					StatusID = 2,
					TotalScore = 490,
					RatingCount = 100,
					RatingAverage = 4.9f
				},
				new Event
				{
					EventID = 3,
					EventName = "Acoustic Unplugged Night",
					Description = "An intimate atmosphere showcasing raw emotions through special acoustic arrangements.",
					TotalTickets = 7000,
					TicketsSold = 6500,
					RegularPrice = 40,
					VipPrice = 80,
					PremiumPrice = 150,
					PerformerID = 5,
					EventDate = new DateTime(2024, 11, 25, 20, 30, 0),
					LocationID = 18,
					StatusID = 2,
					TotalScore = 450,
					RatingCount = 100,
					RatingAverage = 4.5f
				},
				new Event
				{
					EventID = 4,
					EventName = "Winter Club Party",
					Description = "The hottest winter night featuring top-tier rhythms and a clubbing atmosphere to remember.",
					TotalTickets = 5000,
					TicketsSold = 5000,
					RegularPrice = 25,
					VipPrice = 50,
					PremiumPrice = 90,
					PerformerID = 9,
					EventDate = new DateTime(2024, 12, 20, 23, 0, 0),
					LocationID = 23,
					StatusID = 2,
					TotalScore = 420,
					RatingCount = 100,
					RatingAverage = 4.2f
				},
				new Event
				{
					EventID = 5,
					EventName = "New Year's Eve Gala",
					Description = "A glamorous New Year's celebration with an exclusive musical program and premium entertainment.",
					TotalTickets = 4000,
					TicketsSold = 4000,
					RegularPrice = 50,
					VipPrice = 100,
					PremiumPrice = 150,
					PerformerID = 2,
					EventDate = new DateTime(2024, 12, 31, 22, 0, 0),
					LocationID = 6,
					StatusID = 2,
					TotalScore = 470,
					RatingCount = 100,
					RatingAverage = 4.7f
				},
				new Event
				{
					EventID = 6,
					EventName = "The Power of Voice",
					Description = "Vocal domination and energy that pushes the boundaries of modern pop music.",
					TotalTickets = 5000,
					TicketsSold = 4200,
					RegularPrice = 20,
					VipPrice = 40,
					PremiumPrice = 80,
					PerformerID = 3,
					EventDate = new DateTime(2025, 01, 10, 20, 0, 0),
					LocationID = 2,
					StatusID = 2,
					TotalScore = 460,
					RatingCount = 100,
					RatingAverage = 4.6f
				},
				new Event
				{
					EventID = 7,
					EventName = "Valentine's Warmup",
					Description = "The perfect prelude to the holiday of love featuring the most romantic local melodies.",
					TotalTickets = 5000,
					TicketsSold = 5000,
					RegularPrice = 25,
					VipPrice = 50,
					PremiumPrice = 90,
					PerformerID = 8,
					EventDate = new DateTime(2025, 02, 05, 21, 0, 0),
					LocationID = 12,
					StatusID = 2,
					TotalScore = 480,
					RatingCount = 100,
					RatingAverage = 4.8f
				},
				new Event
				{
					EventID = 8,
					EventName = "The Arena Experience",
					Description = "An audio-visual spectacle in the largest arena that will leave you breathless.",
					TotalTickets = 16000,
					TicketsSold = 16000,
					RegularPrice = 35,
					VipPrice = 75,
					PremiumPrice = 130,
					PerformerID = 9,
					EventDate = new DateTime(2025, 02, 10, 20, 0, 0),
					LocationID = 8,
					StatusID = 2,
					TotalScore = 500,
					RatingCount = 100,
					RatingAverage = 5.0f
				},
				new Event
				{
					EventID = 9,
					EventName = "Valentine's Live Special",
					Description = "A special concert evening dedicated to love in the heart of Sarajevo.",
					TotalTickets = 15000,
					TicketsSold = 8000,
					RegularPrice = 25,
					VipPrice = 50,
					PremiumPrice = 90,
					PerformerID = 7,
					EventDate = new DateTime(2025, 02, 14, 20, 0, 0),
					LocationID = 1,
					StatusID = 2,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 10,
					EventName = "Canceled Pop Show",
					Description = "A major pop concert designed to be the highlight of the winter tour season.",
					TotalTickets = 3000,
					TicketsSold = 0,
					RegularPrice = 20,
					VipPrice = 40,
					PremiumPrice = 70,
					PerformerID = 2,
					EventDate = new DateTime(2025, 02, 22, 22, 0, 0),
					LocationID = 26,
					StatusID = 3,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 11,
					EventName = "Women's Day Spectacle",
					Description = "A traditional concert dedicated to all ladies with flowers, emotions, and songs.",
					TotalTickets = 6200,
					TicketsSold = 2500,
					RegularPrice = 20,
					VipPrice = 40,
					PremiumPrice = 80,
					PerformerID = 3,
					EventDate = new DateTime(2025, 03, 08, 20, 0, 0),
					LocationID = 14,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 12,
					EventName = "Spring Live Tour",
					Description = "Awakening of spring with new energy and the premiere of upcoming singles.",
					TotalTickets = 8000,
					TicketsSold = 3100,
					RegularPrice = 20,
					VipPrice = 45,
					PremiumPrice = 85,
					PerformerID = 8,
					EventDate = new DateTime(2025, 03, 15, 21, 0, 0),
					LocationID = 4,
					StatusID = 2,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 13,
					EventName = "Sava Center Exclusive",
					Description = "An exclusive night in a prestigious setting with top-tier musicians and surprise guests.",
					TotalTickets = 4000,
					TicketsSold = 3800,
					RegularPrice = 45,
					VipPrice = 90,
					PremiumPrice = 160,
					PerformerID = 4,
					EventDate = new DateTime(2025, 03, 28, 20, 0, 0),
					LocationID = 27,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 14,
					EventName = "Vocal Magic Live",
					Description = "Vocal magic that captures hearts across the region as part of a major tour.",
					TotalTickets = 11000,
					TicketsSold = 5000,
					RegularPrice = 30,
					VipPrice = 60,
					PremiumPrice = 110,
					PerformerID = 9,
					EventDate = new DateTime(2025, 04, 05, 20, 0, 0),
					LocationID = 28,
					StatusID = 2,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 15,
					EventName = "Pop Rock Evening",
					Description = "A fusion of powerful sounds and pop melodies in a legendary sports arena.",
					TotalTickets = 5000,
					TicketsSold = 1500,
					RegularPrice = 30,
					VipPrice = 60,
					PremiumPrice = 100,
					PerformerID = 5,
					EventDate = new DateTime(2025, 04, 12, 20, 30, 0),
					LocationID = 2,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 16,
					EventName = "Rejected Summer Fest",
					Description = "An outdoor summer festival planned to gather thousands of music lovers.",
					TotalTickets = 3000,
					TicketsSold = 0,
					RegularPrice = 25,
					VipPrice = 50,
					PremiumPrice = 90,
					PerformerID = 9,
					EventDate = new DateTime(2025, 04, 25, 22, 0, 0),
					LocationID = 26,
					StatusID = 3,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 17,
					EventName = "Stadium Open Air",
					Description = "A grand concert under the stars in a massive stadium setting.",
					TotalTickets = 9000,
					TicketsSold = 4500,
					RegularPrice = 20,
					VipPrice = 45,
					PremiumPrice = 80,
					PerformerID = 7,
					EventDate = new DateTime(2025, 05, 10, 21, 0, 0),
					LocationID = 15,
					StatusID = 2,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 18,
					EventName = "Kastel Fortress Spectacle",
					Description = "A night to remember at the ancient fortress with premium sound and light shows.",
					TotalTickets = 10000,
					TicketsSold = 3000,
					RegularPrice = 25,
					VipPrice = 50,
					PremiumPrice = 95,
					PerformerID = 6,
					EventDate = new DateTime(2025, 05, 17, 21, 0, 0),
					LocationID = 11,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 19,
					EventName = "Zetra Hall Live",
					Description = "The biggest concert of the artist's career in the legendary Olympic hall.",
					TotalTickets = 12000,
					TicketsSold = 5200,
					RegularPrice = 25,
					VipPrice = 55,
					PremiumPrice = 100,
					PerformerID = 2,
					EventDate = new DateTime(2025, 05, 24, 20, 30, 0),
					LocationID = 3,
					StatusID = 2,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				},
				new Event
				{
					EventID = 20,
					EventName = "Balkan Spring Festival",
					Description = "Closing the spring season with a massive festival lineup at the fortress.",
					TotalTickets = 40000,
					TicketsSold = 12000,
					RegularPrice = 40,
					VipPrice = 100,
					PremiumPrice = 200,
					PerformerID = 8,
					EventDate = new DateTime(2025, 05, 31, 19, 0, 0),
					LocationID = 29,
					StatusID = 1,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f
				}
			);
		}
	}
}