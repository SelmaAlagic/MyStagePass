using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class CustomerFavoriteEventController : BaseCRUDController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject, CustomerFavoriteEventInsertRequest, CustomerFavoriteEventUpdateRequest>
	{
		public CustomerFavoriteEventController(ILogger<BaseController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject>> logger, ICustomerFavoriteEventService service) : base(logger, service)
		{
		}
	}
}