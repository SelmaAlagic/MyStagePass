using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;
using System.Security.Claims;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize]
	public class UserController : BaseCRUDController<User, UserSearchObject, UserInsertRequest, UserUpdateRequest>
	{
		private readonly IUserService _userService;
		public UserController(ILogger<BaseController<User, UserSearchObject>> logger, IUserService service) : base(logger, service)
		{
			_userService=service;
		}

		[Authorize(Roles = "Admin")]
		[HttpDelete("deactivate/{id}")]
		public override async Task<User> Delete(int id)
		{
			return await _service.Delete(id);
		}

		[Authorize(Roles = "Admin")]
		[HttpPut("restore/{id}")]
		public async Task<ActionResult<User>> Restore(int id)
		{
			var restoredUser = await _userService.Restore(id);
			return restoredUser;
		}

		[AllowAnonymous]
		[HttpPost("login")]
		public async Task<IActionResult> Login([FromBody] LoginRequest request)
		{
			try
			{
				var response = await _userService.AuthenticateUser(request.Username, request.Password);

				return response.Result switch
				{
					AuthResult.Success => Ok(response),
					AuthResult.UserNotFound => NotFound(new { message = "User not found or account is inactive" }),
					AuthResult.InvalidPassword => Unauthorized(new { message = "Invalid username or password" }),
					_ => BadRequest(new { message = "Login failed" })
				};
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "Login error for username: {Username}", request.Username);
				return StatusCode(500, new { message = "An error occurred during login" });
			}
		}

		[Authorize]
		[HttpGet("current")]
		public IActionResult GetCurrentUser()
		{
			try
			{
				var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
				var email = User.FindFirst(ClaimTypes.Email)?.Value;
				var role = User.FindFirst(ClaimTypes.Role)?.Value;
				var username = User.FindFirst("Username")?.Value;
				var firstName = User.FindFirst("FirstName")?.Value;
				var lastName = User.FindFirst("LastName")?.Value;

				return Ok(new
				{
					userId = int.Parse(userId ?? "0"),
					email,
					role,
					username,
					firstName,
					lastName,
					fullName = $"{firstName} {lastName}".Trim()
				});
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "Error getting current user");
				return Unauthorized(new { message = "Invalid token" });
			}
		}

		[Authorize(Roles = "Admin, Customer, Performer")]
		[HttpGet("my-profile")]
		public async Task<IActionResult> GetMyProfile()
		{
			try
			{
				var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)?.Value);

				var user = await _userService.GetById(userId);

				if (user == null)
					return NotFound(new { message = "User not found" });

				return Ok(user);
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "Error getting user profile");
				return StatusCode(500, new { message = "Error retrieving profile" });
			}
		}
	}
}