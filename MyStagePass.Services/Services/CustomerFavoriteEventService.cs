using AutoMapper;
using Microsoft.EntityFrameworkCore;
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
	}
}