using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class StatusController : BaseController<Status, StatusSearchObject>
	{
		public StatusController(ILogger<BaseController<Status, StatusSearchObject>> logger, IStatusService service) : base(logger, service)
		{
		}
	}
}
