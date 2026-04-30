using MyStagePass.Model.DTOs;
using MyStagePass.Model.Requests;

namespace MyStagePass.Services.Interfaces
{
	public interface IPaymentService
	{
		Task<PaymentIntentResponse> CreatePaymentIntent(int customerUserId, PaymentRequest request);
		Task<Model.Models.Purchase> VerifyAndPurchase(int customerUserId, string paymentIntentId);
	}
}