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
		[NonAction]
		public override async Task<Notification> Insert([FromBody] NotificationInsertRequest request) => throw new UnauthorizedAccessException("Not allowed.");

		[NonAction]
		public override async Task<Notification> Update(int id, [FromBody] NotificationUpdateRequest request) => throw new UnauthorizedAccessException("Not allowed.");


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

		[HttpDelete("{id}")]
		public override async Task<Notification> Delete(int id)
		{
			var userId = _currentUserService.GetUserId();
			var notification = await _notificationService.GetById(id);

			if (notification == null)
				throw new KeyNotFoundException("Notification not found.");

			if (notification.UserID != userId)
				throw new UnauthorizedAccessException("You can only delete your own notifications.");

			return await _notificationService.Delete(id);
		}
	}
}