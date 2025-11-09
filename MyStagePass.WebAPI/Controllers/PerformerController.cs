using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class PerformerController : BaseCRUDController<Performer, PerformerSearchObject, PerformerInsetRequest, PerformerUpdateRequest>
	{
		public PerformerController(ILogger<BaseController<Performer, PerformerSearchObject>> logger, IPerformerService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		public override Task<Performer> Insert([FromBody] PerformerInsetRequest insert)
		{
			return base.Insert(insert);
		}
	}
}
