using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class TicketController : BaseController<Ticket, TicketSearchObject>
	{
		public TicketController(ILogger<BaseController<Ticket, TicketSearchObject>> logger, ITicketService service) : base(logger, service)
		{
		}
	}
}
