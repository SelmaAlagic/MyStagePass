
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class NotificationData
	{
		public static void SeedData(this EntityTypeBuilder<Notification> entity)
		{
			entity.HasData(
				new Notification { NotificationID = 1, UserID = 1, Title = "New Performer Registration", Message = "Performer Dzejla Ramovic has registered and is waiting for verification!", CreatedAt = new DateTime(2025, 3, 15, 9, 30, 0), isRead = false },
				new Notification { NotificationID = 2, UserID = 1, Title = "New Performer Registration", Message = "Performer Jelena Rozga has registered and is waiting for verification!", CreatedAt = new DateTime(2025, 3, 18, 11, 15, 0), isRead = false },
				new Notification { NotificationID = 3, UserID = 1, Title = "New Performer Registration", Message = "Performer Marija Serifovic has registered and is waiting for verification!", CreatedAt = new DateTime(2025, 3, 20, 14, 45, 0), isRead = true },
				new Notification { NotificationID = 4, UserID = 1, Title = "New Event Submitted", Message = "Ilma Karahmet submitted a new event for approval!", CreatedAt = new DateTime(2025, 3, 10, 16, 20, 0), isRead = true },
				new Notification { NotificationID = 5, UserID = 1, Title = "New Event Submitted", Message = "Toni Cetinski submitted a new event for approval!", CreatedAt = new DateTime(2025, 3, 5, 13, 10, 0), isRead = true },
				new Notification { NotificationID = 6, UserID = 1, Title = "New Event Submitted", Message = "Zeljko Samardzic submitted a new event for approval!", CreatedAt = new DateTime(2025, 1, 30, 10, 15, 0), isRead = false },
				new Notification { NotificationID = 7, UserID = 1, Title = "New Event Submitted", Message = "Prljavo Kazaliste submitted a new event for approval!", CreatedAt = new DateTime(2025, 2, 1, 10, 30, 0), isRead = false },
				new Notification { NotificationID = 17, UserID = 3, Title = "Event Status Update", Message = "Your event 'Ilma Karahmet - Debut Concert' has been approved!", CreatedAt = new DateTime(2025, 1, 20, 14, 30, 0), isRead = true },
				new Notification { NotificationID = 18, UserID = 3, Title = "Event Status Update", Message = "Your event 'Ilma Karahmet - Acoustic Evening' has been approved!", CreatedAt = new DateTime(2025, 2, 12, 11, 45, 0), isRead = true },
				new Notification { NotificationID = 19, UserID = 5, Title = "Event Status Update", Message = "Your event 'Toni Cetinski - Split Summer Nights' has been approved!", CreatedAt = new DateTime(2024, 3, 10, 13, 0, 0), isRead = true },
				new Notification { NotificationID = 20, UserID = 5, Title = "Event Status Update", Message = "Your event 'Toni Cetinski - Sarajevo Winter' has been approved!", CreatedAt = new DateTime(2024, 9, 5, 16, 15, 0), isRead = true },
				new Notification { NotificationID = 21, UserID = 5, Title = "Event Status Update", Message = "Your event 'Toni Cetinski - Banja Luka Special' has been rejected.", CreatedAt = new DateTime(2024, 12, 12, 9, 30, 0), isRead = false },
				new Notification { NotificationID = 22, UserID = 6, Title = "Event Status Update", Message = "Your event 'Zeljko Samardzic - Belgrade Classics' has been approved!", CreatedAt = new DateTime(2024, 5, 20, 12, 30, 0), isRead = true },
				new Notification { NotificationID = 23, UserID = 6, Title = "Event Status Update", Message = "Your event 'Zeljko Samardzic - Zenica Live' has been rejected.", CreatedAt = new DateTime(2025, 2, 1, 10, 15, 0), isRead = false },
				new Notification { NotificationID = 24, UserID = 7, Title = "Event Status Update", Message = "Your event 'Adi Sose - Jazz Night' has been approved!", CreatedAt = new DateTime(2024, 11, 15, 13, 20, 0), isRead = true },
				new Notification { NotificationID = 25, UserID = 7, Title = "Event Status Update", Message = "Your event 'Adi Sose - Akustik Session' has been approved!", CreatedAt = new DateTime(2024, 6, 20, 9, 45, 0), isRead = true },
				new Notification { NotificationID = 26, UserID = 8, Title = "Event Status Update", Message = "Your event 'Mirza Selimovic - Folk Spectacle' has been approved!", CreatedAt = new DateTime(2024, 4, 10, 14, 0, 0), isRead = true },
				new Notification { NotificationID = 27, UserID = 8, Title = "Event Status Update", Message = "Your event 'Mirza Selimovic - Bihac Summer' has been rejected.", CreatedAt = new DateTime(2025, 2, 22, 15, 15, 0), isRead = false },
				new Notification { NotificationID = 28, UserID = 10, Title = "Event Status Update", Message = "Your event 'Prljavo Kazaliste - Sarajevo Rock Night' has been approved!", CreatedAt = new DateTime(2024, 6, 15, 13, 45, 0), isRead = true },
				new Notification { NotificationID = 29, UserID = 10, Title = "Event Status Update", Message = "Your event 'Prljavo Kazaliste - 40 Years Anniversary' has been rejected.", CreatedAt = new DateTime(2025, 2, 3, 10, 30, 0), isRead = false },
				new Notification { NotificationID = 30, UserID = 11, Title = "New Event From Favorite Performer", Message = "Toni Cetinski has announced a new event in Banja Luka!", CreatedAt = new DateTime(2024, 12, 5, 11, 20, 0), isRead = true },
				new Notification { NotificationID = 31, UserID = 11, Title = "New Event From Favorite Performer", Message = "Prljavo Kazaliste has announced a new anniversary concert!", CreatedAt = new DateTime(2025, 1, 30, 13, 45, 0), isRead = false },
				new Notification { NotificationID = 32, UserID = 12, Title = "New Event From Favorite Performer", Message = "Zeljko Samardzic has announced a new event!", CreatedAt = new DateTime(2025, 1, 25, 16, 30, 0), isRead = true },
				new Notification { NotificationID = 33, UserID = 12, Title = "New Event From Favorite Performer", Message = "Ilma Karahmet has announced a new acoustic evening!", CreatedAt = new DateTime(2025, 2, 5, 11, 45, 0), isRead = false },
				new Notification { NotificationID = 34, UserID = 13, Title = "New Event From Favorite Performer", Message = "Adi Sose has announced a new Jazz Night!", CreatedAt = new DateTime(2024, 11, 10, 9, 30, 0), isRead = true },
				new Notification { NotificationID = 35, UserID = 13, Title = "New Event From Favorite Performer", Message = "Mirza Selimovic has announced a new event in Bihac!", CreatedAt = new DateTime(2025, 2, 18, 10, 20, 0), isRead = false },
				new Notification { NotificationID = 36, UserID = 14, Title = "New Event From Favorite Performer", Message = "Ilma Karahmet has announced a new debut concert!", CreatedAt = new DateTime(2025, 1, 15, 14, 45, 0), isRead = true },
				new Notification { NotificationID = 37, UserID = 15, Title = "New Event From Favorite Performer", Message = "Zeljko Samardzic has announced a new event in Zenica!", CreatedAt = new DateTime(2025, 1, 25, 16, 15, 0), isRead = true },
				new Notification { NotificationID = 38, UserID = 15, Title = "New Event From Favorite Performer", Message = "Prljavo Kazaliste has announced a new Split Open Air concert!", CreatedAt = new DateTime(2024, 3, 20, 16, 20, 0), isRead = true },
				new Notification { NotificationID = 39, UserID = 16, Title = "New Event From Favorite Performer", Message = "Prljavo Kazaliste has announced a 40 Years Anniversary concert!", CreatedAt = new DateTime(2025, 1, 30, 13, 20, 0), isRead = false },
				new Notification { NotificationID = 40, UserID = 16, Title = "New Event From Favorite Performer", Message = "Toni Cetinski has announced a new event in Zagreb Arena!", CreatedAt = new DateTime(2025, 2, 1, 10, 0, 0), isRead = true }
			);
		}
	}
}