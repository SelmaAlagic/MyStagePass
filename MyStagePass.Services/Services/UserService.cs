using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class UserService : BaseService<Model.Models.User, Database.User, UserSearchObject>, IUserService
	{
		public UserService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override IQueryable<User> AddFilter(IQueryable<User> query, UserSearchObject? search = null)
		{
			if (search == null)
				return query;


			if (!string.IsNullOrWhiteSpace(search.FTS))
			{
				string lowerQuery = search.FTS.ToLower();
				query = query.Where(u =>
					u.FirstName!.ToLower().Contains(lowerQuery) ||
					u.LastName!.ToLower().Contains(lowerQuery) ||
					u.Username!.ToLower().Contains(lowerQuery) ||
					u.Email!.ToLower().Contains(lowerQuery));
			}

			if (search.IsActive.HasValue)
			{
				query = query.Where(u => u.IsActive == search.IsActive.Value);
			}

			return query;
		}

		public async Task Delete(int id)
		{
			var entity = await _context.Users.FirstOrDefaultAsync(u => u.UserID == id);
			if (entity == null)
				throw new Exception("User not found");

			entity.IsActive = false;

			await _context.SaveChangesAsync();
		}
	}
}
