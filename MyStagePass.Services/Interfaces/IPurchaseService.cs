using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
	public interface IPurchaseService : ICRUDService<Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>
	{
		Task<PagedResult<Event>> GetCustomerEvents(PurchaseSearchObject search);
		Task<Model.Models.Purchase?> GetByPaymentIntentId(string paymentIntentId);
	}
}