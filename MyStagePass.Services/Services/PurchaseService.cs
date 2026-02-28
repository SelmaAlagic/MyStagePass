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
			query = query.Include(c => c.Tickets);
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
				.FirstOrDefaultAsync(c => c.UserID == request.CustomerID);

			if (customer == null)
				throw new UserException("Customer not found for the given user.");

			request.CustomerID = customer.CustomerID;

			var ev = await _context.Events.FindAsync(request.EventID);
			if (ev == null)
				throw new UserException("Event not found");

			int singlePrice = request.TicketType switch
			{
				Model.Models.Event.TicketType.Vip => ev.VipPrice,
				Model.Models.Event.TicketType.Premium => ev.PremiumPrice,
				_ => ev.RegularPrice
			};

			using var transaction = await _context.Database.BeginTransactionAsync();
			try
			{
				var purchaseEntity = new Database.Purchase
				{
					CustomerID = request.CustomerID,
					PurchaseDate = DateTime.Now,
					IsDeleted = false
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
						TicketType = (Database.Event.TicketType)request.TicketType,
						IsDeleted = false
					};
					_context.Tickets.Add(ticket);
					await _context.SaveChangesAsync();

					ticket.GenerateQRCode($"{ticket.TicketID}");
				}

				ev.TicketsSold += request.NumberOfTickets;
				await _context.SaveChangesAsync();
				await transaction.CommitAsync();

				var purchaseId = purchaseEntity.PurchaseID;
				var result = await _context.Purchases
					.Include(p => p.Tickets)
					.ThenInclude(t => t.Event)
					.FirstOrDefaultAsync(p => p.PurchaseID == purchaseId);

				return _mapper.Map<Model.Models.Purchase>(result);
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
			var reviews = _context.Reviews
				.Where(r => r.CustomerID == search.CustomerID)
				.ToList();

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
	}
}