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

		public override async Task<Model.Models.Genre> Update(int id, GenreUpdateRequest update)
		{
			var exists = await _context.Genres
				.AnyAsync(x => x.Name.ToLower() == update.Name.ToLower()
							&& x.GenreID != id);
			if (exists)
				throw new UserException("Genre with this name already exists.");

			return await base.Update(id, update);
		}

		public override IQueryable<Genre> AddInclude(IQueryable<Genre> query, GenreSearchObject? search = null)
		{
			query = query.Include(p => p.Performers).ThenInclude(pg => pg.Performer);

			return base.AddInclude(query, search);
		}

		public override async Task<Model.Models.Genre> Delete(int id)
		{
			var genre = await _context.Genres
				.Include(g => g.Performers)
				.FirstOrDefaultAsync(g => g.GenreID == id)
				?? throw new UserException("Genre not found.");

			if (genre.Performers.Any())
				throw new UserException("Cannot delete genre because it has assigned performers.");

			return await base.Delete(id);
		}
	}
}