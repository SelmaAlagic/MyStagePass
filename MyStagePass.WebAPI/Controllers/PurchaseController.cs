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
			int customerID = int.Parse(User.FindFirst("RoleId").Value);
			search.CustomerID = customerID;

			if (search.DateFrom != null && search.DateTo != null && search.DateFrom > search.DateTo)
			{
				return await Task.FromException<PagedResult<Purchase>>(new ArgumentException("Datum 'od' ne može biti veći od datuma 'do'."));
			}

			return await base.Get(search);
		}

		[HttpPost]
		public override async Task<Purchase> Insert([FromBody] PurchaseInsertRequest request)
		{
			var userId = int.Parse(User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier).Value);
			request.CustomerID = userId;

			return await base.Insert(request);
		}

		[HttpDelete("{id}")]
		public override async Task<Purchase> Delete(int id)
		{
			return await base.Delete(id);
		}
	}
}