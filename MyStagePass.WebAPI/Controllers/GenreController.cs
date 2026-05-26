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

	public class GenreController : BaseCRUDController<Genre, GenreSearchObject, GenreInsertRequest, GenreUpdateRequest>
	{
		public GenreController(ILogger<BaseController<Genre, GenreSearchObject>> logger, IGenreService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		public override Task<PagedResult<Genre>> Get([FromQuery] GenreSearchObject? search = null)
		{
			return base.Get(search);
		}
	}
}