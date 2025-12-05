using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles = "Customer")]
	public class PurchaseController : BaseController<Purchase, PurchaseSearchObject>
	{
		public PurchaseController(ILogger<BaseController<Purchase, PurchaseSearchObject>> logger, IPurchaseService service) : base(logger, service)
		{
		}

		[HttpGet]
		public override async Task<PagedResult<Purchase>> Get([FromQuery] PurchaseSearchObject search)
		{
			int customerID = int.Parse(User.FindFirst("RoleId").Value);
			search.CustomerID = customerID;

			if (search.DateFrom != null && search.DateTo != null && search.DateFrom > search.DateTo)
			{
				return await Task.FromException<PagedResult<Purchase>>(new ArgumentException("Datum 'od' ne može biti veći od datuma 'do'."));
			}

			return await base.Get(search);
		}

		[HttpDelete("{id}")]
		public async Task<IActionResult> SoftDelete(int id)
		{
			var purchaseService = _service as IPurchaseService;
			if (purchaseService == null)
				return BadRequest("Service not available");
			await purchaseService.SoftDelete(id);
			return Ok("Purchase successfully soft-deleted!");
		}
	}
}