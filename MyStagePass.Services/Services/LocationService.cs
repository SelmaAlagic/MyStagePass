using AutoMapper;
using Microsoft.EntityFrameworkCore;
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

			if (search.CapacityFrom != null)
				query = query.Where(l => l.Capacity >= search.CapacityFrom);

			if (search.CapacityTo != null)
				query = query.Where(l => l.Capacity <= search.CapacityTo);

			return query;
		}
		public override async Task BeforeInsert(Database.Location entity, LocationInsertRequest insert)
		{
			if (string.IsNullOrWhiteSpace(insert.LocationName))
				throw new Exception("Location name is required.");

			if (string.IsNullOrWhiteSpace(insert.Address))
				throw new Exception("Address is required.");

			if (insert.Capacity <= 0)
				throw new Exception("Capacity must be greater than zero.");

			var cityExists = await _context.Cities.AnyAsync(c => c.CityID == insert.CityID);
			if (!cityExists)
				throw new Exception("City does not exist.");
		}
	}
}