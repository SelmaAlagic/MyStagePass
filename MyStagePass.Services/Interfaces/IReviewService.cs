using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
	public interface IReviewService : IService<Review, ReviewSearchObject>
	{
		Task Insert(ReviewInsertRequest request);
	}
}