using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles=Roles.Customer)]
	public class PaymentController : ControllerBase
	{
		private readonly IPaymentService _paymentService;
		private readonly ICurrentUserService _currentUserService;

		public PaymentController(IPaymentService paymentService, ICurrentUserService currentUserService)
		{
			_paymentService = paymentService;
			_currentUserService = currentUserService;
		}

		[HttpPost("create-payment-intent")]
		public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentRequest request)
		{
			var customerIdClaim = _currentUserService.GetCustomerId();
			var result = await _paymentService.CreatePaymentIntent(customerIdClaim, request);

			return Ok(result);
		}

		[HttpPost("verify-and-purchase")]
		public async Task<IActionResult> VerifyAndPurchase([FromBody] VerifyPaymentRequest request)
		{
			var customerIdClaim = _currentUserService.GetCustomerId();
			var result = await _paymentService.VerifyAndPurchase(customerIdClaim, request.PaymentIntentId);
			return Ok(result);
		}

	}
}