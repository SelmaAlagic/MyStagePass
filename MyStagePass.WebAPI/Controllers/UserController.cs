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
	public class UserController : BaseController<User, UserSearchObject>
	{
		private readonly IUserService _userService;
		public UserController(ILogger<BaseController<User, UserSearchObject>> logger, IUserService service) : base(logger, service)
		{
			_userService=service;
		}

		[Authorize(Roles = "Admin")]
		[HttpDelete("{id}")]
		public async Task<IActionResult> Delete(int id)
		{
			var userService = _service as IUserService;
			if (userService == null)
				return BadRequest("Service not available");

			await userService.Delete(id);
			return Ok("User successfully deleted!");
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
				var roleId = User.FindFirst("RoleId")?.Value;
				var username = User.FindFirst("Username")?.Value;
				var firstName = User.FindFirst("FirstName")?.Value;
				var lastName = User.FindFirst("LastName")?.Value;

				return Ok(new
				{
					userId = int.Parse(userId ?? "0"),
					email,
					role,
					roleId = int.Parse(roleId ?? "0"),
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

		[Authorize]
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