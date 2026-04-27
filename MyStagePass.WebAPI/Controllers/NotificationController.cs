using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;
using System.Security.Claims;

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

		[HttpPut("mark-all-as-read")]
		public async Task<IActionResult> MarkAllAsRead()
		{
			var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
			await _notificationService.MarkAllAsRead(userId);
			return Ok();
		}

		[HttpGet("unread-count")]
		public async Task<ActionResult<int>> GetUnreadCount()
		{
			var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
			var count = await _notificationService.GetUnreadCount(userId);
			return Ok(count);
		}

		[HttpGet]
		public override async Task<PagedResult<Notification>> Get([FromQuery] NotificationSearchObject search)
		{
			var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);
			search.UserID = userId;
			return await _service.Get(search);
		}
	}
}