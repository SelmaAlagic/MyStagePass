using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class UserController : BaseController<User, UserSearchObject>
	{
		public UserController(ILogger<BaseController<User, UserSearchObject>> logger, IUserService service) : base(logger, service)
		{
		}

		[HttpDelete("{id}")]
		public async Task<IActionResult> Delete(int id)
		{
			var userService = _service as IUserService;
			if (userService == null)
				return BadRequest("Service not available");

			await userService.Delete(id);
			return Ok("User successfully deleted!");
		}
	}
}