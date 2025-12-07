using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
	public interface INotificationService: IService<Notification, NotificationSearchObject>
	{
		Task<int> GetUnreadCount(int userId);
		Task MarkAllAsRead(int userId);
		Task<Model.Models.Notification> Insert(NotificationInsertRequest request);
		Task NotifyUser(int userId, string message);
		Task NotifyUsers(List<int> userIds, string message);
		Task SoftDelete(int id);
	}
}