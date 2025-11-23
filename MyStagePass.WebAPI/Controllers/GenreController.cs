using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class GenreController : BaseController<Genre, GenreSearchObject>
	{
		public GenreController(ILogger<BaseController<Genre, GenreSearchObject>> logger, IGenreService service) : base(logger, service)
		{
		}
	}
}