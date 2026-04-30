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
	public class PerformerController : BaseCRUDController<Performer, PerformerSearchObject, PerformerInsertRequest, PerformerUpdateRequest>
	{
		private readonly IPerformerService _performerService;
		private readonly ICurrentUserService _currentUserService;

		public PerformerController(ILogger<BaseController<Performer, PerformerSearchObject>> logger, IPerformerService service, ICurrentUserService currentUserService) : base(logger, service)
		{
			_performerService = service;
			_currentUserService=currentUserService;
		}

		[HttpPost("register")]
		[AllowAnonymous]
		public override Task<Performer> Insert([FromBody] PerformerInsertRequest insert)
		{
			return base.Insert(insert);
		}

		[Authorize(Roles =Roles.Admin)]
		[HttpPut("{id}/approve")]
		public async Task<IActionResult> Approve(int id, [FromQuery] bool isApproved, [FromQuery] string? reason = null)
		{
			var result = await _performerService.ApprovePerformer(id, isApproved, reason);
			return Ok(result);
		}

		[Authorize(Roles = Roles.Admin + "," + Roles.Performer)]
		[HttpPut("{id}")]
		public override async Task<Performer> Update(int id, [FromBody] PerformerUpdateRequest update)
		{
			return await _performerService.Update(id, update);
		}

		[Authorize(Roles = Roles.Admin)]
		[HttpDelete("{id}")]
		public override async Task<Performer> Delete(int id)
		{
			return await base.Delete(id);
		}

		[Authorize(Roles = Roles.Performer)]
		[HttpGet("my-statistics")]
		public async Task<IActionResult> GetMyStatistics([FromQuery] int? month, [FromQuery] int? year, [FromQuery] int? eventId)
		{
			int performerId = _currentUserService.GetPerformerId();
			var result = await _performerService.GetMyStatistics(performerId, month, year, eventId);
			return Ok(result);
		}
	}
}