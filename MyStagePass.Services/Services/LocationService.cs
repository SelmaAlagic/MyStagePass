using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;


namespace MyStagePass.Services.Services
{
	public class LocationService : BaseCRUDService<Model.Models.Location, Database.Location, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>, ILocationService
	{
		public LocationService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override async Task BeforeInsert(Database.Location entity, LocationInsertRequest insert)
		{
			var cityExists = await _context.Cities.AnyAsync(c => c.CityID == insert.CityID);
			if (!cityExists)
				throw new UserException("City does not exist.");

			var exists = await _context.Locations
				.AnyAsync(x =>
					x.CityID == insert.CityID &&
					x.Address.ToLower() == insert.Address.ToLower() &&
					x.LocationName.ToLower() == insert.LocationName.ToLower());

			if (exists)
				throw new UserException("Location with this name and address already exists in this city.");

			await base.BeforeInsert(entity, insert);
		}

		public override IQueryable<Database.Location> AddInclude(IQueryable<Database.Location> query, LocationSearchObject? search = null)
		{
			return query.Include(l => l.Events).Include(l=>l.City);
		}

		public override IQueryable<Database.Location> AddFilter(IQueryable<Database.Location> query, LocationSearchObject? search = null)
		{
			if (search == null)
				return query;

			if (!string.IsNullOrWhiteSpace(search.LocationName))
				query = query.Where(l => l.LocationName!.ToLower().Contains(search.LocationName.ToLower()));

			if (!string.IsNullOrWhiteSpace(search.Address))
				query = query.Where(l => l.Address!.ToLower().Contains(search.Address.ToLower()));

			if (search?.CityID.HasValue == true)
				query = query.Where(l => l.CityID == search.CityID.Value);

			if (search?.IsActive.HasValue == true)
				query = query.Where(l => l.IsActive == search.IsActive.Value);

			return query;
		}

		public override async Task<Model.Models.Location> Update(int id, LocationUpdateRequest update)
		{
			var entity = await _context.Locations.FindAsync(id);
			if (entity == null)
				throw new UserException("Location not found");

			var newName = !string.IsNullOrWhiteSpace(update.LocationName) ? update.LocationName : entity.LocationName;
			var newAddress = !string.IsNullOrWhiteSpace(update.Address) ? update.Address : entity.Address;
			var newCityId = update.CityID ?? entity.CityID;

			var exists = await _context.Locations
				.AnyAsync(x =>
					x.LocationName.ToLower() == newName.ToLower() &&
					x.Address.ToLower() == newAddress.ToLower() &&
					x.CityID == newCityId &&
					x.LocationID != id);
			if (exists)
				throw new UserException("Location with this name and address already exists in this city.");

			if (!string.IsNullOrWhiteSpace(update.LocationName))
				entity.LocationName = update.LocationName;
			if (!string.IsNullOrWhiteSpace(update.Address))
				entity.Address = update.Address;
			if (update.Capacity.HasValue)
				entity.Capacity = update.Capacity.Value;
			if (update.CityID.HasValue)
				entity.CityID = update.CityID.Value;
			if (update.IsActive.HasValue)
				entity.IsActive = update.IsActive.Value;

			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Location>(entity);
		}

		public override async Task<Model.Models.Location> Delete(int id)
		{
			var entity = await _context.Locations
				.Include(l => l.Events)
				.FirstOrDefaultAsync(l => l.LocationID == id);
			if (entity == null)
				throw new UserException("Location not found");
			if (entity.Events != null && entity.Events.Any())
				throw new UserException("Cannot delete location that has events assigned to it.");
			entity.IsActive = false; 
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Location>(entity);
		}
	}
}