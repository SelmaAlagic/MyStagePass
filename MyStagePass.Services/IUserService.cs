using MyStagePass.Model;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.WebAPI.Controllers
{
	public interface IUserService
	{
		public List<User> Get(UserSearchObject search);
		public User Get(int Id);
	}
}
