using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class NotificationService : BaseService<Model.Models.Notification, Database.Notification, NotificationSearchObject>, INotificationService
	{
		public NotificationService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public async Task SoftDelete(int id)
		{
			var notification = await _context.Notifications
		.FirstOrDefaultAsync(n => n.NotificationID == id);

			if (notification == null)
				throw new Exception("Notification not found");

			notification.IsDeleted = true;

			await _context.SaveChangesAsync();

		}
	}
}
