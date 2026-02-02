using AutoMapper;
using Microsoft.EntityFrameworkCore;
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
				if (string.IsNullOrEmpty(update.PasswordConfirm))
					throw new Exception("Password confirmation is required.");

				if (update.Password != update.PasswordConfirm)
					throw new Exception("Password and confirmation do not match.");
			}

			var set = _context.Set<Admin>();
			var entity = await set.Include(a => a.User).FirstOrDefaultAsync(a => a.AdminID == id);

			if (entity?.User == null)
				throw new Exception("Admin or User not found");

			_mapper.Map(update, entity.User);
			_mapper.Map(update, entity);

			if (!string.IsNullOrWhiteSpace(update.Password))
			{
				entity.User.Salt = PasswordHelper.GenerateSalt();
				entity.User.Password = PasswordHelper.GenerateHash(entity.User.Salt, update.Password);
			}

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