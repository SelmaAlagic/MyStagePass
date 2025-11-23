using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class StatusService : BaseService<Model.Models.Status, Database.Status, StatusSearchObject>, IStatusService
	{
		public StatusService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Database.Status> AddInclude(IQueryable<Database.Status> query, StatusSearchObject? search = null)
		{
			query = query.Include(e => e.Events);
			return base.AddInclude(query, search);
		}
		public override async Task<Model.Models.Status> GetById(int id)
		{
			var query = _context.Set<Database.Status>().AsQueryable();

			query = AddInclude(query);

			var entity = await query.FirstOrDefaultAsync(s => s.StatusID == id);

			if (entity == null)
				throw new Exception("Status not found");

			return _mapper.Map<Model.Models.Status>(entity);
		}
	}
}