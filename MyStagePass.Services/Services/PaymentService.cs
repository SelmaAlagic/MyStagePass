using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Requests;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;
using Stripe;
using AutoMapper;
using MyStagePass.Model.DTOs;

namespace MyStagePass.Services.Services
{
	public class PaymentService : IPaymentService
	{
		private readonly MyStagePassDbContext _context;
		private readonly IMapper _mapper;
		private readonly IRabbitMQProducer _rabbitMQProducer;
		private readonly IPurchaseService _purchaseService;
		public PaymentService(MyStagePassDbContext context, IMapper mapper, IRabbitMQProducer rabbitMQProducer, IPurchaseService purchaseService)
		{
			_context = context;
			_mapper = mapper;
			_rabbitMQProducer = rabbitMQProducer;
			_purchaseService=purchaseService;	
		}

		public async Task<PaymentIntentResponse> CreatePaymentIntent(int customerUserId, PaymentRequest request)
		{
			var ev = await _context.Events
				.Include(e => e.Status)
				.FirstOrDefaultAsync(e => e.EventID == request.EventId)
				?? throw new UserException("Event not found.");

			if (ev.StatusID != Status.ApprovedID)
				throw new UserException("Tickets can only be purchased for approved events.");

			if (ev.EventDate < DateTime.UtcNow)
				throw new UserException("Cannot purchase tickets for past events.");

			int remainingTickets = ev.TotalTickets - ev.TicketsSold;
			if (request.NumberOfTickets <= 0)
				throw new UserException("Number of tickets must be at least 1.");

			if (request.NumberOfTickets > remainingTickets)
				throw new UserException($"Only {remainingTickets} ticket(s) remaining for this event.");

			var ticketType = (Model.Models.TicketType)request.TicketType;

			long singlePrice = ticketType switch
			{
				Model.Models.TicketType.Vip => ev.VipPrice,
				Model.Models.TicketType.Premium => ev.PremiumPrice,
				_ => ev.RegularPrice
			};

			if (singlePrice <= 0)
				throw new UserException("Invalid ticket price.");

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
					{ "customerUserId", customerUserId.ToString() }
				}
			};

			var service = new PaymentIntentService();
			var intent = await service.CreateAsync(options);

			return new PaymentIntentResponse
			{
				ClientSecret = intent.ClientSecret,
				AmountInKM = singlePrice * request.NumberOfTickets,
				AmountInCents = totalAmount
			};
		}

		public async Task<Model.Models.Purchase> VerifyAndPurchase(int customerUserId, string paymentIntentId)
		{
			var intentService = new PaymentIntentService();
			var intent = await intentService.GetAsync(paymentIntentId)
				?? throw new UserException("Payment intent not found.");

			if (intent.Metadata.TryGetValue("customerUserId", out var metaUserId))
			{
				if (metaUserId != customerUserId.ToString())
					throw new UserException("Payment intent does not belong to this user.");
			}

			if (intent.Status != "succeeded")
				throw new UserException($"Payment not completed. Status: {intent.Status}");

			if (!intent.Metadata.TryGetValue("eventId", out var eventIdStr) ||
				!intent.Metadata.TryGetValue("numberOfTickets", out var numTicketsStr) ||
				!intent.Metadata.TryGetValue("ticketType", out var ticketTypeStr))
				throw new UserException("Invalid payment metadata.");

			var existing = await _context.Purchases
				.FirstOrDefaultAsync(p => p.PaymentIntentId == paymentIntentId);
			if (existing != null)
				throw new UserException("Purchase already exists for this payment.");

			var insertRequest = new PurchaseInsertRequest
			{
				EventID = int.Parse(eventIdStr),
				NumberOfTickets = int.Parse(numTicketsStr),
				TicketType = (Model.Models.TicketType)int.Parse(ticketTypeStr),
				CustomerID = customerUserId,
				PaymentIntentId = intent.Id
			};

			return await _purchaseService.Insert(insertRequest);
		}
	}
}