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
	public class CustomerFavoriteEventController : BaseCRUDController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject, CustomerFavoriteEventInsertRequest, CustomerFavoriteEventUpdateRequest>
	{
		private readonly ICustomerFavoriteEventService _favoriteService;
		public CustomerFavoriteEventController(ILogger<BaseController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject>> logger, ICustomerFavoriteEventService service) : base(logger, service)
		{
			_favoriteService = service;
		}

		[HttpGet]
		public override async Task<PagedResult<CustomerFavoriteEvent>> Get([FromQuery] CustomerFavoriteEventSearchObject search)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;

			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
				throw new UnauthorizedAccessException("Customer not authenticated");

			search.CustomerID = customerId;

			return await base.Get(search);
		}

		[HttpPost("toggle/{eventId}")]
		public async Task<IActionResult> Toggle(int eventId)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;
			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
				throw new UnauthorizedAccessException("Customer not authenticated");

			bool isFavorited = await _favoriteService.ToggleFavorite(customerId, eventId);
			return Ok(new { isFavorited });
		}
	}
}