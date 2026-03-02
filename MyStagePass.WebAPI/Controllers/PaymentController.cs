using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Requests;
using MyStagePass.Services.Interfaces;
using Stripe;
using System.Security.Claims;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class PaymentController : ControllerBase
	{
		private readonly IPurchaseService _purchaseService;

		public PaymentController(IConfiguration config, IPurchaseService purchaseService)
		{
			_purchaseService = purchaseService;
		}

		[HttpPost("create-payment-intent")]
		[Authorize(Roles = "Customer")]
		public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentRequest request)
		{
			var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

			var options = new PaymentIntentCreateOptions
			{
				Amount = request.Amount,
				Currency = "eur",
				AutomaticPaymentMethods = new PaymentIntentAutomaticPaymentMethodsOptions
				{
					Enabled = true,
				},
				Metadata = new Dictionary<string, string>
				{
					{ "eventId", request.EventId.ToString() },
					{ "numberOfTickets", request.NumberOfTickets.ToString() },
					{ "ticketType", request.TicketType.ToString() },
					{ "userId", userId! }
				}
			};

			var service = new PaymentIntentService();
			var intent = await service.CreateAsync(options);

			return Ok(new { clientSecret = intent.ClientSecret });
		}

	}
}