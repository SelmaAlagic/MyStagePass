using Microsoft.AspNetCore.Mvc;
using MyStagePass.Services.Database;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
    [Route("api/[controller]")]
	[ApiController]
	public class UserController : ControllerBase
	{
		//UserService userService=new UserService();

		protected IUserService _userService;
		public UserController(IUserService service) 
		{
			_userService=service;
		}

		[HttpGet()]
		public IEnumerable<User> Get([FromQuery]UserSearchObject? search)
		{
			return _userService.Get(search);
		}

		[HttpGet("{Id}")]
		public User Get(int Id)
		{
			return _userService.Get(Id);
		}
	}
}
