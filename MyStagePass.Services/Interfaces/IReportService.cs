using MyStagePass.Model.DTOs;

namespace MyStagePass.Services.Interfaces
{
	public interface IReportService
	{
		Task<SalesReportDto> GetMonthlyReportData(int month, int year);
		Task<CancelledEventsReportDto> GetCancelledEventsReport(int cityId);
	}
}