using MyStagePass.Services.Database;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
    public interface IUserService
    {
        public List<User> Get(UserSearchObject search);
        public User Get(int Id);
    }
}
