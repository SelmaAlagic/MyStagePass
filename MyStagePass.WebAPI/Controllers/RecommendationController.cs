using Microsoft.AspNetCore.Mvc;
using MyStagePass.Services.Interfaces;
using MyStagePass.Model.DTOs;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;

namespace MyStagePass.WebAPI.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	[Authorize(Roles = "Customer")]
	public class RecommendationController : ControllerBase
	{
		private readonly IRecommendedService _recommendedService;

		public RecommendationController(IRecommendedService recommendedService)
		{
			_recommendedService = recommendedService;
		}

		[HttpGet]
		public async Task<ActionResult<List<EventRecommendation>>> GetRecommendations([FromQuery] int topN = 10)
		{
			var customerIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

			if (string.IsNullOrEmpty(customerIdClaim))
				return Unauthorized("User is not logged in!");

			if (!int.TryParse(customerIdClaim, out int customerId))
				return BadRequest("Invalid user ID");

			var recommendations = await _recommendedService.GetRecommendationsForCustomerAsync(customerId, topN);
			return Ok(recommendations);
		}
	}
}