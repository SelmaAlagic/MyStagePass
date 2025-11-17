using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class CustomerFavoriteEventService : BaseService<Model.Models.CustomerFavoriteEvent, Database.CustomerFavoriteEvent, CustomerFavoriteEventSearchObject>, ICustomerFavoriteEventService
	{
		public CustomerFavoriteEventService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<CustomerFavoriteEvent> AddInclude(IQueryable<CustomerFavoriteEvent> query, CustomerFavoriteEventSearchObject? search = null)
		{
			//query = query.Include(cfe => cfe.Event);

			return base.AddInclude(query, search);
		}

	}
}
