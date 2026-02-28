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
	[Authorize(Roles = "Customer")]
	public class TicketController : BaseController<Ticket, TicketSearchObject>
	{
		public TicketController(ILogger<BaseController<Ticket, TicketSearchObject>> logger, ITicketService service) : base(logger, service)
		{
		}

		[HttpGet]
		public override async Task<PagedResult<Ticket>> Get([FromQuery] TicketSearchObject search)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;
			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerId))
				throw new UnauthorizedAccessException("Customer not authenticated");

			search.CustomerID = customerId;
			return await base.Get(search);
		}

		[HttpGet("{id}")]
		public override async Task<Ticket> GetById(int id)
		{
			var customerIdClaim = User.FindFirst("CustomerID")?.Value;
			if (string.IsNullOrEmpty(customerIdClaim) || !int.TryParse(customerIdClaim, out int customerID))
				throw new UnauthorizedAccessException("Customer not authenticated");

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