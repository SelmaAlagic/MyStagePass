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
	[AllowAnonymous]
	public class LocationController : BaseCRUDController<Location, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>
	{
		public LocationController(ILogger<BaseController<Location, LocationSearchObject>> logger, ILocationService service) : base(logger, service)
		{
		}
	}
}