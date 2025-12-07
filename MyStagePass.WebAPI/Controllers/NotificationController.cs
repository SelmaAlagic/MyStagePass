using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;
using System.Security.Claims;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize]
	public class NotificationController : BaseController<Notification, NotificationSearchObject>
	{
		public NotificationController(ILogger<BaseController<Notification, NotificationSearchObject>> logger, INotificationService service) : base(logger, service)
		{
		}

		[HttpGet]
		public override async Task<PagedResult<Notification>> Get([FromQuery] NotificationSearchObject search)
		{
			int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier).Value);
			search.UserID = userId;

			return await base.Get(search);
		}

		[HttpGet("unread")]
		public async Task<IActionResult> GetUnread([FromQuery] NotificationSearchObject search)
		{
			var notificationService = _service as INotificationService;
			int userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier).Value);

			int unreadCount = await notificationService.GetUnreadCount(userId);

			search.UserID = userId;
			search.IsRead = false;

			var result = await base.Get(search);
			await notificationService.MarkAllAsRead(userId);

			return Ok(new
			{
				notifications = result,
				unreadCount = unreadCount
			});
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