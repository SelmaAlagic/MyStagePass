using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace MyStagePass.Services.Interfaces
{
	public interface INotificationService: IService<Notification, NotificationSearchObject>
	{
		Task SoftDelete(int id);
	}
}
