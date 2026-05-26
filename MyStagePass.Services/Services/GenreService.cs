using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class GenreService : BaseCRUDService<Model.Models.Genre, Database.Genre, GenreSearchObject, GenreInsertRequest, GenreUpdateRequest>, IGenreService
	{
		public GenreService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override async Task BeforeInsert(Genre entity, GenreInsertRequest insert)
		{
			var exists = await _context.Genres.AnyAsync(x => x.Name.ToLower() == insert.Name.ToLower());

			if (exists)
			{
				throw new UserException("Genre with this name already exists.");
			}

			await base.BeforeInsert(entity, insert);
		}

		public override IQueryable<Genre> AddFilter(IQueryable<Genre> query, GenreSearchObject? search = null)
		{
			if (search == null)
				return query;

			if (!string.IsNullOrWhiteSpace(search.Name))
			{
				query = query.Where(g => g.Name.ToLower().Contains(search.Name.ToLower()));
			}
			return query;
		}

		public override IQueryable<Genre> AddInclude(IQueryable<Genre> query, GenreSearchObject? search = null)
		{
			query = query.Include(p => p.Performers).ThenInclude(pg => pg.Performer);

			return base.AddInclude(query, search);
		}
	}
}