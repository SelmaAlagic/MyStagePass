using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class PurchaseService : BaseService<Model.Models.Purchase, Database.Purchase, PurchaseSearchObject>, IPurchaseService
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

		public async Task SoftDelete(int id)
		{
			var entity = await _context.Purchases
				.Include(p => p.Tickets)
				.FirstOrDefaultAsync(p => p.PurchaseID == id);

			if (entity == null)
				throw new Exception("Purchase not found");

			entity.IsDeleted = true;

			if (entity.Tickets != null)
			{
				foreach (var ticket in entity.Tickets)
				{
					ticket.IsDeleted = true;
				}
			}

			await _context.SaveChangesAsync(); ;
		}
	}
}