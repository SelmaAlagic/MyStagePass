using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class GenreService : BaseService<Model.Models.Genre, Database.Genre, GenreSearchObject>, IGenreService
	{
		public GenreService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override IQueryable<Genre> AddInclude(IQueryable<Genre> query, GenreSearchObject? search = null)
		{
			query = query.Include(p => p.Performers).ThenInclude(pg => pg.Performer);

			return base.AddInclude(query, search);
		}
	}
}
