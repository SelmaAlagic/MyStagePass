using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class CountryService : BaseCRUDService<Model.Models.Country, Database.Country, CountrySearchObject, CountryInsertRequest, CountryUpdateRequest>, ICountryService
	{
		public CountryService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override async Task BeforeInsert(Country entity, CountryInsertRequest insert)
		{
			var exists = await _context.Countries
				.AnyAsync(x => x.Name.ToLower() == insert.Name.ToLower());

			if (exists)
			{
				throw new UserException("Country with this name already exists.");
			}

			await base.BeforeInsert(entity, insert);
		}
		public override IQueryable<Database.Country> AddFilter(IQueryable<Database.Country> query, CountrySearchObject? search = null)
		{
			if (search == null) return query;

			if (search?.IsActive.HasValue == true)
				query = query.Where(c => c.IsActive == search.IsActive.Value);

			if (!string.IsNullOrWhiteSpace(search.CountryName))
				query = query.Where(c => c.Name!.ToLower().Contains(search.CountryName.ToLower()));
			return query;
		}

		public override IQueryable<Country> AddInclude(IQueryable<Country> query, CountrySearchObject? search = null)
		{
			query = query.Include(c => c.Cities);
			return base.AddInclude(query, search);
		}
		public override async Task<Model.Models.Country> GetById(int id)
		{
			var entity = await _context.Countries
				.Include(c => c.Cities)
				.FirstOrDefaultAsync(c => c.CountryID == id);
			if (entity == null)
				throw new UserException("Country not found");
			return _mapper.Map<Model.Models.Country>(entity);
		}

		public override async Task<Model.Models.Country> Update(int id, CountryUpdateRequest update)
		{
			var entity = await _context.Countries.FindAsync(id);
			if (entity == null)
				throw new UserException("Country not found");

			if (!string.IsNullOrWhiteSpace(update.Name))
			{
				var exists = await _context.Countries
					.AnyAsync(x => x.Name.ToLower() == update.Name.ToLower() && x.CountryID != id);
				if (exists)
					throw new UserException("Country with this name already exists.");

				entity.Name = update.Name;
			}

			if (update.IsActive.HasValue)
				entity.IsActive = update.IsActive.Value;

			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Country>(entity);
		}

		public override async Task<Model.Models.Country> Delete(int id)
		{
			var entity = await _context.Countries
				.Include(c => c.Cities)
				.FirstOrDefaultAsync(c => c.CountryID == id);
			if (entity == null)
				throw new UserException("Country not found");
			if (entity.Cities != null && entity.Cities.Any(c => c.IsActive))
				throw new UserException("Cannot delete country that has active cities.");

			entity.IsActive = false; 
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Country>(entity);
		}
	}
}