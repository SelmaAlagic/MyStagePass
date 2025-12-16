using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize]
	public class ReviewController : BaseController<Review, ReviewSearchObject>
	{
		public ReviewController(ILogger<BaseController<Review, ReviewSearchObject>> logger, IReviewService service) : base(logger, service)
		{
		}

		[Authorize(Roles = "Customer")]
		[HttpPost("submit")]
		public async Task<IActionResult> Post([FromBody] ReviewInsertRequest request)
		{
			var reviewService = _service as IReviewService;
			if (reviewService == null)
				return BadRequest("Service not available");
			await reviewService.Insert(request);
			return Ok("Review successfully created!");
		}
	}
}