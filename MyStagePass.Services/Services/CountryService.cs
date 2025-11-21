using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class CountryService : BaseService<Model.Models.Country, Database.Country, CountrySearchObject>, ICountryService
	{
		public CountryService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override async Task<Model.Models.Country> GetById(int id)
		{
			var entity = await _context.Countries
			.Include(c => c.Cities)
				.FirstOrDefaultAsync(c => c.CountryID == id);

			return _mapper.Map<Model.Models.Country>(entity);
		}
	}
}
