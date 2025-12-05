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
	public class PerformerController : BaseCRUDController<Performer, PerformerSearchObject, PerformerInsertRequest, PerformerUpdateRequest>
	{
		public PerformerController(ILogger<BaseController<Performer, PerformerSearchObject>> logger, IPerformerService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		[HttpPost("register")]
		public override Task<Performer> Insert([FromBody] PerformerInsertRequest insert)
		{
			return base.Insert(insert);
		}
	}
}