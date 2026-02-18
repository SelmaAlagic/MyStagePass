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
	public class GenreController : BaseController<Genre, GenreSearchObject>
	{
		public GenreController(ILogger<BaseController<Genre, GenreSearchObject>> logger, IGenreService service) : base(logger, service)
		{
		}
	}
}