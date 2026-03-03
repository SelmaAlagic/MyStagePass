using MyStagePass.Model.DTOs;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;

namespace MyStagePass.Services.Interfaces
{
	public interface IPerformerService : ICRUDService<Performer, PerformerSearchObject, PerformerInsertRequest, PerformerUpdateRequest>
	{
		Task<Performer> ApprovePerformer(int performerId, bool isApprove);
		Task<PerformerStatistics> GetMyStatistics(int performerId, int? month, int? year, int? eventId);
	}
}