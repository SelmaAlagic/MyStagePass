using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Helpers;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class CustomerService : BaseCRUDService<Model.Models.Customer, Customer, CustomerSearchObject, CustomerInsertRequest, CustomerUpdateRequest>, ICustomerService
	{
		public CustomerService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public override async Task BeforeInsert(Customer entity, CustomerInsertRequest insert)
		{
			if (insert.Password != insert.PasswordConfirm)
				throw new Exception("Password and confirmation do not match.");

			if (await _context.Users.AnyAsync(u => u.Username == insert.Username))
				throw new Exception("Username already exists.");

			if (await _context.Users.AnyAsync(u => u.Email == insert.Email))
				throw new Exception("Email already exists.");

			User user = _mapper.Map<User>(insert);
			entity.User = user;
			entity.User.Salt = PasswordHelper.GenerateSalt();
			entity.User.Password = PasswordHelper.GenerateHash(entity.User.Salt, insert.Password);
		}

		public override IQueryable<Customer> AddInclude(IQueryable<Customer> query, CustomerSearchObject? search = null)
		{
			if (search.isUserIncluded == true)
			{
				query = query.Include("User");
			}

			query = query.Include(c => c.FavoriteEvents);

			if (!string.IsNullOrWhiteSpace(search?.searchTerm))
			{
				string term = search.searchTerm.ToLower();
				query = query.Where(p =>
					(p.User.FirstName != null && p.User.FirstName.ToLower().StartsWith(term)) ||
					(p.User.LastName != null && p.User.LastName.ToLower().StartsWith(term)));
			}

			return base.AddInclude(query, search);
		}

		public override async Task<Model.Models.Customer> Update(int id, CustomerUpdateRequest update)
		{
			if (!string.IsNullOrEmpty(update.Password) || !string.IsNullOrEmpty(update.PasswordConfirm))
			{
				if (update.Password != update.PasswordConfirm)
					throw new Exception("Password and confirmation do not match.");
			}

			var set = _context.Set<Customer>();
			var entity = await set.Include(c => c.User).FirstOrDefaultAsync(c => c.CustomerID == id);
			_mapper.Map(update, entity?.User);
			_mapper.Map(update, entity);
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Customer>(entity);
		}

		public async Task<Model.Models.Customer> UpdateBaseUser(int id, CustomerUpdateRequest update)
		{
			var set = _context.Set<Customer>();
			var entity = await set.Include(c => c.User).FirstOrDefaultAsync(c => c.CustomerID == id);
			_mapper.Map(update, entity?.User);
			await _context.SaveChangesAsync();
			return _mapper.Map<Model.Models.Customer>(entity);
		}
	}
}