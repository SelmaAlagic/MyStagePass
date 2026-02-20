using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[AllowAnonymous]
	public class PerformerController : BaseCRUDController<Performer, PerformerSearchObject, PerformerInsertRequest, PerformerUpdateRequest>
	{
		private readonly IPerformerService _performerService;
		public PerformerController(ILogger<BaseController<Performer, PerformerSearchObject>> logger, IPerformerService service) : base(logger, service)
		{
			_performerService = service;
		}

		[HttpPost("register")]
		public override Task<Performer> Insert([FromBody] PerformerInsertRequest insert)
		{
			return base.Insert(insert);
		}

		[Authorize(Roles ="Admin")]
		[HttpPut("{id}/approve")]
		public async Task<IActionResult> Approve(int id, [FromQuery] bool isApproved)
		{
			var result = await _performerService.ApprovePerformer(id, isApproved);
			if (result == null)
				return NotFound();
			return Ok(result);
		}

		[Authorize(Roles = "Admin,Performer")]
		[HttpPut("{id}")]
		public override async Task<Performer> Update(int id, [FromBody] PerformerUpdateRequest update)
		{
			var isAdmin = User.IsInRole("Admin");
			if (!isAdmin)
			{
				var performerIdClaim = User.FindFirst("PerformerID")?.Value;
				if (string.IsNullOrEmpty(performerIdClaim))
					throw new UnauthorizedAccessException("Invalid token");
				int tokenPerformerId = int.Parse(performerIdClaim);
				if (tokenPerformerId != id)
					throw new UnauthorizedAccessException("You can only update your own profile");
			}
			return await _performerService.Update(id, update);
		}

		[Authorize(Roles = "Admin")]
		[HttpDelete("{id}")]
		public override async Task<Performer> Delete(int id)
		{
			return await base.Delete(id);
		}
	}
}