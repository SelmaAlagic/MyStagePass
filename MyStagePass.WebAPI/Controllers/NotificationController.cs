using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize]
	public class NotificationController : BaseCRUDController<Model.Models.Notification, NotificationSearchObject, NotificationInsertRequest, NotificationUpdateRequest>
	{
		private readonly INotificationService _notificationService;

		public NotificationController(ILogger<BaseController<Notification, NotificationSearchObject>> logger, INotificationService service) : base(logger, service)
		{
			_notificationService=service;
		}

		[HttpPut("mark-all-as-read/{userId}")]
		public async Task<IActionResult> MarkAllAsRead(int userId)
		{
			await _notificationService.MarkAllAsRead(userId);
			return Ok();
		}

		[HttpGet("unread-count/{userId}")]
		public async Task<ActionResult<int>> GetUnreadCount(int userId)
		{
			var count = await _notificationService.GetUnreadCount(userId);
			return Ok(count);
		}
	}
}