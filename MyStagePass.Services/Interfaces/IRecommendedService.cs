using MyStagePass.Model.DTOs;

namespace MyStagePass.Services.Interfaces
{
	public interface IRecommendedService
	{
		Task<List<EventRecommendation>> GetRecommendationsForCustomerAsync(int customerId, int topN = 10);
	}
}