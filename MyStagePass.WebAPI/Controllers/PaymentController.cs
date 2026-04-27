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
		private readonly IEventService _eventService;

		public PaymentController(IPurchaseService purchaseService, IEventService eventService)
		{
			_purchaseService = purchaseService;
			_eventService = eventService;
		}

		[HttpPost("create-payment-intent")]
		[Authorize(Roles = "Customer")]
		public async Task<IActionResult> CreatePaymentIntent([FromBody] PaymentRequest request)
		{
			var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
			if (string.IsNullOrEmpty(userId))
				return Unauthorized();

			var ev = await _eventService.GetById(request.EventId);
			if (ev == null)
				return NotFound("Event not found");

			var ticketType = (MyStagePass.Model.Models.TicketType)request.TicketType;

			long singlePrice = ticketType switch
			{
				MyStagePass.Model.Models.TicketType.Vip => ev.VipPrice,
				MyStagePass.Model.Models.TicketType.Premium => ev.PremiumPrice,
				_ => ev.RegularPrice
			};

			long totalAmount = singlePrice * request.NumberOfTickets * 100;

			var options = new PaymentIntentCreateOptions
			{
				Amount = totalAmount,
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
					{ "userId", userId }
				}
			};

			var service = new PaymentIntentService();
			var intent = await service.CreateAsync(options);

			return Ok(new
			{
				clientSecret = intent.ClientSecret,
				amountInKM = singlePrice * request.NumberOfTickets,
				amountInCents = totalAmount
			});
		}

		[HttpPost("verify-and-purchase")]
		[Authorize(Roles = "Customer")]
		public async Task<IActionResult> VerifyAndPurchase([FromBody] VerifyPaymentRequest request)
		{
			var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
			if (string.IsNullOrEmpty(userId))
				return Unauthorized();

			var intentService = new PaymentIntentService();
			var intent = await intentService.GetAsync(request.PaymentIntentId);

			if (intent == null)
				return NotFound("Payment intent not found");

			if (intent.Status != "succeeded")
				return BadRequest($"Payment not completed. Status: {intent.Status}");

			if (!intent.Metadata.TryGetValue("eventId", out var eventIdStr) ||
				!intent.Metadata.TryGetValue("numberOfTickets", out var numTicketsStr) ||
				!intent.Metadata.TryGetValue("ticketType", out var ticketTypeStr))
				return BadRequest("Invalid payment metadata");

			var existing = await _purchaseService.GetByPaymentIntentId(request.PaymentIntentId);
			if (existing != null)
				return BadRequest("Purchase already exists for this payment");

			var insertRequest = new PurchaseInsertRequest
			{
				EventID = int.Parse(eventIdStr),
				NumberOfTickets = int.Parse(numTicketsStr),
				TicketType = (MyStagePass.Model.Models.TicketType)int.Parse(ticketTypeStr),
				CustomerID = int.Parse(userId),
				PaymentIntentId = intent.Id 
			};
			var purchase = await _purchaseService.Insert(insertRequest);
			return Ok(purchase);
		}
	}
}