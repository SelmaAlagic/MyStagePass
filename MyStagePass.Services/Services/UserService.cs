using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
    public class UserService : IUserService
    {
        private readonly MyStagePassDbContext _context;

        public UserService(MyStagePassDbContext context)
        {
            _context = context;
        }

        public virtual List<User> Get(UserSearchObject search)
        {
            var query = _context.Users.Include(x => x.Notifications).AsQueryable();

            // Pretraga po imenu
            if (!string.IsNullOrWhiteSpace(search?.FirstName))
            {
                query = query.Where(x => x.FirstName.ToLower() == search.FirstName.ToLower());
            }

            // Full Text Search (FTS) - pretraga po imenu, prezimenu, emailu, username-u i telefonu
            if (!string.IsNullOrWhiteSpace(search?.FTS))
            {
                var ftsLower = search.FTS.ToLower();
                query = query.Where(x =>
                    x.FirstName != null && x.FirstName.ToLower().Contains(ftsLower) ||
                    x.LastName != null && x.LastName.ToLower().Contains(ftsLower) ||
                    x.Email != null && x.Email.ToLower().Contains(ftsLower) ||
                    x.Username != null && x.Username.ToLower().Contains(ftsLower) ||
                    x.PhoneNumber != null && x.PhoneNumber.ToLower().Contains(ftsLower)
                );
            }

            return query.ToList();
        }

        public virtual User Get(int id)
        {
            return _context.Users.Include(x => x.Notifications).FirstOrDefault(x => x.UserID == id);
        }
    }
}