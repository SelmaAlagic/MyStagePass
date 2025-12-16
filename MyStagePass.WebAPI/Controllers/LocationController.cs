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
	[Authorize(Roles ="Admin")]
	public class LocationController : BaseCRUDController<Location, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>
	{
		public LocationController(ILogger<BaseController<Location, LocationSearchObject>> logger, ILocationService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		[HttpGet]
		public override async Task<PagedResult<Location>> Get([FromQuery] LocationSearchObject search)
		{
			return await base.Get(search);
		}
	}
}