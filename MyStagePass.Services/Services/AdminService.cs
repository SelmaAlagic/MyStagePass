using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Helpers;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class AdminService : BaseCRUDService<Model.Models.Admin, Admin, AdminSearchObject, AdminInsertRequest, AdminUpdateRequest>, IAdminService
	{
		public AdminService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}

		public override async Task BeforeInsert(Admin entity, AdminInsertRequest insert)
		{
			if (string.IsNullOrWhiteSpace(insert.Password))
				throw new UserException("Password is required.");

			if (string.IsNullOrWhiteSpace(insert.PasswordConfirm))
				throw new UserException("Password confirmation is required.");

			if (insert.Password != insert.PasswordConfirm)
				throw new UserException("Password and confirmation do not match.");

			if (insert.Password.Length < 6)
				throw new UserException("Password must be at least 6 characters long.");

			if (await _context.Users.AnyAsync(u => u.Username == insert.Username))
				throw new UserException($"Username '{insert.Username}' already exists.");

			if (await _context.Users.AnyAsync(u => u.Email == insert.Email))
				throw new UserException($"Email '{insert.Email}' is already registered.");

			User user = _mapper.Map<User>(insert);
			entity.User = user;
			entity.User.Salt = PasswordHelper.GenerateSalt();
			entity.User.Password = PasswordHelper.GenerateHash(entity.User.Salt, insert.Password);
		}

		public override IQueryable<Admin> AddInclude(IQueryable<Admin> query, AdminSearchObject? search = null)
		{
			if (search.isUserIncluded == true)
			{
				query = query.Include("User");
			}
			return base.AddInclude(query, search);
		}

		public override async Task<Model.Models.Admin> GetById(int id)
		{
			var entity = await _context.Set<Admin>()
				.Include(x => x.User)
				.FirstOrDefaultAsync(x => x.AdminID == id);

			return _mapper.Map<Model.Models.Admin>(entity);
		}
		public override async Task<Model.Models.Admin> Update(int id, AdminUpdateRequest update)
		{
			if (!string.IsNullOrEmpty(update.Password))
			{
				if (string.IsNullOrEmpty(update.CurrentPassword))
					throw new UserException("Current password is required to change password.");

				if (string.IsNullOrEmpty(update.PasswordConfirm))
					throw new UserException("Password confirmation is required.");

				if (update.Password != update.PasswordConfirm)
					throw new UserException("New password and confirmation do not match.");
			}

			var set = _context.Set<Admin>();
			var entity = await set.Include(a => a.User).FirstOrDefaultAsync(a => a.AdminID == id);

			if (entity?.User == null)
				throw new UserException("Admin or User not found");

			if (!string.IsNullOrWhiteSpace(update.Password))
			{
				var currentPasswordHash = PasswordHelper.GenerateHash(
					entity.User.Salt,
					update.CurrentPassword
				);

				if (entity.User.Password != currentPasswordHash)
					throw new UserException("Current password is incorrect.");

				entity.User.Salt = PasswordHelper.GenerateSalt();
				entity.User.Password = PasswordHelper.GenerateHash(entity.User.Salt, update.Password);
			}

			_mapper.Map(update, entity.User);
			_mapper.Map(update, entity);

			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Admin>(entity);
		}

		public async Task<Model.Models.Admin> UpdateBaseUser(int id, AdminUpdateRequest update)
		{
			var set = _context.Set<Admin>();
			var entity = await set.Include(a => a.User).FirstOrDefaultAsync(a => a.AdminID == id);
			_mapper.Map(update, entity?.User);
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Admin>(entity);
		}
	}
}