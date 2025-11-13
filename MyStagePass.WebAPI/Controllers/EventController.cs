using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class EventController : BaseCRUDController<Event, EventSearchObject, EventInsertRequest, EventUpdateRequest>
	{
		public EventController(ILogger<BaseController<Event, EventSearchObject>> logger, IEventService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		public override Task<Event> Insert([FromBody] EventInsertRequest insert)
		{
			return base.Insert(insert);
		}
	}
}
