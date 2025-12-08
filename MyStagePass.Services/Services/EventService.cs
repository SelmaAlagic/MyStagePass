using AutoMapper;
using Microsoft.EntityFrameworkCore;
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
			query = query.Include(e => e.FavoritedByCustomers).Include(e => e.Status); 

			return base.AddInclude(query, search);
		}
		public override IQueryable<Event> AddFilter(IQueryable<Event> query, EventSearchObject? search = null)
		{
			if (search == null)
				return query;

			if (search.PerformerID.HasValue)
				query = query.Where(e => e.PerformerID == search.PerformerID.Value);

			if (!string.IsNullOrEmpty(search.Status))
				query = query.Where(e => e.Status.StatusName == search.Status);

			if (!string.IsNullOrEmpty(search.EventName))
				query = query.Where(e => e.EventName!.ToLower().Contains(search.EventName.ToLower()));

			if (!string.IsNullOrEmpty(search.Location))
				query = query.Where(e => e.Location.LocationName!.ToLower().Contains(search.Location.ToLower()));

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
				throw new Exception("Event not found");

			var status = await _context.Statuses.FirstOrDefaultAsync(s => s.StatusName.ToLower() == newStatus.ToLower());
			if (status == null)
				throw new Exception("Status not found");
			
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