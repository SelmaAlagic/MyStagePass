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
				throw new UserException("Datum 'od' ne može biti veći od datuma 'do'.");

			return await base.Get(search);
		}

		[HttpGet("my-events")]
		public async Task<PagedResult<Event>> GetMyEvents([FromQuery] PurchaseSearchObject search)
		{
			search.CustomerID = _currentUserService.GetCustomerId();
			var eventService = _service as IPurchaseService;
			return await eventService.GetCustomerEvents(search);
		}

		[NonAction]
		public override async Task<Purchase> Insert([FromBody] PurchaseInsertRequest request)
		{
			throw new UserException("Direct purchase is not allowed. Use /api/Payment/verify-and-purchase.");
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

		[NonAction]
		public override async Task<Purchase> Delete(int id)
		{
			throw new UserException("Purchases cannot be deleted.");
		}

		[NonAction]
		public override async Task<Purchase> Update(int id, [FromBody] PurchaseUpdateRequest request)
		{
			throw new UserException("Purchases cannot be updated.");
		}
	}
}