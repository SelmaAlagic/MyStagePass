using MyStagePass.Model.DTOs;

public interface IRecommendedService
{
	Task<List<EventRecommendation>> GetRecommendationsForCustomerAsync(int topN = 10);
}