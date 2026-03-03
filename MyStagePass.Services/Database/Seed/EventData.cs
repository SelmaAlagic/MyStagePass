using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class EventData
	{
		public static void SeedData(this EntityTypeBuilder<Event> entity)
		{
			entity.HasData(
				// ===== ILMA KARAHMET (PerformerID 2) - 3 events =====
				new Event
				{
					EventID = 1,
					EventName = "Ilma Karahmet - Debut Concert",
					Description = "First solo concert of the rising pop artist",
					EventDate = new DateTime(2026, 5, 10, 20, 0, 0), // upcoming
					StatusID = 2, // Approved
					TotalTickets = 5000,
					TicketsSold = 2100,
					RegularPrice = 25,
					VipPrice = 60,
					PremiumPrice = 100,
					PerformerID = 2,
					LocationID = 2,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2025, 1, 15, 14, 30, 0)
				},
				new Event
				{
					EventID = 2,
					EventName = "Ilma Karahmet - Tuzla Summer Fest",
					Description = "Summer performance at Tuzla Festival",
					EventDate = new DateTime(2024, 7, 22, 21, 0, 0), // past
					StatusID = 3,
					TotalTickets = 7000,
					TicketsSold = 5200,
					RegularPrice = 30,
					VipPrice = 70,
					PremiumPrice = 120,
					PerformerID = 2,
					LocationID = 5,
					TotalScore = 412,
					RatingCount = 89,
					RatingAverage = 4.63f,
					CreatedAt = new DateTime(2024, 3, 10, 11, 0, 0)
				},
				new Event
				{
					EventID = 3,
					EventName = "Ilma Karahmet - Acoustic Evening",
					Description = "Special concert in an intimate setting",
					EventDate = new DateTime(2026, 9, 5, 19, 30, 0), // upcoming
					StatusID = 1, // Pending
					TotalTickets = 3000,
					TicketsSold = 0,
					RegularPrice = 35,
					VipPrice = 80,
					PremiumPrice = 150,
					PerformerID = 2,
					LocationID = 12,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2025, 2, 5, 9, 15, 0)
				},

				// ===== TONI CETINSKI (PerformerID 4) - 5 events =====
				new Event
				{
					EventID = 4,
					EventName = "Toni Cetinski - Zagreb Arena",
					Description = "Spectacular concert celebrating 30 years of career",
					EventDate = new DateTime(2026, 11, 20, 20, 0, 0), // upcoming
					StatusID = 1, // Pending
					TotalTickets = 16000,
					TicketsSold = 0,
					RegularPrice = 40,
					VipPrice = 90,
					PremiumPrice = 180,
					PerformerID = 4,
					LocationID = 8,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2025, 2, 1, 10, 0, 0)
				},
				new Event
				{
					EventID = 5,
					EventName = "Toni Cetinski - Split Summer Nights",
					Description = "Summer open-air concert",
					EventDate = new DateTime(2024, 8, 5, 21, 0, 0), // past
					StatusID = 3,
					TotalTickets = 12000,
					TicketsSold = 11800,
					RegularPrice = 35,
					VipPrice = 80,
					PremiumPrice = 160,
					PerformerID = 4,
					LocationID = 7,
					TotalScore = 1100,
					RatingCount = 234,
					RatingAverage = 4.70f,
					CreatedAt = new DateTime(2024, 2, 20, 12, 0, 0)
				},
				new Event
				{
					EventID = 6,
					EventName = "Toni Cetinski - Sarajevo Winter",
					Description = "Romantic evening with the most beautiful ballads",
					EventDate = new DateTime(2025, 2, 14, 20, 0, 0), // past
					StatusID = 3,
					TotalTickets = 15000,
					TicketsSold = 14300,
					RegularPrice = 35,
					VipPrice = 80,
					PremiumPrice = 160,
					PerformerID = 4,
					LocationID = 1,
					TotalScore = 865,
					RatingCount = 187,
					RatingAverage = 4.62f,
					CreatedAt = new DateTime(2024, 9, 1, 15, 30, 0)
				},
				new Event
				{
					EventID = 7,
					EventName = "Toni Cetinski - Mostar Bridge Concert",
					Description = "Unique concert near the Old Bridge",
					EventDate = new DateTime(2024, 9, 15, 20, 30, 0), // past
					StatusID = 2,
					TotalTickets = 9000,
					TicketsSold = 8900,
					RegularPrice = 30,
					VipPrice = 75,
					PremiumPrice = 140,
					PerformerID = 4,
					LocationID = 15,
					TotalScore = 756,
					RatingCount = 168,
					RatingAverage = 4.50f,
					CreatedAt = new DateTime(2024, 4, 10, 9, 45, 0)
				},
				new Event
				{
					EventID = 8,
					EventName = "Toni Cetinski - Banja Luka Special",
					Description = "Greatest hits concert",
					EventDate = new DateTime(2026, 4, 18, 20, 0, 0), // upcoming
					StatusID = 2, // Approved
					TotalTickets = 8000,
					TicketsSold = 3250,
					RegularPrice = 30,
					VipPrice = 75,
					PremiumPrice = 140,
					PerformerID = 4,
					LocationID = 4,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2024, 12, 5, 11, 20, 0)
				},

				// ===== ZELJKO SAMARDZIC (PerformerID 5) - 4 events =====
				new Event
				{
					EventID = 9,
					EventName = "Zeljko Samardzic - Belgrade Classics",
					Description = "Evening of greatest folk-pop hits",
					EventDate = new DateTime(2024, 10, 12, 20, 0, 0), // past
					StatusID = 3,
					TotalTickets = 18000,
					TicketsSold = 17600,
					RegularPrice = 25,
					VipPrice = 60,
					PremiumPrice = 120,
					PerformerID = 5,
					LocationID = 10,
					TotalScore = 1420,
					RatingCount = 312,
					RatingAverage = 4.55f,
					CreatedAt = new DateTime(2024, 5, 15, 13, 0, 0)
				},
				new Event
				{
					EventID = 10,
					EventName = "Zeljko Samardzic - Sarajevo Ballads",
					Description = "Love songs and romantic ballads",
					EventDate = new DateTime(2025, 3, 8, 20, 0, 0), // past
					StatusID = 2,
					TotalTickets = 12000,
					TicketsSold = 10900,
					RegularPrice = 25,
					VipPrice = 60,
					PremiumPrice = 120,
					PerformerID = 5,
					LocationID = 3,
					TotalScore = 712,
					RatingCount = 156,
					RatingAverage = 4.56f,
					CreatedAt = new DateTime(2024, 8, 20, 10, 30, 0)
				},
				new Event
				{
					EventID = 11,
					EventName = "Zeljko Samardzic - Zenica Live",
					Description = "Intimate acoustic concert",
					EventDate = new DateTime(2026, 7, 30, 21, 0, 0), // upcoming
					StatusID = 1, // Pending
					TotalTickets = 6200,
					TicketsSold = 0,
					RegularPrice = 20,
					VipPrice = 50,
					PremiumPrice = 100,
					PerformerID = 5,
					LocationID = 14,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2025, 1, 25, 16, 15, 0)
				},
				new Event
				{
					EventID = 12,
					EventName = "Zeljko Samardzic - Novi Sad Festival",
					Description = "Special guest at EXIT Festival",
					EventDate = new DateTime(2024, 7, 7, 23, 0, 0), // past
					StatusID = 3,
					TotalTickets = 40000,
					TicketsSold = 35000,
					RegularPrice = 45,
					VipPrice = 120,
					PremiumPrice = 250,
					PerformerID = 5,
					LocationID = 29,
					TotalScore = 1290,
					RatingCount = 278,
					RatingAverage = 4.64f,
					CreatedAt = new DateTime(2024, 2, 28, 14, 0, 0)
				},

				// ===== ADI SOSE (PerformerID 6) - 2 events =====
				new Event
				{
					EventID = 13,
					EventName = "Adi Sose - Jazz Night",
					Description = "Evening of jazz and soul music",
					EventDate = new DateTime(2026, 6, 5, 21, 0, 0), // upcoming
					StatusID = 2, // Approved
					TotalTickets = 5000,
					TicketsSold = 1850,
					RegularPrice = 30,
					VipPrice = 70,
					PremiumPrice = 130,
					PerformerID = 6,
					LocationID = 2,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2024, 11, 10, 9, 0, 0)
				},
				new Event
				{
					EventID = 14,
					EventName = "Adi Sose - Akustik Session",
					Description = "Unique vocal performance with band",
					EventDate = new DateTime(2024, 11, 18, 20, 0, 0), // past
					StatusID = 3,
					TotalTickets = 3000,
					TicketsSold = 2800,
					RegularPrice = 25,
					VipPrice = 60,
					PremiumPrice = 110,
					PerformerID = 6,
					LocationID = 26,
					TotalScore = 315,
					RatingCount = 67,
					RatingAverage = 4.70f,
					CreatedAt = new DateTime(2024, 6, 15, 12, 30, 0)
				},

				// ===== MIRZA SELIMOVIC (PerformerID 7) - 3 events =====
				new Event
				{
					EventID = 15,
					EventName = "Mirza Selimovic - Folk Spectacle",
					Description = "Traditional folk music night",
					EventDate = new DateTime(2024, 9, 28, 20, 0, 0), // past
					StatusID = 3,
					TotalTickets = 10000,
					TicketsSold = 8200,
					RegularPrice = 20,
					VipPrice = 50,
					PremiumPrice = 100,
					PerformerID = 7,
					LocationID = 11,
					TotalScore = 665,
					RatingCount = 145,
					RatingAverage = 4.59f,
					CreatedAt = new DateTime(2024, 4, 5, 10, 45, 0)
				},
				new Event
				{
					EventID = 16,
					EventName = "Mirza Selimovic - Bihac Summer",
					Description = "Summer concert in Una National Park",
					EventDate = new DateTime(2026, 8, 20, 20, 30, 0), // upcoming
					StatusID = 1, // Pending
					TotalTickets = 3000,
					TicketsSold = 0,
					RegularPrice = 25,
					VipPrice = 60,
					PremiumPrice = 120,
					PerformerID = 7,
					LocationID = 16,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2025, 2, 18, 8, 30, 0)
				},
				new Event
				{
					EventID = 17,
					EventName = "Mirza Selimovic - New Year's Eve",
					Description = "New Year celebration in Podgorica",
					EventDate = new DateTime(2024, 12, 31, 22, 0, 0), // past
					StatusID = 2,
					TotalTickets = 9000,
					TicketsSold = 6750,
					RegularPrice = 40,
					VipPrice = 100,
					PremiumPrice = 200,
					PerformerID = 7,
					LocationID = 9,
					TotalScore = 580,
					RatingCount = 125,
					RatingAverage = 4.64f,
					CreatedAt = new DateTime(2024, 7, 1, 11, 0, 0)
				},

				// ===== PRLJAVO KAZALISTE (PerformerID 9) - 4 events =====
				new Event
				{
					EventID = 18,
					EventName = "Prljavo Kazaliste - 40 Years Anniversary",
					Description = "Jubilee concert with special guests",
					EventDate = new DateTime(2026, 10, 5, 20, 0, 0), // upcoming
					StatusID = 1, // Pending
					TotalTickets = 16000,
					TicketsSold = 0,
					RegularPrice = 35,
					VipPrice = 85,
					PremiumPrice = 170,
					PerformerID = 9,
					LocationID = 8,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2025, 1, 30, 13, 20, 0)
				},
				new Event
				{
					EventID = 19,
					EventName = "Prljavo Kazaliste - Sarajevo Rock Night",
					Description = "Rock classics and new hits",
					EventDate = new DateTime(2024, 11, 15, 21, 0, 0), // past
					StatusID = 3,
					TotalTickets = 12000,
					TicketsSold = 11000,
					RegularPrice = 30,
					VipPrice = 75,
					PremiumPrice = 150,
					PerformerID = 9,
					LocationID = 3,
					TotalScore = 935,
					RatingCount = 203,
					RatingAverage = 4.60f,
					CreatedAt = new DateTime(2024, 6, 10, 9, 45, 0)
				},
				new Event
				{
					EventID = 20,
					EventName = "Prljavo Kazaliste - Split Open Air",
					Description = "Summer rock concert at Poljud",
					EventDate = new DateTime(2024, 8, 25, 21, 0, 0), // past
					StatusID = 3,
					TotalTickets = 34000,
					TicketsSold = 29800,
					RegularPrice = 35,
					VipPrice = 90,
					PremiumPrice = 180,
					PerformerID = 9,
					LocationID = 19,
					TotalScore = 1220,
					RatingCount = 267,
					RatingAverage = 4.57f,
					CreatedAt = new DateTime(2024, 3, 15, 15, 30, 0)
				},
				new Event
				{
					EventID = 21,
					EventName = "Prljavo Kazaliste - Mostar Rock Fest",
					Description = "Headliner at Mostar Rock Festival",
					EventDate = new DateTime(2026, 7, 12, 22, 0, 0), // upcoming
					StatusID = 2, // Approved
					TotalTickets = 9000,
					TicketsSold = 4300,
					RegularPrice = 30,
					VipPrice = 75,
					PremiumPrice = 150,
					PerformerID = 9,
					LocationID = 15,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2024, 10, 5, 10, 0, 0)
				},

				// ===== BALKAN SPRING FESTIVAL =====
				new Event
				{
					EventID = 22,
					EventName = "Balkan Spring Festival",
					Description = "Closing the spring season with a massive festival lineup at the fortress.",
					EventDate = new DateTime(2026, 5, 31, 19, 0, 0), // upcoming
					StatusID = 1, // Pending
					TotalTickets = 40000,
					TicketsSold = 12000,
					RegularPrice = 40,
					VipPrice = 100,
					PremiumPrice = 200,
					PerformerID = 8,
					LocationID = 29,
					TotalScore = 0,
					RatingCount = 0,
					RatingAverage = 0f,
					CreatedAt = new DateTime(2025, 4, 20, 10, 0, 0)
				}
			);
		}
	}
}