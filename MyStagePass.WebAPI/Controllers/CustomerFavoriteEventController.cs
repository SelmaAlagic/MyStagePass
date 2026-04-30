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
	public class CustomerFavoriteEventController : BaseCRUDController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject, CustomerFavoriteEventInsertRequest, CustomerFavoriteEventUpdateRequest>
	{
		private readonly ICustomerFavoriteEventService _favoriteService;
		private readonly ICurrentUserService _currentUserService;
		public CustomerFavoriteEventController(ILogger<BaseController<Model.Models.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject>> logger, ICustomerFavoriteEventService service, ICurrentUserService currentUserService) : base(logger, service)
		{
			_favoriteService = service;
			_currentUserService=currentUserService;	
		}

		[HttpGet]
		public override async Task<PagedResult<CustomerFavoriteEvent>> Get([FromQuery] CustomerFavoriteEventSearchObject search)
		{
			search.CustomerID = _currentUserService.GetCustomerId();
			return await base.Get(search);
		}

		[HttpPost("toggle/{eventId}")]
		public async Task<IActionResult> Toggle(int eventId)
		{
			int customerId = _currentUserService.GetCustomerId();
			bool isFavorited = await _favoriteService.ToggleFavorite(customerId, eventId);
			return Ok(new { isFavorited });
		}
	}
}