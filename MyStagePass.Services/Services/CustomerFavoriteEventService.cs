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
	}
}