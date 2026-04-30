using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class PurchaseService : BaseCRUDService<Model.Models.Purchase, Database.Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>, IPurchaseService
	{
		public PurchaseService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<Database.Purchase> AddInclude(IQueryable<Database.Purchase> query, PurchaseSearchObject? search = null)
		{
			query = query
				.Include(p => p.Tickets)
					.ThenInclude(t => t.Event)
						.ThenInclude(e => e.Performer)
							.ThenInclude(p => p.User)
				.Include(p => p.Tickets)
					.ThenInclude(t => t.Event)
						.ThenInclude(e => e.Location)
							.ThenInclude(l => l.City);
			return base.AddInclude(query, search);
		}

		public override IQueryable<Database.Purchase> AddFilter(IQueryable<Database.Purchase> query, PurchaseSearchObject? search = null)
		{
			if (search == null)
				return query;

			query = query.Where(p => !p.IsDeleted);

			if (search.CustomerID.HasValue)
				query = query.Where(p => p.CustomerID == search.CustomerID.Value);

			if (search.DateFrom != null)
				query = query.Where(p => p.PurchaseDate >= search.DateFrom);

			if (search.DateTo != null)
				query = query.Where(p => p.PurchaseDate <= search.DateTo);

			return query;
		}

		public override async Task<Model.Models.Purchase> Delete(int id)
		{
			var entity = await _context.Purchases
				.Include(p => p.Tickets)
				.FirstOrDefaultAsync(p => p.PurchaseID == id);

			if (entity == null)
				throw new UserException("Purchase not found");

			entity.IsDeleted = true;

			if (entity.Tickets != null)
			{
				foreach (var ticket in entity.Tickets)
				{
					ticket.IsDeleted = true;

					var ev = await _context.Events.FindAsync(ticket.EventID);
					if (ev != null && ev.TicketsSold > 0)
					{
						ev.TicketsSold -= 1;
					}
				}
			}

			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Purchase>(entity);
		}

		public override async Task<Model.Models.Purchase> Insert(PurchaseInsertRequest request)
		{
			var customer = await _context.Customers
				.FirstOrDefaultAsync(c => c.CustomerID == request.CustomerID)
				?? throw new UserException("Customer not found.");

			var ev = await _context.Events
				.Include(e => e.Status)
				.FirstOrDefaultAsync(e => e.EventID == request.EventID)
				?? throw new UserException("Event not found.");

			if (ev.StatusID != Status.ApprovedID)
				throw new UserException("Tickets can only be purchased for approved events.");

			if (ev.EventDate < DateTime.UtcNow)
				throw new UserException("Cannot purchase tickets for past events.");

			if (request.NumberOfTickets <= 0)
				throw new UserException("Number of tickets must be at least 1.");

			int remainingTickets = ev.TotalTickets - ev.TicketsSold;
			if (request.NumberOfTickets > remainingTickets)
				throw new UserException(remainingTickets == 0
					? "This event is sold out."
					: $"Not enough tickets available. Only {remainingTickets} ticket(s) remaining.");

			int singlePrice = request.TicketType switch
			{
				Model.Models.TicketType.Vip => ev.VipPrice,
				Model.Models.TicketType.Premium => ev.PremiumPrice,
				_ => ev.RegularPrice
			};

			if (singlePrice <= 0)
				throw new UserException("Invalid ticket price for selected ticket type.");

			using var transaction = await _context.Database.BeginTransactionAsync();
			try
			{
				var purchaseEntity = new Database.Purchase
				{
					CustomerID = request.CustomerID,
					PurchaseDate = DateTime.UtcNow,
					IsDeleted = false,
					PaymentIntentId = request.PaymentIntentId
				};

				_context.Purchases.Add(purchaseEntity);
				await _context.SaveChangesAsync();

				for (int i = 0; i < request.NumberOfTickets; i++)
				{
					var ticket = new Database.Ticket
					{
						EventID = request.EventID,
						PurchaseID = purchaseEntity.PurchaseID,
						Price = singlePrice,
						TicketType = (Database.TicketType)request.TicketType,
						IsDeleted = false
					};
					_context.Tickets.Add(ticket);
				}

				ev.TicketsSold += request.NumberOfTickets;
				await _context.SaveChangesAsync();
				await transaction.CommitAsync();

				var result = await _context.Purchases
					.Include(p => p.Tickets)
						.ThenInclude(t => t.Event)
							.ThenInclude(e => e.Performer)
								.ThenInclude(p => p.User)
					.Include(p => p.Tickets)
						.ThenInclude(t => t.Event)
							.ThenInclude(e => e.Location)
								.ThenInclude(l => l.City)
					.FirstOrDefaultAsync(p => p.PurchaseID == purchaseEntity.PurchaseID);

				return _mapper.Map<Model.Models.Purchase>(result);
			}
			catch (UserException)
			{
				await transaction.RollbackAsync();
				throw; 
			}
			catch (Exception ex)
			{
				await transaction.RollbackAsync();
				throw new UserException("Error during purchase: " + ex.Message);
			}
		}

		public async Task<PagedResult<Model.Models.Event>> GetCustomerEvents(PurchaseSearchObject search)
		{
			var query = _context.Purchases
				.Where(p => p.CustomerID == search.CustomerID && !p.IsDeleted)
				.Include(p => p.Tickets)
					.ThenInclude(t => t.Event)
						.ThenInclude(e => e.Performer)
							.ThenInclude(p => p.User)
				.Include(p => p.Tickets)
					.ThenInclude(t => t.Event)
						.ThenInclude(e => e.Location)
				.AsQueryable();

			var purchases = await query.ToListAsync();

			var eventsFromDb = purchases
				.SelectMany(p => p.Tickets)
				.Where(t => !t.IsDeleted && t.Event != null)
				.GroupBy(t => t.EventID)
				.Select(g => g.First().Event)
				.ToList();

			eventsFromDb = eventsFromDb.OrderByDescending(e => e.EventDate).ToList();

			var totalCount = eventsFromDb.Count;

			var page = search.Page ?? 0;
			var pageSize = search.PageSize ?? 10;

			var customerId = search.CustomerID;
			var reviews = await _context.Reviews
				.Where(r => r.CustomerID == search.CustomerID)
				.ToListAsync();

			var pagedEvents = eventsFromDb
				.Skip(page * pageSize)
				.Take(pageSize)
				.Select(e =>
				{
					var mapped = _mapper.Map<Model.Models.Event>(e);
					var review = reviews.FirstOrDefault(r => r.EventID == e.EventID);
					mapped.UserRating = review?.RatingValue;
					return mapped;
				})
				.ToList();

			return PagedResult<Model.Models.Event>.Create(pagedEvents, page, pageSize, totalCount);
		}

		public async Task<Model.Models.Purchase?> GetByPaymentIntentId(string paymentIntentId)
		{
			var entity = await _context.Purchases
				.FirstOrDefaultAsync(p => p.PaymentIntentId == paymentIntentId);
			return entity == null ? null : _mapper.Map<Model.Models.Purchase>(entity);
		}
	}
}