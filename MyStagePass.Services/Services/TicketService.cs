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
			query = query.Include(t => t.Purchase).Include(t => t.Event);
			query = query.Where(p => !p.IsDeleted);
			return base.AddInclude(query, search);
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