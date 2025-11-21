using AutoMapper;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;


namespace MyStagePass.Services.Services
{
	public class ReviewService : BaseService<Model.Models.Review, Database.Review, ReviewSearchObject>, IReviewService
	{
		public ReviewService(MyStagePassDbContext context, IMapper mapper) : base(context, mapper)
		{
		}
		public async Task Insert(ReviewInsertRequest request)
		{
			var eventEntity = await _context.Events.FirstOrDefaultAsync(e => e.EventID == request.EventID);
			if (eventEntity == null)
				throw new Exception("Event not found");

			if (eventEntity.EventDate > DateTime.Now)
				throw new Exception("Cannot review an event that hasn't happened yet.");

			var review = _mapper.Map<Review>(request);

			review.CreatedAt = DateTime.Now;

			_context.Reviews.Add(review);

			eventEntity.TotalScore += request.RatingValue;
			eventEntity.RatingCount += 1;
			eventEntity.RatingAverage =
				(int)eventEntity.TotalScore / eventEntity.RatingCount;

			await _context.SaveChangesAsync();
		}
	}
}
