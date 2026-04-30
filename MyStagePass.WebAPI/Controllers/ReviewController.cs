using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles = Roles.Customer)]
	public class ReviewController : BaseController<Review, ReviewSearchObject>
	{
		private readonly ICurrentUserService _currentUserService;

		public ReviewController(ILogger<BaseController<Review, ReviewSearchObject>> logger, IReviewService service, ICurrentUserService currentUserService) : base(logger, service)
		{
			_currentUserService=currentUserService;
		}

		[HttpPost("submit")]
		public async Task<IActionResult> Post([FromBody] ReviewInsertRequest request)
		{
			request.CustomerID = _currentUserService.GetCustomerId();

			var reviewService = _service as IReviewService;
			if (reviewService == null)
				return BadRequest("Service not available");

			await reviewService.Insert(request);
			return Ok("Review successfully created!");
		}
	}
}