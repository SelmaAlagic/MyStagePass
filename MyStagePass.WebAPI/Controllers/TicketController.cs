using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles = Roles.Customer)]
	public class TicketController : BaseController<Ticket, TicketSearchObject>
	{
		private readonly ICurrentUserService _currentUserService;

		public TicketController(ILogger<BaseController<Ticket, TicketSearchObject>> logger, ITicketService service, ICurrentUserService currentUserService) : base(logger, service)
		{
			_currentUserService=currentUserService;
		}

		[HttpGet]
		public override async Task<PagedResult<Ticket>> Get([FromQuery] TicketSearchObject search)
		{
			search.CustomerID = _currentUserService.GetCustomerId();
			return await base.Get(search);
		}

		[HttpGet("{id}")]
		public override async Task<Ticket> GetById(int id)
		{
			int customerID = _currentUserService.GetCustomerId();
			var ticket = await base.GetById(id);

			if (ticket == null)
				throw new UserException("Ticket not found");

			if (ticket.Purchase == null)
				throw new UserException("Ticket purchase information is missing");

			if (ticket.Purchase.CustomerID != customerID)
				throw new UnauthorizedAccessException("You don't have permission to view this ticket");

			return ticket;
		}
	}
}