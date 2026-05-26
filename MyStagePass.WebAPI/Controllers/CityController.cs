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
	[Authorize(Roles = Roles.Admin)]
	public class CityController : BaseCRUDController<City, CitySearchObject, CityInsertRequest, CityUpdateRequest>
	{
		public CityController(ILogger<BaseController<City, CitySearchObject>> logger, ICityService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		[HttpGet]
		public override async Task<PagedResult<City>> Get([FromQuery] CitySearchObject search)
		{
			return await base.Get(search);
		}

		[AllowAnonymous]
		[HttpGet("{id}")]
		public override async Task<City> GetById(int id)
		{
			return await base.GetById(id);
		}
	}
}