using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class NotificationData
	{
		public static void SeedData(this EntityTypeBuilder<Notification> entity)
		{
			entity.HasData(
				new Notification { NotificationID = 1, UserID = 1, Message = "New performer request waiting for verification!", CreatedAt = new DateTime(2025, 10, 29, 10, 0, 0), isRead = true },
				new Notification { NotificationID = 2, UserID = 1, Message = "You have some events waiting for approval!", CreatedAt = new DateTime(2025, 10, 29, 10, 30, 0), isRead = true },
				new Notification { NotificationID = 3, UserID = 11, Message = "Adi Sose added a new event!", CreatedAt = new DateTime(2025, 1, 15, 12, 0, 0), isRead = false },
				new Notification { NotificationID = 4, UserID = 12, Message = "Mirza Selimovic added a new event!", CreatedAt = new DateTime(2025, 1, 20, 15, 0, 0), isRead = true },
				new Notification { NotificationID = 5, UserID = 13, Message = "Jelena Rozga added a new event!", CreatedAt = new DateTime(2025, 2, 1, 10, 0, 0), isRead = false },
				new Notification { NotificationID = 6, UserID = 15, Message = "Marija Serifovic added a new event!", CreatedAt = new DateTime(2025, 2, 10, 14, 0, 0), isRead = false },
				new Notification { NotificationID = 7, UserID = 11, Message = "Dzejla Ramovic added a new event!", CreatedAt = new DateTime(2025, 2, 12, 09, 0, 0), isRead = true },
				new Notification { NotificationID = 8, UserID = 9, Message = "Your event has been approved!", CreatedAt = new DateTime(2025, 1, 5, 10, 0, 0), isRead = true }, 
				new Notification { NotificationID = 9, UserID = 2, Message = "Your event has been rejected!", CreatedAt = new DateTime(2025, 1, 22, 16, 0, 0), isRead = false },
				new Notification { NotificationID = 10, UserID = 7, Message = "Your event has been approved!", CreatedAt = new DateTime(2025, 1, 10, 11, 0, 0), isRead = true }, 
				new Notification { NotificationID = 11, UserID = 10, Message = "Your event has been rejected!", CreatedAt = new DateTime(2025, 2, 9, 16, 0, 0), isRead = false }, 
				new Notification { NotificationID = 12, UserID = 3, Message = "Your event has been approved!", CreatedAt = new DateTime(2025, 2, 11, 12, 0, 0), isRead = false }, 
				new Notification { NotificationID = 13, UserID = 8, Message = "Your event has been approved!", CreatedAt = new DateTime(2025, 1, 15, 08, 0, 0), isRead = true } 
			);
		}
	}
}