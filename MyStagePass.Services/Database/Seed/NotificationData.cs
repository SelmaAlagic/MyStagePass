using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class NotificationData
	{
		public static void SeedData(this EntityTypeBuilder<Notification> entity)
		{
			entity.HasData(
				//Admin notifications
				new Notification { NotificationID = 1, UserID = 1, Message = "New performer request waiting for verification!", CreatedAt = new DateTime(2025, 10, 29, 10, 0, 0), isRead = true },
				new Notification { NotificationID = 2, UserID = 1, Message = "You have some events waiting for approval!", CreatedAt = new DateTime(2025, 10, 29, 10, 30, 0), isRead = true },

				// Customer notifications
				new Notification { NotificationID = 3, UserID = 7, Message = "Ilma Karahmet added a new event!", CreatedAt = new DateTime(2025, 11, 28, 12, 0, 0), isRead = false },
				new Notification { NotificationID = 4, UserID = 9, Message = "Toni Cetinski added a new event!", CreatedAt = new DateTime(2025, 10, 28, 10, 0, 0), isRead = true },

				// Performer notifications
				new Notification { NotificationID = 5, UserID = 4, Message = "Your event has been approved!", CreatedAt = new DateTime(2025, 12, 31, 14, 0, 0), isRead = false },
				new Notification { NotificationID = 6, UserID = 5, Message = "Your event has been rejected!", CreatedAt = new DateTime(2025, 1, 22, 16, 0, 0), isRead = false },
				new Notification { NotificationID = 7, UserID = 3, Message = "Your event has been rejected!", CreatedAt = new DateTime(2025, 2, 9, 16, 0, 0), isRead = false }
			);
		}
	}
}