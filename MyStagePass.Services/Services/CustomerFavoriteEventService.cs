using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class CustomerFavoriteEventService : BaseCRUDService<Model.Models.CustomerFavoriteEvent, Database.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject, CustomerFavoriteEventInsertRequest, CustomerFavoriteEventUpdateRequest>, ICustomerFavoriteEventService
	{
		public CustomerFavoriteEventService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<Database.CustomerFavoriteEvent> AddFilter(IQueryable<Database.CustomerFavoriteEvent> query, CustomerFavoriteEventSearchObject? search = null)
		{
			if (search == null)
				return query;

			if (search.CustomerID.HasValue)
				query = query.Where(f => f.CustomerID == search.CustomerID.Value);

			return query;
		}

		public override IQueryable<Database.CustomerFavoriteEvent> AddInclude(IQueryable<Database.CustomerFavoriteEvent> query, CustomerFavoriteEventSearchObject? search = null)
		{
			return query.Include(x => x.Event)
			   .ThenInclude(x => x.Performer)
			   .ThenInclude(x => x.User)
			   .Include(x => x.Event)
			   .ThenInclude(x => x.Location);
		}

		public async Task<bool> ToggleFavorite(int customerId, int eventId)
		{
			var existing = await _context.CustomerFavoriteEvents
				.FirstOrDefaultAsync(f => f.CustomerID == customerId && f.EventID == eventId);

			if (existing != null)
			{
				_context.CustomerFavoriteEvents.Remove(existing);
				await _context.SaveChangesAsync();
				return false; 
			}

			var newFavorite = new Database.CustomerFavoriteEvent
			{
				CustomerID = customerId,
				EventID = eventId
			};
			_context.CustomerFavoriteEvents.Add(newFavorite);
			await _context.SaveChangesAsync();
			return true; 
		}
	}
}