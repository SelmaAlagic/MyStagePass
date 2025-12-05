using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[AllowAnonymous]
	public class CityController : BaseController<City, CitySearchObject>
	{
		public CityController(ILogger<BaseController<City, CitySearchObject>> logger, ICityService service) : base(logger, service)
		{
		}
	}
}