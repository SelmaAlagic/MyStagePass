using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.DTOs;
using MyStagePass.Model.Helpers;

namespace MyStagePass.WebAPI.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	[Authorize(Roles = Roles.Customer)]
	public class RecommendationController : ControllerBase
	{
		private readonly IRecommendedService _recommendedService;

		public RecommendationController(IRecommendedService recommendedService)
		{
			_recommendedService = recommendedService;
		}

		[HttpGet]
		public async Task<ActionResult<List<EventRecommendation>>> GetRecommendations(
			[FromQuery] int topN = 10)
		{
			try
			{
				var recommendations = await _recommendedService
					.GetRecommendationsForCustomerAsync(topN);
				return Ok(recommendations);
			}
			catch (UnauthorizedAccessException ex)
			{
				return Unauthorized(ex.Message);
			}
		}
	}
}