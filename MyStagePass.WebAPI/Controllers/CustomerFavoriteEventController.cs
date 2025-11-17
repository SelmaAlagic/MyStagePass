using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class CustomerFavoriteEventController : BaseController<CustomerFavoriteEvent, CustomerFavoriteEventSearchObject>
	{
		public CustomerFavoriteEventController(ILogger<BaseController<CustomerFavoriteEvent, CustomerFavoriteEventSearchObject>> logger, ICustomerFavoriteEventService service) : base(logger, service)
		{
		}
	}
}
