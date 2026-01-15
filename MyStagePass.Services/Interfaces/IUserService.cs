using MyStagePass.Model.Helpers;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
    public interface IUserService : IService<Model.Models.User, UserSearchObject>
    {
		Task Delete(int id);
		Task<AuthResponse> AuthenticateUser(string username, string password);
	}
}