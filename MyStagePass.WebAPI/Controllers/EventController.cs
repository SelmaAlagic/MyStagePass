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
	public class EventController : BaseCRUDController<Event, EventSearchObject, EventInsertRequest, EventUpdateRequest>
	{
		public EventController(ILogger<BaseController<Event, EventSearchObject>> logger, IEventService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		[HttpGet]
		public override async Task<PagedResult<Event>> Get([FromQuery] EventSearchObject search)
		{
			search.Status = "Approved";
			return await base.Get(search);
		}

		[Authorize(Roles = "Performer")]
		[HttpGet("my-events")]
		public async Task<PagedResult<Event>> GetMyEvents([FromQuery] EventSearchObject search)
		{
			var performerIdClaim = User.FindFirst("PerformerID")?.Value;

			if (string.IsNullOrEmpty(performerIdClaim) || !int.TryParse(performerIdClaim, out int performerId))
				throw new UnauthorizedAccessException("Performer not authenticated");

			search.PerformerID = performerId;
			return await base.Get(search);
		}

		[Authorize(Roles = "Admin")]
		[HttpGet("admin/all")]
		public async Task<PagedResult<Event>> GetAllForAdmin([FromQuery] EventSearchObject search)
		{
			return await base.Get(search);
		}

		[Authorize(Roles = "Performer")]
		[HttpPost]
		public override async Task<Event> Insert([FromBody] EventInsertRequest insert)
		{
			var performerIdClaim = User.FindFirst("PerformerID")?.Value;

			if (string.IsNullOrEmpty(performerIdClaim) || !int.TryParse(performerIdClaim, out int performerId))
				throw new UnauthorizedAccessException("Performer not authenticated");

			insert.PerformerID = performerId;

			return await base.Insert(insert);
		}


		[Authorize(Roles = "Admin")]
		[HttpPut("{id}/status")]
		public async Task<IActionResult> ApproveEvent(int id, [FromQuery] string newStatus)
		{
			var eventService = _service as IEventService;
			if (eventService == null)
				return BadRequest("Service not available");

			try
			{
				await eventService.UpdateAdminStatus(id, newStatus);
				return Ok($"Event status updated to {newStatus} successfully!");
			}
			catch (Exception ex)
			{
				return BadRequest(ex.Message);
			}
		}

		[Authorize(Roles = "Performer")]
		[HttpPut("{id}")]
		public override async Task<Event> Update(int id, [FromBody] EventUpdateRequest update)
		{
			var existingEvent = await (_service as IEventService).GetById(id);
			if (existingEvent == null)
				throw new Exception("Event not found");

			var performerIdClaim = User.FindFirst("PerformerID")?.Value;

			if (string.IsNullOrEmpty(performerIdClaim) || !int.TryParse(performerIdClaim, out int performerId))
				throw new UnauthorizedAccessException("Performer not authenticated");

			if (existingEvent.PerformerID != performerId)
				throw new Exception("You can only update your own events");

			return await base.Update(id, update);
		}

		[Authorize(Roles = "Admin")]
		[HttpDelete("{id}")]
		public override async Task<Event> Delete(int id)
		{
			return await base.Delete(id);
		}
	}
}