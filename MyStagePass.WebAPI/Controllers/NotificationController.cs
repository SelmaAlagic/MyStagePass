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
		public NotificationController(ILogger<BaseController<Notification, NotificationSearchObject>> logger, INotificationService service) : base(logger, service)
		{
		}
	}
}