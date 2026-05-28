using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize (Roles = Roles.Admin)]
	public class StatusController : BaseCRUDController<Status, StatusSearchObject, StatusInsertRequest, StatusUpdateRequest>
	{
		public StatusController(ILogger<BaseController<Status, StatusSearchObject>> logger, IStatusService service) : base(logger, service)
		{
		}
	}
}