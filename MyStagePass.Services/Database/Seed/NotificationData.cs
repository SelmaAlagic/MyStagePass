using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class NotificationData
	{
		public static void SeedData(this EntityTypeBuilder<Notification> entity)
		{
			entity.HasData(
				new Notification { NotificationID = 1, UserID = 1, Message = "New performer request (Dzejla Ramovic) waiting for verification!", CreatedAt = new DateTime(2025, 3, 15, 9, 30, 0), isRead = false },
				new Notification { NotificationID = 2, UserID = 1, Message = "New performer request (Jelena Rozga) waiting for verification!", CreatedAt = new DateTime(2025, 3, 18, 11, 15, 0), isRead = false },
				new Notification { NotificationID = 3, UserID = 1, Message = "New performer request (Marija Serifovic) waiting for verification!", CreatedAt = new DateTime(2025, 3, 20, 14, 45, 0), isRead = false },
				new Notification { NotificationID = 4, UserID = 1, Message = "3 events pending approval for approved performers!", CreatedAt = new DateTime(2025, 3, 22, 10, 0, 0), isRead = true },
				new Notification { NotificationID = 5, UserID = 1, Message = "Ilma Karahmet submitted a new event for approval", CreatedAt = new DateTime(2025, 3, 10, 16, 20, 0), isRead = true },
				new Notification { NotificationID = 6, UserID = 1, Message = "Toni Cetinski submitted 2 new events for approval", CreatedAt = new DateTime(2025, 3, 5, 13, 10, 0), isRead = true },
				new Notification { NotificationID = 7, UserID = 2, Message = "Your performer application has been received and is pending review", CreatedAt = new DateTime(2025, 3, 15, 9, 35, 0), isRead = true },
				new Notification { NotificationID = 8, UserID = 2, Message = "Your application is still under review by admin", CreatedAt = new DateTime(2025, 3, 20, 10, 0, 0), isRead = false },
				new Notification { NotificationID = 9, UserID = 3, Message = "Your event 'Ilma Karahmet - Debut Concert' has been approved!", CreatedAt = new DateTime(2025, 1, 20, 14, 30, 0), isRead = true },
				new Notification { NotificationID = 10, UserID = 3, Message = "Your event 'Ilma Karahmet - Acoustic Evening' is pending approval", CreatedAt = new DateTime(2025, 2, 10, 11, 45, 0), isRead = false },
				new Notification { NotificationID = 11, UserID = 3, Message = "5 customers have added your events to favorites!", CreatedAt = new DateTime(2025, 2, 15, 9, 0, 0), isRead = false },
				new Notification { NotificationID = 12, UserID = 4, Message = "Your performer application has been received and is pending review", CreatedAt = new DateTime(2025, 3, 18, 11, 20, 0), isRead = true },
				new Notification { NotificationID = 13, UserID = 4, Message = "Your application is still under review by admin", CreatedAt = new DateTime(2025, 3, 25, 10, 30, 0), isRead = false },
				new Notification { NotificationID = 14, UserID = 5, Message = "Your event 'Toni Cetinski - Split Summer Nights' has been approved!", CreatedAt = new DateTime(2024, 3, 10, 13, 0, 0), isRead = true },
				new Notification { NotificationID = 15, UserID = 5, Message = "Your event 'Toni Cetinski - Sarajevo Winter' has been approved!", CreatedAt = new DateTime(2024, 9, 5, 16, 15, 0), isRead = true },
				new Notification { NotificationID = 16, UserID = 5, Message = "Your event 'Toni Cetinski - Mostar Bridge Concert' has been approved!", CreatedAt = new DateTime(2024, 4, 15, 10, 45, 0), isRead = true },
				new Notification { NotificationID = 17, UserID = 5, Message = "Your event 'Toni Cetinski - Banja Luka Special' is pending approval", CreatedAt = new DateTime(2024, 12, 10, 9, 30, 0), isRead = false },
				new Notification { NotificationID = 18, UserID = 5, Message = "Your event 'Toni Cetinski - Zagreb Arena' is pending approval", CreatedAt = new DateTime(2025, 2, 5, 14, 20, 0), isRead = false },
				new Notification { NotificationID = 19, UserID = 5, Message = "8 customers have added your events to favorites!", CreatedAt = new DateTime(2025, 1, 20, 11, 0, 0), isRead = true },
				new Notification { NotificationID = 20, UserID = 5, Message = "Congratulations! Your event 'Split Summer Nights' reached 234 reviews with 4.70 average rating!", CreatedAt = new DateTime(2024, 9, 1, 9, 0, 0), isRead = true },
				new Notification { NotificationID = 21, UserID = 6, Message = "Your event 'Zeljko Samardzic - Belgrade Classics' has been approved!", CreatedAt = new DateTime(2024, 5, 20, 12, 30, 0), isRead = true },
				new Notification { NotificationID = 22, UserID = 6, Message = "Your event 'Zeljko Samardzic - Sarajevo Ballads' has been approved!", CreatedAt = new DateTime(2024, 8, 25, 15, 45, 0), isRead = true },
				new Notification { NotificationID = 23, UserID = 6, Message = "Your event 'Zeljko Samardzic - Zenica Live' is pending approval", CreatedAt = new DateTime(2025, 1, 30, 10, 15, 0), isRead = false },
				new Notification { NotificationID = 24, UserID = 6, Message = "Your event 'Zeljko Samardzic - Novi Sad Festival' has been approved!", CreatedAt = new DateTime(2024, 3, 5, 11, 0, 0), isRead = true },
				new Notification { NotificationID = 25, UserID = 6, Message = "6 customers have added your events to favorites!", CreatedAt = new DateTime(2025, 2, 1, 14, 30, 0), isRead = false },
				new Notification { NotificationID = 26, UserID = 7, Message = "Your event 'Adi Sose - Jazz Night' has been approved!", CreatedAt = new DateTime(2024, 11, 15, 13, 20, 0), isRead = true },
				new Notification { NotificationID = 27, UserID = 7, Message = "Your event 'Adi Sose - Akustik Session' has been approved!", CreatedAt = new DateTime(2024, 6, 20, 9, 45, 0), isRead = true },
				new Notification { NotificationID = 28, UserID = 7, Message = "3 customers have added your events to favorites!", CreatedAt = new DateTime(2025, 1, 10, 16, 0, 0), isRead = true },
				new Notification { NotificationID = 29, UserID = 7, Message = "Your Akustik Session event got 4.70 average rating from 67 reviews!", CreatedAt = new DateTime(2024, 12, 1, 10, 0, 0), isRead = true },
				new Notification { NotificationID = 30, UserID = 8, Message = "Your event 'Mirza Selimovic - Folk Spectacle' has been approved!", CreatedAt = new DateTime(2024, 4, 10, 14, 0, 0), isRead = true },
				new Notification { NotificationID = 31, UserID = 8, Message = "Your event 'Mirza Selimovic - New Year's Eve' has been approved!", CreatedAt = new DateTime(2024, 7, 5, 11, 30, 0), isRead = true },
				new Notification { NotificationID = 32, UserID = 8, Message = "Your event 'Mirza Selimovic - Bihac Summer' is pending approval", CreatedAt = new DateTime(2025, 2, 20, 15, 15, 0), isRead = false },
				new Notification { NotificationID = 33, UserID = 8, Message = "4 customers have added your events to favorites!", CreatedAt = new DateTime(2025, 1, 5, 12, 45, 0), isRead = true },
				new Notification { NotificationID = 34, UserID = 9, Message = "Your performer application has been received and is pending review", CreatedAt = new DateTime(2025, 3, 20, 14, 50, 0), isRead = true },
				new Notification { NotificationID = 35, UserID = 9, Message = "Your application is still under review by admin", CreatedAt = new DateTime(2025, 3, 25, 9, 15, 0), isRead = false },
				new Notification { NotificationID = 36, UserID = 10, Message = "Your event 'Prljavo Kazaliste - 40 Years Anniversary' is pending approval", CreatedAt = new DateTime(2025, 2, 1, 10, 30, 0), isRead = false },
				new Notification { NotificationID = 37, UserID = 10, Message = "Your event 'Prljavo Kazaliste - Sarajevo Rock Night' has been approved!", CreatedAt = new DateTime(2024, 6, 15, 13, 45, 0), isRead = true },
				new Notification { NotificationID = 38, UserID = 10, Message = "Your event 'Prljavo Kazaliste - Split Open Air' has been approved!", CreatedAt = new DateTime(2024, 3, 20, 16, 20, 0), isRead = true },
				new Notification { NotificationID = 39, UserID = 10, Message = "Your event 'Prljavo Kazaliste - Mostar Rock Fest' has been approved!", CreatedAt = new DateTime(2024, 10, 10, 11, 0, 0), isRead = true },
				new Notification { NotificationID = 40, UserID = 10, Message = "5 customers have added your events to favorites!", CreatedAt = new DateTime(2025, 2, 15, 14, 0, 0), isRead = false },
				new Notification { NotificationID = 41, UserID = 11, Message = "Toni Cetinski added a new event in Banja Luka!", CreatedAt = new DateTime(2024, 12, 5, 11, 20, 0), isRead = true },
				new Notification { NotificationID = 42, UserID = 11, Message = "Prljavo Kazaliste added a new anniversary concert!", CreatedAt = new DateTime(2025, 1, 30, 13, 45, 0), isRead = false },
				new Notification { NotificationID = 43, UserID = 11, Message = "Zeljko Samardzic event in Zenica is now available!", CreatedAt = new DateTime(2025, 1, 25, 16, 30, 0), isRead = true },
				new Notification { NotificationID = 44, UserID = 11, Message = "One of your favorite performers (Toni Cetinski) has a new event!", CreatedAt = new DateTime(2025, 2, 1, 10, 15, 0), isRead = false },
				new Notification { NotificationID = 45, UserID = 12, Message = "Zeljko Samardzic at EXIT Festival was a huge success!", CreatedAt = new DateTime(2024, 7, 10, 9, 0, 0), isRead = true },
				new Notification { NotificationID = 46, UserID = 12, Message = "Mirza Selimovic New Year's Eve event is coming up!", CreatedAt = new DateTime(2024, 12, 1, 14, 30, 0), isRead = true },
				new Notification { NotificationID = 47, UserID = 12, Message = "Ilma Karahmet acoustic evening tickets now available!", CreatedAt = new DateTime(2025, 2, 5, 11, 45, 0), isRead = false },
				new Notification { NotificationID = 48, UserID = 13, Message = "Adi Sose Jazz Night is coming soon!", CreatedAt = new DateTime(2024, 11, 10, 9, 30, 0), isRead = true },
				new Notification { NotificationID = 49, UserID = 13, Message = "Ilma Karahmet Tuzla Summer Fest reviews are in - 4.63 rating!", CreatedAt = new DateTime(2024, 7, 25, 15, 0, 0), isRead = true },
				new Notification { NotificationID = 50, UserID = 13, Message = "Mirza Selimovic Bihac Summer event is now pending approval", CreatedAt = new DateTime(2025, 2, 18, 10, 20, 0), isRead = false },
				new Notification { NotificationID = 51, UserID = 14, Message = "Ilma Karahmet debut concert tickets selling fast!", CreatedAt = new DateTime(2025, 1, 15, 14, 45, 0), isRead = true },
				new Notification { NotificationID = 52, UserID = 14, Message = "Zeljko Samardzic Sarajevo Ballads event has ended - check reviews!", CreatedAt = new DateTime(2025, 3, 9, 11, 0, 0), isRead = false },
				new Notification { NotificationID = 53, UserID = 15, Message = "Zeljko Samardzic Zenica Live tickets now available!", CreatedAt = new DateTime(2025, 1, 25, 16, 15, 0), isRead = true },
				new Notification { NotificationID = 54, UserID = 15, Message = "Prljavo Kazaliste Split Open Air was amazing - 4.57 rating!", CreatedAt = new DateTime(2024, 8, 28, 10, 30, 0), isRead = true },
				new Notification { NotificationID = 55, UserID = 15, Message = "Toni Cetinski Sarajevo Winter event photos available!", CreatedAt = new DateTime(2025, 2, 15, 13, 45, 0), isRead = false },
				new Notification { NotificationID = 56, UserID = 16, Message = "Prljavo Kazaliste 40 Years Anniversary concert announced!", CreatedAt = new DateTime(2025, 1, 30, 13, 20, 0), isRead = false },
				new Notification { NotificationID = 57, UserID = 16, Message = "Toni Cetinski Zagreb Arena event is now pending approval", CreatedAt = new DateTime(2025, 2, 1, 10, 0, 0), isRead = true }
			);
		}
	}
}