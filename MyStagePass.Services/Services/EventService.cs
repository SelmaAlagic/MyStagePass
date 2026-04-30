using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class EventService : BaseCRUDService<Model.Models.Event, Event, EventSearchObject, EventInsertRequest, EventUpdateRequest>, IEventService
	{
		private readonly INotificationService _notificationService;
		private readonly ILogger<EventService> _logger;
		private readonly IRabbitMQProducer _rabbitMQProducer;
		private readonly ICurrentUserService _currentUserService;
		public EventService(MyStagePassDbContext context, IMapper mapper, INotificationService notificationService, ILogger<EventService> logger, IRabbitMQProducer rabbitMQProducer, ICurrentUserService currentUserService) : base(context, mapper)
		{
			_notificationService = notificationService;
			_logger = logger;
			_rabbitMQProducer = rabbitMQProducer;
			_currentUserService=currentUserService;
		}

		public override async Task BeforeInsert(Event entity, EventInsertRequest insert)
		{
			if (insert.RegularPrice <= 0 || insert.VipPrice <= 0 || insert.PremiumPrice <= 0)
				throw new UserException("Ticket prices must be greater than 0.");

			var location = await _context.Locations.FirstOrDefaultAsync(l => l.LocationID == insert.LocationID);
			if (location != null)
				entity.TotalTickets = location.Capacity;

			await ValidateLocationAvailability(insert.LocationID, insert.EventDate);

			entity.StatusID = Status.PendingID;
			entity.CreatedAt = DateTime.UtcNow;
			entity.TicketsSold = 0;
		}

		public override async Task<Model.Models.Event> Insert(EventInsertRequest insert)
		{
			await ValidateLocationAvailability(insert.LocationID, insert.EventDate);

			var result = await base.Insert(insert);

			var admins = await _context.Users
				.Where(u => u.Admins.Any())
				.ToListAsync();

			foreach (var admin in admins)
			{
				await _notificationService.NotifyUser(
					admin.UserID,
					"New Event Submitted",
					$"Event '{result.EventName}' has been submitted and is waiting for approval!"
				);
			}

			return result;
		}

		public override IQueryable<Event> AddInclude(IQueryable<Event> query, EventSearchObject? search = null)
		{
			query = query
				.Include(e => e.FavoritedByCustomers)
				.Include(e => e.Status)
				.Include(e => e.Location).ThenInclude(e => e.City)
				.Include(e => e.Performer).ThenInclude(p => p.User)
				.Include(e => e.Performer).ThenInclude(e => e.Events);

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
						.Select(e => (float)e.TotalScore / e.RatingCount)
						.DefaultIfEmpty(0)
						.Average();
				}
			}
			return result;
		}

		private async Task ValidateLocationAvailability(int locationId, DateTime eventDate, int? excludeEventId = null)
		{
			var events = await _context.Events
				.Where(e =>
					e.LocationID == locationId &&
					e.StatusID != Status.CancelledID &&
					e.StatusID != Status.RejectedID &&
					(excludeEventId == null || e.EventID != excludeEventId))
				.ToListAsync();

			foreach (var existingEvent in events)
			{
				var diff = Math.Abs((existingEvent.EventDate - eventDate).TotalHours);

				if (diff < 2)
				{
					throw new UserException(
						$"This location is already booked for '{existingEvent.EventName}' on " +
						$"{existingEvent.EventDate:MMMM dd, yyyy} at {existingEvent.EventDate:HH:mm}. " +
						$"Events at the same location must be at least 2 hours apart."
					);
				}
			}
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
					e.EventName.ToLower().Contains(lowerQuery) ||
					e.Location.LocationName.ToLower().Contains(lowerQuery) ||
					(e.Location.City != null && e.Location.City.Name.ToLower().Contains(lowerQuery)));
			}

			if (search.IncludeCancelled == true)
			{
				query = query.Where(e =>
					(e.StatusID == Status.ApprovedID || e.StatusID == Status.CancelledID)
					&& e.EventDate >= DateTime.UtcNow);
			}

			if (!string.IsNullOrWhiteSpace(search.Status))
			{
				query = query.Where(e => e.Status.StatusName.ToLower() == search.Status.ToLower());
			}

			if (search?.LocationID.HasValue == true)
			{
				query = query.Where(e => e.LocationID == search.LocationID.Value);
			}

			if (search.EventDateFrom != null)
				query = query.Where(e => e.EventDate >= search.EventDateFrom.Value.Date);

			if (search.EventDateTo != null)
			{
				var endDate = search.EventDateTo.Value.Date.AddDays(1);
				query = query.Where(e => e.EventDate < endDate);
			}

			if (search.IsUpcoming != null)
			{
				if (search.IsUpcoming.Value)
					query = query.Where(e => e.EventDate >= DateTime.UtcNow);
				else
					query = query.Where(e => e.EventDate < DateTime.UtcNow);
			}

			if (search.MaxPrice != null)
				query = query.Where(e => e.RegularPrice <= search.MaxPrice || e.VipPrice <= search.MaxPrice || e.PremiumPrice <= search.MaxPrice);

			if (search.MinPrice != null)
				query = query.Where(e => e.RegularPrice >= search.MinPrice || e.VipPrice >= search.MinPrice || e.PremiumPrice >= search.MinPrice);

			query = query.OrderByDescending(e => e.CreatedAt);
			return query;
		}

		public async Task<Model.Models.Event> UpdateAdminStatus(int eventId, string newStatus)
		{
			var entity = await _context.Events
				.Include(e => e.Status)
				.Include(e => e.Performer)
				.FirstOrDefaultAsync(e => e.EventID == eventId);

			if (entity == null)
				throw new UserException("Event not found");

			var allowedTransitions = new Dictionary<int, List<int>>
			{
				{ Status.PendingID,  new List<int> { Status.ApprovedID, Status.RejectedID } },
				{ Status.ApprovedID, new List<int> { Status.CancelledID } },
				{ Status.RejectedID, new List<int> { Status.PendingID, Status.ApprovedID } },
				{ Status.CancelledID, new List<int>() }
			};

			var status = await _context.Statuses
				.FirstOrDefaultAsync(s => s.StatusName.ToLower() == newStatus.ToLower());

			if (status == null)
				throw new UserException("Status not found");

			if (!allowedTransitions.ContainsKey(entity.StatusID) ||
				!allowedTransitions[entity.StatusID].Contains(status.StatusID))
				throw new UserException($"Cannot transition from '{entity.Status.StatusName}' to '{newStatus}'.");

			entity.StatusID = status.StatusID;
			entity.StatusChangedAt = DateTime.UtcNow;
			entity.ApprovedByAdminID = _currentUserService.GetUserId();
			await _context.SaveChangesAsync();

			if (status.StatusID == Status.ApprovedID)
			{
				await _notificationService.NotifyUser(
					entity.Performer.UserID,
					"Event Status Update",
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
							"New Event From Favorite Performer",
							$"{performer.ArtistName} has added a new event!"
						);
					}
				}
			}
			else if (status.StatusID == Status.RejectedID)
			{
				await _notificationService.NotifyUser(
					entity.Performer.UserID,
					"Event Status Update",
					$"Unfortunately, your event '{entity.EventName}' was not approved."
				);
			}

			return _mapper.Map<Model.Models.Event>(entity);
		}

		public override async Task<Model.Models.Event> Update(int id, EventUpdateRequest update)
		{
			var existing = await _context.Events.FindAsync(id);
			if (existing == null)
				throw new UserException("Event not found");

			int performerId = _currentUserService.GetPerformerId();
			if (existing.PerformerID != performerId)
				throw new UserException("You can only update your own events");

			if (existing == null)
				throw new UserException("Event not found");

			var oldDate = existing.EventDate;

			if (update.EventDate.HasValue)
				await ValidateLocationAvailability(existing.LocationID, update.EventDate.Value, id);

			var result = await base.Update(id, update);

			if (update.EventDate.HasValue && update.EventDate.Value != oldDate)
			{

				var buyerUsers = await _context.Tickets
					.Where(t => t.EventID == id && !t.IsDeleted)
					.Include(t => t.Purchase)
						.ThenInclude(p => p.Customer)
							.ThenInclude(c => c.User)
					.Select(t => t.Purchase.Customer.User)
					.Distinct()
					.ToListAsync();

				var buyerUserIds = buyerUsers.Select(u => u.UserID).ToList();
				if (buyerUserIds.Any())
				{
					await _notificationService.NotifyUsers(
						buyerUserIds,
						"Event Rescheduled",
						$"The event '{result.EventName}' has been rescheduled to {update.EventDate.Value:MMMM dd, yyyy HH:mm}."
					);
				}
				foreach (var user in buyerUsers)
				{
					var emailModel = new EmailModel
					{
						Sender = "noreply@mystagepass.com",
						Recipient = user.Email,
						Subject = $"Event Rescheduled: {result.EventName}",
						Content =
							$"Hi {user.FirstName},\n\n" +
							$"The event '{result.EventName}' has been rescheduled.\n" +
							$"New date: {update.EventDate.Value:MMMM dd, yyyy HH:mm}\n\n" +
							$"Thank you for your understanding."
					};

					_rabbitMQProducer.SendMessage(emailModel);
				}
			}

			return result;
		}

		public async Task<Model.Models.Event> CancelEvent(int eventId, string? reason = null)
		{
			var entity = await _context.Events
				.Include(e => e.Status)
				.Include(e => e.Performer)
					.ThenInclude(p => p.User)
				.Include(e => e.Tickets)
					.ThenInclude(t => t.Purchase)
						.ThenInclude(p => p.Customer)
							.ThenInclude(c => c.User)
				.FirstOrDefaultAsync(e => e.EventID == eventId);

			if (entity == null)
				throw new UserException("Event not found");
			if (entity.StatusID == Status.CancelledID)
				throw new UserException("Event is already cancelled.");
			if (entity.StatusID != Status.ApprovedID)
				throw new UserException("Only approved events can be cancelled.");

			entity.StatusID = Status.CancelledID;
			entity.CancellationReason = reason;
			entity.StatusChangedAt = DateTime.UtcNow;

			await _context.SaveChangesAsync();
			var cancelReasonText = string.IsNullOrWhiteSpace(reason)
				? "No specific reason was provided."
				: reason;

			await _notificationService.NotifyUser(
				entity.Performer.UserID,
				"Event Cancelled",
				$"Your event '{entity.EventName}' has been cancelled. Reason: {cancelReasonText}"
			);

			var performerEmail = new EmailModel
			{
				Sender = "noreply@mystagepass.com",
				Recipient = entity.Performer.User.Email,
				Subject = $"Your Event Has Been Cancelled: {entity.EventName}",
				Content =
					$"Dear {entity.Performer.User.FirstName},\n\n" +
					$"Your event '{entity.EventName}' has been cancelled.\n\n" +
					$"Reason: {cancelReasonText}\n\n" +
					$"Please contact support if you need additional details.\n\n" +
					$"Best regards,\nMyStagePass Team"
			};
			_rabbitMQProducer.SendMessage(performerEmail);

			var activeTickets = entity.Tickets.Where(t => !t.IsDeleted).ToList();
			foreach (var ticket in activeTickets)
				ticket.IsDeleted = true;

			var purchaseIds = activeTickets
				.Select(t => t.PurchaseID)
				.Distinct()
				.ToList();

			var purchases = await _context.Purchases
				.Where(p => purchaseIds.Contains(p.PurchaseID) && p.PaymentIntentId != null)
				.ToListAsync();

			var refundService = new Stripe.RefundService();
			foreach (var purchase in purchases)
			{
				try
				{
					var refundOptions = new Stripe.RefundCreateOptions
					{
						PaymentIntent = purchase.PaymentIntentId
					};
					await refundService.CreateAsync(refundOptions);
					purchase.IsRefunded = true;
				}
				catch (Stripe.StripeException ex)
				{
					_logger.LogError(ex, "Refund failed for purchase {PurchaseID}", purchase.PurchaseID);
				}
			}

			var customerUserIds = activeTickets
				.Select(t => t.Purchase.Customer.User.UserID)
				.Distinct()
				.ToList();

			if (customerUserIds.Any())
			{
				await _notificationService.NotifyUsers(
					customerUserIds,
					"Event Cancelled",
					$"The event '{entity.EventName}' for which you purchased tickets has been cancelled. Reason: {cancelReasonText}"
				);
			}

			await _context.SaveChangesAsync();
			var customerEmails = activeTickets
				.Select(t => t.Purchase.Customer.User)
				.DistinctBy(u => u.UserID)
				.Select(u => new { u.Email, u.FirstName })
				.ToList();

			foreach (var customer in customerEmails)
			{
				var emailModel = new EmailModel
				{
					Sender = "noreply@mystagepass.com",
					Recipient = customer.Email,
					Subject = $"Event Cancelled – Refund Processed: {entity.EventName}",
					Content =
						$"Dear {customer.FirstName},\n\n" +
						$"The event '{entity.EventName}' for which you purchased tickets has been cancelled.\n\n" +
						$"Reason: {cancelReasonText}\n\n" +
						$"A full refund has been initiated and will appear on your account within 5-10 business days.\n\n" +
						$"We apologize for the inconvenience.\n\n" +
						$"Best regards,\nMyStagePass Team"
				};
				_rabbitMQProducer.SendMessage(emailModel);
			}

			return _mapper.Map<Model.Models.Event>(entity);
		}
	}
}