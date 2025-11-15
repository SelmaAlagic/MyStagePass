using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class TicketService : BaseService<Model.Models.Ticket, Database.Ticket, TicketSearchObject>, ITicketService
	{
		public TicketService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<Database.Ticket> AddInclude(IQueryable<Database.Ticket> query, TicketSearchObject? search = null)
		{
			return base.AddInclude(query, search);
		}

	}
}
