using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;
using System.Security.Claims;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles = "Customer")]
	public class CustomerFavoriteEventController : BaseCRUDController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject, CustomerFavoriteEventInsertRequest, CustomerFavoriteEventUpdateRequest>
	{
		public CustomerFavoriteEventController(ILogger<BaseController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject>> logger, ICustomerFavoriteEventService service) : base(logger, service)
		{
		}

		[HttpGet]
		public override async Task<PagedResult<CustomerFavoriteEvent>> Get([FromQuery] CustomerFavoriteEventSearchObject search)
		{
			int customerId = int.Parse(User.FindFirst("RoleId").Value);
			search.CustomerID = customerId;

			return await base.Get(search);
		}
	}
}