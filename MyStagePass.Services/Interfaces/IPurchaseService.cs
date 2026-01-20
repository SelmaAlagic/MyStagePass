using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
	public interface IPurchaseService : ICRUDService<Purchase, PurchaseSearchObject, PurchaseInsertRequest, PurchaseUpdateRequest>
	{
	}
}