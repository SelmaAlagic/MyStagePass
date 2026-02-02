using AutoMapper;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Helpers;
using MyStagePass.Services.Interfaces;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;

namespace MyStagePass.Services.Services
{
	public class UserService : BaseCRUDService<Model.Models.User, Database.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>, IUserService
	{
		private readonly IConfiguration _configuration;
		public UserService(MyStagePassDbContext context, IMapper mapper, IConfiguration configuration) : base(context, mapper)
		{
			_configuration=configuration;
		}

		public override IQueryable<User> AddInclude(IQueryable<User> query, UserSearchObject? search = null)
		{
			query = query
				.Include(u => u.Admins)
				.Include(u => u.Performers)
				.Include(u => u.Customers);

			return query;
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
				
		public override async Task<Model.Models.User> Delete(int id) 
		{
			var entity = await _context.Users.FirstOrDefaultAsync(u => u.UserID == id);
			if (entity == null)
				throw new Exception("User not found");

			entity.IsActive = false;
			await _context.SaveChangesAsync();

			return _mapper.Map<Model.Models.User>(entity);
		}

		public async Task<Model.Models.User> Restore(int id)
		{
			var user = await _context.Users.FindAsync(id);
			if (user == null)
				throw new Exception("User not found");

			user.IsActive = true; 
			await _context.SaveChangesAsync();

			return _mapper.Map<Model.Models.User>(user);
		}

		public async Task<AuthResponse> AuthenticateUser(string username, string password)
		{
			var user = await _context.Users
				.Include(u => u.Admins)
				.Include(u => u.Performers)
				.Include(u => u.Customers)
				.FirstOrDefaultAsync(u => u.Username == username);

			if (user == null)
			{
				return new AuthResponse { Result = AuthResult.UserNotFound };
			}

			if (!user.IsActive)
			{
				return new AuthResponse { Result = AuthResult.UserNotFound };
			}

			if (!PasswordHelper.VerifyPassword(password, user.Password, user.Salt))
			{
				return new AuthResponse { Result = AuthResult.InvalidPassword };
			}

			string userRole;

			if (user.Admins != null && user.Admins.Any())
			{
				userRole = "Admin";
			}
			else if (user.Performers != null && user.Performers.Any())
			{
				userRole = "Performer";
			}
			else if (user.Customers != null && user.Customers.Any())
			{
				userRole = "Customer";
			}
			else
			{
				return new AuthResponse { Result = AuthResult.UserNotFound };
			}

			var token = GenerateJwtToken(user, userRole);

			return new AuthResponse
			{
				Result = AuthResult.Success,
				Token = token,
				UserId = user.UserID,
				Role = userRole
			};
		}
		
		private string GenerateJwtToken(Database.User user, string userRole)
		{
			var claims = new List<Claim>
			{
				new Claim(ClaimTypes.NameIdentifier, user.UserID.ToString()),     
                new Claim(ClaimTypes.Email, user.Email),                          
                new Claim(ClaimTypes.Role, userRole),                            
                new Claim("Username", user.Username ?? string.Empty),             
                new Claim("FirstName", user.FirstName ?? string.Empty),          
                new Claim("LastName", user.LastName ?? string.Empty)              
            };

			var key = new SymmetricSecurityKey(
				Encoding.UTF8.GetBytes(_configuration["AppSettings:Token"])
			);

			var creds = new SigningCredentials(key, SecurityAlgorithms.HmacSha256Signature);

			var token = new JwtSecurityToken(
				claims: claims,
				expires: DateTime.Now.AddHours(8),  
				signingCredentials: creds
			);

			return new JwtSecurityTokenHandler().WriteToken(token);
		}
	}
}