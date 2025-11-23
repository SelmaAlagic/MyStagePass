using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
	public interface INotificationService: IService<Notification, NotificationSearchObject>
	{
		Task SoftDelete(int id);
	}
}