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
	public class CountryController : BaseCRUDController<Country, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>
	{
		public CountryController(ILogger<BaseController<Country, CountrySearchObject>> logger, ICountryService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		[HttpGet]
		public override async Task<PagedResult<Country>> Get([FromQuery] CountrySearchObject search)
		{
			return await base.Get(search);
		}

		[AllowAnonymous]
		[HttpGet("{id}")]
		public override async Task<Country> GetById(int id)
		{
			return await base.GetById(id);
		}
	}
}