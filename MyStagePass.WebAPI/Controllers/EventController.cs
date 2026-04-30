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
	[Authorize]
	public class EventController : BaseCRUDController<Event, EventSearchObject, EventInsertRequest, EventUpdateRequest>
	{
		private readonly ICurrentUserService _currentUserService;

		public EventController(ILogger<BaseController<Event, EventSearchObject>> logger, IEventService service, ICurrentUserService currentUserService) : base(logger, service)
		{
			_currentUserService=currentUserService;
		}

		[AllowAnonymous]
		[HttpGet]
		public override async Task<PagedResult<Event>> Get([FromQuery] EventSearchObject search)
		{
			search.IncludeCancelled = true;
			return await base.Get(search);
		}

		[Authorize(Roles = Roles.Performer)]
		[HttpGet("my-events")]
		public async Task<PagedResult<Event>> GetMyEvents([FromQuery] EventSearchObject search)
		{
			search.PerformerID = _currentUserService.GetPerformerId();
			return await base.Get(search);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpGet("admin/all")]
		public async Task<PagedResult<Event>> GetAllForAdmin([FromQuery] EventSearchObject search)
		{
			return await base.Get(search);
		}

		[Authorize(Roles = Roles.Performer)]
		[HttpPost]
		public override async Task<Event> Insert([FromBody] EventInsertRequest insert)
		{
			insert.PerformerID = _currentUserService.GetPerformerId();
			return await base.Insert(insert);
		}


		[Authorize(Roles = Roles.Admin)]
		[HttpPut("{id}/status")]
		public async Task<IActionResult> ApproveEvent(int id, [FromQuery] string newStatus)
		{
			var eventService = _service as IEventService;
			await eventService.UpdateAdminStatus(id, newStatus);
			return Ok($"Event status updated to {newStatus} successfully!");
		}

		[Authorize(Roles = Roles.Performer)]
		[HttpPut("{id}")]
		public override async Task<Event> Update(int id, [FromBody] EventUpdateRequest update)
		{
			return await base.Update(id, update);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpDelete("{id}")]
		public override async Task<Event> Delete(int id)
		{
			return await base.Delete(id);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpPut("{id}/cancel")]
		public async Task<IActionResult> Cancel(int id, [FromQuery] string? reason = null)
		{
			var eventService = _service as IEventService;
			var result = await eventService.CancelEvent(id, reason);
			return Ok(result);
		}
	}
}