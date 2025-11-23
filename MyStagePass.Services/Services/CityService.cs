using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class CityService : BaseService<Model.Models.City, Database.City, CitySearchObject>, ICityService
	{
		public CityService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<City> AddInclude(IQueryable<City> query, CitySearchObject? search = null)
		{
			query = query.Include(c => c.Locations);

			return base.AddInclude(query, search);
		}

		public override async Task<Model.Models.City> GetById(int id)
		{
			var entity = await _context.Cities
				.Include(c => c.Locations)
				.FirstOrDefaultAsync(c => c.CityID == id);

			return _mapper.Map<Model.Models.City>(entity);
		}
	}
}