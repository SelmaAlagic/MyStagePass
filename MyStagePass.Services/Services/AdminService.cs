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

		public override async Task<Model.Models.Admin> Update(int id, AdminUpdateRequest update)
		{
			var set = _context.Set<Admin>();
			var entity = await set.Include(a => a.User).FirstOrDefaultAsync(a => a.AdminID == id);
			_mapper.Map(update, entity?.User);
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