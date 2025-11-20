using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class NotificationController : BaseController<Notification, NotificationSearchObject>
	{
		public NotificationController(ILogger<BaseController<Notification, NotificationSearchObject>> logger, INotificationService service) : base(logger, service)
		{
		}

		[HttpDelete("{id}")]
		public async Task<IActionResult> SoftDelete(int id)
		{
			var notificationService = _service as INotificationService;
			if (notificationService == null)
				return BadRequest("Service not available");

			await notificationService.SoftDelete(id);
			return Ok("Notification successfully soft-deleted!");
		}
	}
}
