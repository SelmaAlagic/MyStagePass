using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Requests;
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

		public override IQueryable<Notification> AddFilter(IQueryable<Notification> query, NotificationSearchObject? search = null)
		{
			if (search == null)
				return query;

			query = query.Where(p => !p.IsDeleted);

			if (search.UserID != null)
				query = query.Where(n => n.UserID == search.UserID);

			if (search.IsRead != null)
				query = query.Where(n => n.isRead == search.IsRead);

			return query;
		}

		public async Task MarkAllAsRead(int userId)
		{
			var notifications = await _context.Notifications
				.Where(n => n.UserID == userId && !n.isRead && !n.IsDeleted)
				.ToListAsync();

			foreach (var notification in notifications)
			{
				notification.isRead = true;
			}

			await _context.SaveChangesAsync();
		}

		public async Task<int> GetUnreadCount(int userId)
		{
			return await _context.Notifications
				.CountAsync(n => n.UserID == userId && !n.isRead && !n.IsDeleted);
		}
		public async Task<Model.Models.Notification> Insert(NotificationInsertRequest request)
		{
			var entity = _mapper.Map<Database.Notification>(request);
			entity.CreatedAt = DateTime.Now;
			await _context.Notifications.AddAsync(entity);
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Notification>(entity);
		}

		public async Task NotifyUser(int userId, string message)
		{
			await Insert(new NotificationInsertRequest
			{
				UserID = userId,
				Message = message
			});
		}

		public async Task NotifyUsers(List<int> userIds, string message)
		{
			foreach (var userId in userIds)
			{
				await Insert(new NotificationInsertRequest
				{
					UserID = userId,
					Message = message
				});
			}
		}

		public async Task SoftDelete(int id)
		{
			var notification = await _context.Notifications.FirstOrDefaultAsync(n => n.NotificationID == id);

			if (notification == null)
				throw new Exception("Notification not found");

			notification.IsDeleted = true;

			await _context.SaveChangesAsync();
		}
	}
}