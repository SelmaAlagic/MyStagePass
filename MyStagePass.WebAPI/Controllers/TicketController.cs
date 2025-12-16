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
	[Authorize]
	public class TicketController : BaseController<Ticket, TicketSearchObject>
	{
		public TicketController(ILogger<BaseController<Ticket, TicketSearchObject>> logger, ITicketService service) : base(logger, service)
		{
		}

		[Authorize(Roles = "Admin")]
		[HttpGet]
		public override async Task<PagedResult<Ticket>> Get([FromQuery] TicketSearchObject search)
		{
			return await base.Get(search);
		}

		[Authorize(Roles = "Customer")]
		[HttpGet("{id}")]
		public override async Task<Ticket> GetById(int id)
		{
			int customerID = int.Parse(User.FindFirst("RoleId").Value);

			var ticket = await base.GetById(id);

			if (ticket == null)
				throw new Exception("Ticket not found");

			if (ticket.Purchase == null)
				throw new Exception("Ticket purchase information is missing");

			if (ticket.Purchase.CustomerID != customerID)
				throw new UnauthorizedAccessException("You don't have permission to view this ticket");

			return ticket;
		}
	}
}