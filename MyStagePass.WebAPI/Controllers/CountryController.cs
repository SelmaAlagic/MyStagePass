using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class CountryController : BaseController<Country, CountrySearchObject>
	{
		public CountryController(ILogger<BaseController<Country, CountrySearchObject>> logger, ICountryService service) : base(logger, service)
		{
		}
	}
}