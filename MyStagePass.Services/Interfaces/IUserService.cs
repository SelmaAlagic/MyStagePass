using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
    public interface IUserService : ICRUDService<Model.Models.User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
    {
		Task<User> Restore(int id);
		Task<AuthResponse> AuthenticateUser(string username, string password);
	}
}