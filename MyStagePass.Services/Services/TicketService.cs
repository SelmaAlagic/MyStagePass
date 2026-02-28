using AutoMapper;
using Microsoft.EntityFrameworkCore;
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
			query = query
				.Include(t => t.Event)
					.ThenInclude(e => e.Location)
						.ThenInclude(l => l.City)
				.Include(t => t.Event)
					.ThenInclude(e => e.Performer);
			query = query.Where(p => !p.IsDeleted);
			return base.AddInclude(query, search);
		}

		public override IQueryable<Database.Ticket> AddFilter(IQueryable<Database.Ticket> query, TicketSearchObject? search = null)
		{
			query = query.Where(t => !t.IsDeleted);

			if (search?.CustomerID.HasValue == true)
				query = query.Where(t => t.Purchase.CustomerID == search.CustomerID.Value);

			return query;
		}

		public override async Task<Model.Models.Ticket?> GetById(int id)
		{
			var query = _context.Set<Database.Ticket>().AsQueryable();
			query = AddInclude(query);
			var entity = await query.FirstOrDefaultAsync(t => t.TicketID == id);
			return entity != null ? _mapper.Map<Model.Models.Ticket>(entity) : null;
		}
	}
}