using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;
using MyStagePass.Services.Services;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class PerformerController : BaseCRUDController<Performer, PerformerSearchObject, PerformerInsertRequest, PerformerUpdateRequest>
	{
		private readonly IPerformerService _performerService;
		public PerformerController(ILogger<BaseController<Performer, PerformerSearchObject>> logger, IPerformerService service) : base(logger, service)
		{
			_performerService = service;
		}

		[AllowAnonymous]
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
	}
}