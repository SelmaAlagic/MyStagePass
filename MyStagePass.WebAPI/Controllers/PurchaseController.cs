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
	[Authorize(Roles = "Customer")]
	public class PurchaseController : BaseCRUDController<Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>
	{
		public PurchaseController(ILogger<BaseController<Purchase, PurchaseSearchObject>> logger, IPurchaseService service)
			: base(logger, service)
		{
		}

		[HttpGet]
		public override async Task<PagedResult<Purchase>> Get([FromQuery] PurchaseSearchObject search)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;
			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
				throw new UnauthorizedAccessException("Customer not authenticated");

			search.CustomerID = customerId;

			if (search.DateFrom != null && search.DateTo != null && search.DateFrom > search.DateTo)
			{
				return await Task.FromException<PagedResult<Purchase>>(new ArgumentException("Datum 'od' ne može biti veći od datuma 'do'."));
			}

			return await base.Get(search);
		}

		[HttpGet("my-events")]
		public async Task<PagedResult<Event>> GetMyEvents([FromQuery] PurchaseSearchObject search)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;
			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
				throw new UnauthorizedAccessException("Customer not authenticated");

			search.CustomerID = customerId;

			var eventService = _service as IPurchaseService;
			return await eventService.GetCustomerEvents(search);
		}

		[HttpPost]
		public override async Task<Purchase> Insert([FromBody] PurchaseInsertRequest request)
		{
			var userId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier).Value);
			request.CustomerID = userId;
			return await base.Insert(request);
		}

		[HttpGet("{id}")]
		public override async Task<Purchase> GetById(int id)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;
			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
				throw new UnauthorizedAccessException("Customer not authenticated");

			var purchase = await base.GetById(id);

			if (purchase.CustomerID != customerId)
				throw new UnauthorizedAccessException("You are not allowed to view this purchase");

			return purchase;
		}

		[HttpDelete("{id}")]
		public override async Task<Purchase> Delete(int id)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;
			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
				throw new UnauthorizedAccessException("Customer not authenticated");

			var purchase = await base.GetById(id);

			if (purchase.CustomerID != customerId)
				throw new UnauthorizedAccessException("You are not allowed to delete this purchase");

			return await base.Delete(id);
		}
	}
}