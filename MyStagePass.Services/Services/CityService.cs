using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class CityService : BaseCRUDService<Model.Models.City, Database.City, CitySearchObject, CityInsertRequest, CityUpdateRequest>, ICityService
	{
		public CityService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override async Task BeforeInsert(City entity, CityInsertRequest insert)
		{
			var countryExists = await _context.Countries.AnyAsync(c => c.CountryID == insert.CountryID);
			if (!countryExists)
				throw new UserException("Country does not exist.");

			var exists = await _context.Cities
				.AnyAsync(x =>
					x.CountryID == insert.CountryID &&
					x.Name.ToLower() == insert.Name.ToLower());

			if (exists)
			{
				throw new UserException("City with the same name already exists in this country.");
			}

			await base.BeforeInsert(entity, insert);
		}

		public override IQueryable<City> AddInclude(IQueryable<City> query, CitySearchObject? search = null)
		{
			query = query.Include(c => c.Locations).Include(c=>c.Country);
			return base.AddInclude(query, search);
		}

		public override IQueryable<Database.City> AddFilter(IQueryable<Database.City> query, CitySearchObject? search = null)
		{
			if (search == null) return query;
			if (search?.IsActive.HasValue == true)
				query = query.Where(c => c.IsActive == search.IsActive.Value);

			if (!string.IsNullOrWhiteSpace(search.CityName))
				query = query.Where(c => c.Name!.ToLower().Contains(search.CityName.ToLower()));

			if (search.CountryID.HasValue) 
				query = query.Where(c => c.CountryID == search.CountryID.Value);

			return query;
		}

		public override async Task<Model.Models.City> GetById(int id)
		{
			var entity = await _context.Cities
				.Include(c => c.Locations)
				.FirstOrDefaultAsync(c => c.CityID == id);
			if (entity == null)
				throw new UserException("City not found");
			return _mapper.Map<Model.Models.City>(entity);
		}

		public override async Task<Model.Models.City> Update(int id, CityUpdateRequest update)
		{
			var entity = await _context.Cities.FindAsync(id);
			if (entity == null)
				throw new UserException("City not found");

			var newName = !string.IsNullOrWhiteSpace(update.Name) ? update.Name : entity.Name;
			var newCountryId = update.CountryID ?? entity.CountryID;

			var exists = await _context.Cities
				.AnyAsync(x =>
					x.Name.ToLower() == newName.ToLower() &&
					x.CountryID == newCountryId &&
					x.CityID != id);
			if (exists)
				throw new UserException("City with the same name already exists in this country.");

			if (!string.IsNullOrWhiteSpace(update.Name))
				entity.Name = update.Name;
			if (update.CountryID.HasValue)
				entity.CountryID = update.CountryID.Value;
			if (update.IsActive.HasValue)
				entity.IsActive = update.IsActive.Value;

			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.City>(entity);
		}

		public override async Task<Model.Models.City> Delete(int id)
		{
			var entity = await _context.Cities
				.Include(c => c.Locations)
				.FirstOrDefaultAsync(c => c.CityID == id);
			if (entity == null)
				throw new UserException("City not found");
			if (entity.Locations != null && entity.Locations.Any(l => l.IsActive))
				throw new UserException("Cannot delete city that has active locations.");

			entity.IsActive = false; 
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.City>(entity);
		}
	}
}