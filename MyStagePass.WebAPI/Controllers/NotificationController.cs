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
		private readonly ICurrentUserService _currentUserService;

		public NotificationController(ILogger<BaseController<Notification, NotificationSearchObject>> logger, INotificationService service, ICurrentUserService currentUserService) : base(logger, service)
		{
			_notificationService=service;
			_currentUserService=currentUserService;
		}

		[HttpPut("mark-all-as-read")]
		public async Task<IActionResult> MarkAllAsRead()
		{
			var userId = _currentUserService.GetUserId();
			await _notificationService.MarkAllAsRead(userId);
			return Ok();
		}

		[HttpGet("unread-count")]
		public async Task<ActionResult<int>> GetUnreadCount()
		{
			var userId = _currentUserService.GetUserId();
			var count = await _notificationService.GetUnreadCount(userId);
			return Ok(count);
		}

		[HttpGet]
		public override async Task<PagedResult<Notification>> Get([FromQuery] NotificationSearchObject search)
		{
			var userId = _currentUserService.GetUserId();
			search.UserID = userId;
			return await _service.Get(search);
		}
	}
}