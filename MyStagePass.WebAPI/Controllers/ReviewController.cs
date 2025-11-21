using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;
using MyStagePass.Services.Services;

namespace MyStagePass.WebAPI.Controllers
{
	public class ReviewController : BaseController<Review, ReviewSearchObject>
	{
		public ReviewController(ILogger<BaseController<Review, ReviewSearchObject>> logger, IReviewService service) : base(logger, service)
		{
		}

		[HttpPost]
		public async Task<IActionResult> Post([FromBody] ReviewInsertRequest request)
		{
			var reviewService = _service as IReviewService;
			if (reviewService == null)
				return BadRequest("Service not available");

			if (!ModelState.IsValid)
				return BadRequest(ModelState);

			await reviewService.Insert(request);

			return Ok("Review successfully created!");
		}

	}
}
