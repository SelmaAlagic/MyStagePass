using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class EventService : BaseCRUDService<Model.Models.Event, Event, EventSearchObject, EventInsertRequest, EventUpdateRequest>, IEventService
	{
		private readonly MyStagePassDbContext _context;
		private readonly IMapper _mapper;
		private readonly INotificationService _notificationService;

		public EventService(MyStagePassDbContext context, IMapper mapper, INotificationService notificationService) : base(context, mapper)
		{
			_context = context;
			_mapper = mapper;
			_notificationService = notificationService;
		}

		public override async Task BeforeInsert(Event entity, EventInsertRequest insert)
		{
			var location = await _context.Locations.FirstOrDefaultAsync(l => l.LocationID == insert.LocationID);
			if (location != null)
				entity.TotalTickets = location.Capacity;

			var pendingStatus = await _context.Statuses.FirstOrDefaultAsync(s => s.StatusName == "Pending");
			if (pendingStatus != null)
				entity.StatusID = pendingStatus.StatusID;

			entity.TicketsSold = 0; 
		}
		public override async Task<Model.Models.Event> Insert(EventInsertRequest insert)
		{
			var result = await base.Insert(insert);

			await _notificationService.NotifyUser(1, $"Event '{result.EventName}' has been created and is waiting for approval!");

			return result;
		}
		public override IQueryable<Event> AddInclude(IQueryable<Event> query, EventSearchObject? search = null)
		{
			query = query.Include(e => e.FavoritedByCustomers).Include(e => e.Status).Include(e=>e.Location).ThenInclude(e=>e.City).Include(e=>e.Performer).ThenInclude(e=>e.Events); 

			return base.AddInclude(query, search);
		}
		public override async Task<PagedResult<Model.Models.Event>> Get(EventSearchObject? search = null)
		{
			var result = await base.Get(search);

			foreach (var eventObj in result.Result)
			{
				if (eventObj.Performer != null && eventObj.Performer.Events != null)
				{
					eventObj.Performer.AverageRating = eventObj.Performer.Events
						.Where(e => e.RatingCount > 0)
						.Select(e => e.RatingAverage)
						.DefaultIfEmpty(0)
						.Average();
				}
			}
			return result;
		}
		public override IQueryable<Event> AddFilter(IQueryable<Event> query, EventSearchObject? search = null)
		{
			if (search == null)
				return query;

			if (search.PerformerID.HasValue)
				query = query.Where(e => e.PerformerID == search.PerformerID.Value);

			if (!string.IsNullOrWhiteSpace(search.searchTerm))
			{
				string lowerQuery = search.searchTerm.ToLower();
				query = query.Where(e =>
					e.EventName.ToLower().Contains(lowerQuery));
			};

			if (!string.IsNullOrWhiteSpace(search.Status))
			{
				query = query.Where(e => e.Status.StatusName.ToLower() == search.Status.ToLower());
			}

			if (search?.LocationID.HasValue == true)
			{
				query = query.Where(e => e.LocationID == search.LocationID.Value);
			}

			if (search.EventDateFrom != null)
				query = query.Where(e => e.EventDate >= search.EventDateFrom);

			if (search.EventDateTo != null)
				query = query.Where(e => e.EventDate <= search.EventDateTo);

			if (search.IsUpcoming != null)
			{
				if (search.IsUpcoming.Value)
					query = query.Where(e => e.EventDate >= DateTime.Now);
				else
					query = query.Where(e => e.EventDate < DateTime.Now); 
			}

			if (search.MaxPrice != null)
				query = query.Where(e => e.RegularPrice <= search.MaxPrice || e.VipPrice <= search.MaxPrice || e.PremiumPrice <= search.MaxPrice);

			if (search.MinPrice != null)
				query = query.Where(e => e.RegularPrice >= search.MinPrice || e.VipPrice >= search.MinPrice || e.PremiumPrice >= search.MinPrice);

			return query;
		}

		public async Task<Model.Models.Event> UpdateAdminStatus(int eventId, string newStatus)
		{

			var entity = await _context.Events.Include(e => e.Status).Include(e => e.Performer).FirstOrDefaultAsync(e => e.EventID == eventId);
			if (entity == null)
				throw new UserException("Event not found");

			var status = await _context.Statuses.FirstOrDefaultAsync(s => s.StatusName.ToLower() == newStatus.ToLower());
			if (status == null)
				throw new UserException("Status not found");
			
			entity.StatusID = status.StatusID;
			await _context.SaveChangesAsync();

			string statusLower = newStatus.ToLower();

			if (statusLower == "approved")
			{
				await _notificationService.NotifyUser(
					entity.Performer.UserID,
					$"Great news! Your event '{entity.EventName}' has been approved and is now live!"
				);

				var followerUserIds = await _context.CustomerFavoriteEvents
						.Include(f => f.Event)
						.Include(f => f.Customer)
							.ThenInclude(c => c.User)
						.Where(f => f.Event.PerformerID == entity.PerformerID)
						.Select(f => f.Customer.User.UserID)
						.Distinct()
						.ToListAsync();

				if (followerUserIds.Any())
				{
					var performer = await _context.Performers
						.FirstOrDefaultAsync(p => p.PerformerID == entity.PerformerID);

					if (performer != null)
					{
						await _notificationService.NotifyUsers(
							followerUserIds,
							$"Your favorite performer '{performer.ArtistName}' has added a new event '{entity.EventName}'!"
						);
					}
				}
			}
			else if (statusLower == "rejected")
			{
				await _notificationService.NotifyUser(
					entity.Performer.UserID,
					$"Unfortunately, your event '{entity.EventName}' was not approved."
				);
			}

			return _mapper.Map<Model.Models.Event>(entity);
		}
	}
}