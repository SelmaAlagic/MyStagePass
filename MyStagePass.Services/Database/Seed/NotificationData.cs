using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class NotificationData
	{
		public static void SeedData(this EntityTypeBuilder<Notification> entity)
		{
			entity.HasData(
				new Notification { NotificationID = 1, UserID = 1, Title = "New Event Submitted", Message = "Ilma Karahmet has submitted a new event 'Acoustic Evening' for approval!", CreatedAt = new DateTime(2025, 2, 5, 9, 15, 0), isRead = false },
				new Notification { NotificationID = 2, UserID = 1, Title = "New Event Submitted", Message = "Toni Cetinski has submitted a new event 'Zagreb Arena' for approval!", CreatedAt = new DateTime(2025, 2, 1, 10, 0, 0), isRead = false },
				new Notification { NotificationID = 3, UserID = 1, Title = "New Event Submitted", Message = "Zeljko Samardzic has submitted a new event 'Zenica Live' for approval!", CreatedAt = new DateTime(2025, 1, 25, 16, 15, 0), isRead = false },
				new Notification { NotificationID = 4, UserID = 1, Title = "New Event Submitted", Message = "Mirza Selimovic has submitted a new event 'Bihac Summer' for approval!", CreatedAt = new DateTime(2025, 2, 18, 8, 30, 0), isRead = false },
				new Notification { NotificationID = 5, UserID = 1, Title = "New Event Submitted", Message = "Prljavo kazaliste has submitted a new event '40 Years Anniversary' for approval!", CreatedAt = new DateTime(2025, 1, 30, 13, 20, 0), isRead = false },
				new Notification { NotificationID = 6, UserID = 1, Title = "New Event Submitted", Message = "Marija Serifovic has submitted a new event 'Balkan Spring Festival' for approval!", CreatedAt = new DateTime(2025, 4, 20, 10, 0, 0), isRead = false },
				new Notification { NotificationID = 7, UserID = 3, Title = "Event Approved", Message = "Your event 'Debut Concert' has been approved!", CreatedAt = new DateTime(2025, 1, 15, 17, 0, 0), isRead = true },
				new Notification { NotificationID = 8, UserID = 3, Title = "Event Approved", Message = "Your event 'Tuzla Summer Fest' has been approved!", CreatedAt = new DateTime(2024, 3, 10, 14, 0, 0), isRead = true },
				new Notification { NotificationID = 9, UserID = 5, Title = "Event Approved", Message = "Your event 'Mostar Bridge Concert' has been approved!", CreatedAt = new DateTime(2024, 4, 10, 12, 30, 0), isRead = true },
				new Notification { NotificationID = 10, UserID = 5, Title = "Event Approved", Message = "Your event 'Banja Luka Special' has been approved!", CreatedAt = new DateTime(2025, 12, 5, 14, 0, 0), isRead = false },
				new Notification { NotificationID = 11, UserID = 6, Title = "Event Approved", Message = "Your event 'Belgrade Classics' has been approved!", CreatedAt = new DateTime(2024, 5, 15, 16, 0, 0), isRead = true },
				new Notification { NotificationID = 12, UserID = 6, Title = "Event Approved", Message = "Your event 'Sarajevo Ballads' has been approved!", CreatedAt = new DateTime(2025, 8, 20, 13, 0, 0), isRead = false },
				new Notification { NotificationID = 13, UserID = 6, Title = "Event Approved", Message = "Your event 'Novi Sad Festival' has been approved!", CreatedAt = new DateTime(2026, 2, 28, 17, 0, 0), isRead = false },
				new Notification { NotificationID = 14, UserID = 7, Title = "Event Approved", Message = "Your event 'Jazz Night' has been approved!", CreatedAt = new DateTime(2025, 11, 10, 12, 0, 0), isRead = false },
				new Notification { NotificationID = 15, UserID = 7, Title = "Event Approved", Message = "Your event 'Akustik Session' has been approved!", CreatedAt = new DateTime(2025, 6, 15, 15, 30, 0), isRead = true },
				new Notification { NotificationID = 16, UserID = 8, Title = "Event Approved", Message = "Your event 'New Year''s Eve' has been approved!", CreatedAt = new DateTime(2025, 11, 30, 14, 0, 0), isRead = false },
				new Notification { NotificationID = 17, UserID = 10, Title = "Event Approved", Message = "Your event 'Mostar Rock Fest' has been approved!", CreatedAt = new DateTime(2025, 10, 5, 13, 0, 0), isRead = false },
				new Notification { NotificationID = 18, UserID = 5, Title = "Event Rejected", Message = "Your event 'Split Summer Nights' has been rejected.", CreatedAt = new DateTime(2025, 2, 20, 15, 0, 0), isRead = true },
				new Notification { NotificationID = 19, UserID = 5, Title = "Event Rejected", Message = "Your event 'Sarajevo Winter' has been rejected.", CreatedAt = new DateTime(2024, 9, 1, 18, 0, 0), isRead = true },
				new Notification { NotificationID = 20, UserID = 8, Title = "Event Rejected", Message = "Your event 'Folk Spectacle' has been rejected.", CreatedAt = new DateTime(2024, 4, 5, 14, 0, 0), isRead = true },
				new Notification { NotificationID = 21, UserID = 10, Title = "Event Rejected", Message = "Your event 'Sarajevo Rock Night' has been rejected.", CreatedAt = new DateTime(2025, 6, 10, 13, 0, 0), isRead = true },
				new Notification { NotificationID = 22, UserID = 10, Title = "Event Rejected", Message = "Your event 'Split Open Air' has been rejected.", CreatedAt = new DateTime(2024, 3, 15, 18, 30, 0), isRead = true },
				new Notification { NotificationID = 23, UserID = 11, Title = "New Event From Favorite Performer", Message = "Adi Sose has announced a new event 'Akustik Session'!", CreatedAt = new DateTime(2025, 6, 15, 16, 0, 0), isRead = true },
				new Notification { NotificationID = 24, UserID = 11, Title = "New Event From Favorite Performer", Message = "Prljavo kazaliste has announced a new event 'Mostar Rock Fest'!", CreatedAt = new DateTime(2025, 10, 5, 14, 0, 0), isRead = false },
				new Notification { NotificationID = 25, UserID = 11, Title = "New Event From Favorite Performer", Message = "Zeljko Samardzic has announced a new event 'Novi Sad Festival'!", CreatedAt = new DateTime(2026, 2, 28, 18, 0, 0), isRead = false },
				new Notification { NotificationID = 26, UserID = 11, Title = "New Event From Favorite Performer", Message = "Adi Sose has announced a new event 'Jazz Night'!", CreatedAt = new DateTime(2025, 11, 10, 13, 0, 0), isRead = false },
				new Notification { NotificationID = 27, UserID = 11, Title = "New Event From Favorite Performer", Message = "Mirza Selimovic has announced a new event 'New Year''s Eve'!", CreatedAt = new DateTime(2025, 11, 30, 15, 0, 0), isRead = false },
				new Notification { NotificationID = 28, UserID = 12, Title = "New Event From Favorite Performer", Message = "Zeljko Samardzic has announced a new event 'Novi Sad Festival'!", CreatedAt = new DateTime(2026, 2, 28, 18, 0, 0), isRead = false },
				new Notification { NotificationID = 29, UserID = 12, Title = "New Event From Favorite Performer", Message = "Mirza Selimovic has announced a new event 'New Year''s Eve'!", CreatedAt = new DateTime(2025, 11, 30, 15, 0, 0), isRead = false },
				new Notification { NotificationID = 30, UserID = 12, Title = "New Event From Favorite Performer", Message = "Toni Cetinski has announced a new event 'Banja Luka Special'!", CreatedAt = new DateTime(2025, 12, 5, 15, 0, 0), isRead = false },
				new Notification { NotificationID = 31, UserID = 13, Title = "New Event From Favorite Performer", Message = "Adi Sose has announced a new event 'Jazz Night'!", CreatedAt = new DateTime(2025, 11, 10, 13, 0, 0), isRead = false },
				new Notification { NotificationID = 32, UserID = 13, Title = "New Event From Favorite Performer", Message = "Adi Sose has announced a new event 'Akustik Session'!", CreatedAt = new DateTime(2025, 6, 15, 16, 0, 0), isRead = true },
				new Notification { NotificationID = 33, UserID = 13, Title = "New Event From Favorite Performer", Message = "Ilma Karahmet has announced a new event 'Debut Concert'!", CreatedAt = new DateTime(2025, 1, 15, 18, 0, 0), isRead = true },
				new Notification { NotificationID = 34, UserID = 14, Title = "New Event From Favorite Performer", Message = "Ilma Karahmet has announced a new event 'Debut Concert'!", CreatedAt = new DateTime(2025, 1, 15, 18, 0, 0), isRead = true },
				new Notification { NotificationID = 35, UserID = 15, Title = "New Event From Favorite Performer", Message = "Prljavo kazaliste has announced a new event 'Mostar Rock Fest'!", CreatedAt = new DateTime(2025, 10, 5, 14, 0, 0), isRead = false },
				new Notification { NotificationID = 36, UserID = 15, Title = "New Event From Favorite Performer", Message = "Zeljko Samardzic has announced a new event 'Novi Sad Festival'!", CreatedAt = new DateTime(2026, 2, 28, 18, 0, 0), isRead = false },
				new Notification { NotificationID = 37, UserID = 15, Title = "New Event From Favorite Performer", Message = "Toni Cetinski has announced a new event 'Banja Luka Special'!", CreatedAt = new DateTime(2025, 12, 5, 15, 0, 0), isRead = false },
				new Notification { NotificationID = 38, UserID = 16, Title = "New Event From Favorite Performer", Message = "Mirza Selimovic has announced a new event 'New Year''s Eve'!", CreatedAt = new DateTime(2025, 11, 30, 15, 0, 0), isRead = false },
				new Notification { NotificationID = 39, UserID = 16, Title = "New Event From Favorite Performer", Message = "Adi Sose has announced a new event 'Akustik Session'!", CreatedAt = new DateTime(2025, 6, 15, 16, 0, 0), isRead = true }
			);
		}
	}
}