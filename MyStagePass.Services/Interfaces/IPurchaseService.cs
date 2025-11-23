using MyStagePass.Model.Models;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
	public interface IPurchaseService : IService<Purchase, PurchaseSearchObject>
	{
		Task SoftDelete(int id);
	}
}