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
	[Authorize(Roles = Roles.Customer)]
	public class PurchaseController : BaseCRUDController<Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>
	{
		private readonly ICurrentUserService _currentUserService;

		public PurchaseController(ILogger<BaseController<Purchase, PurchaseSearchObject>> logger, IPurchaseService service, ICurrentUserService currentUserService)
			: base(logger, service)
		{
			_currentUserService=currentUserService;
		}

		[HttpGet]
		public override async Task<PagedResult<Purchase>> Get([FromQuery] PurchaseSearchObject search)
		{
			search.CustomerID = _currentUserService.GetCustomerId();

			if (search.DateFrom != null && search.DateTo != null && search.DateFrom > search.DateTo)
			{
				return await Task.FromException<PagedResult<Purchase>>(new ArgumentException("Datum 'od' ne može biti veći od datuma 'do'."));
			}

			return await base.Get(search);
		}

		[HttpGet("my-events")]
		public async Task<PagedResult<Event>> GetMyEvents([FromQuery] PurchaseSearchObject search)
		{
			search.CustomerID = _currentUserService.GetCustomerId();
			var eventService = _service as IPurchaseService;
			return await eventService.GetCustomerEvents(search);
		}

		[HttpPost]
		public override async Task<Purchase> Insert([FromBody] PurchaseInsertRequest request)
		{
			request.CustomerID = _currentUserService.GetCustomerId();
			return await base.Insert(request);
		}

		[HttpGet("{id}")]
		public override async Task<Purchase> GetById(int id)
		{
			int customerId = _currentUserService.GetCustomerId();
			var purchase = await base.GetById(id);

			if (purchase.CustomerID != customerId)
				throw new UnauthorizedAccessException("You are not allowed to view this purchase");

			return purchase;
		}

		[HttpDelete("{id}")]
		public override async Task<Purchase> Delete(int id)
		{
			int customerId = _currentUserService.GetCustomerId();
			var purchase = await base.GetById(id);

			if (purchase.CustomerID != customerId)
				throw new UnauthorizedAccessException("You are not allowed to delete this purchase");

			return await base.Delete(id);
		}
	}
}