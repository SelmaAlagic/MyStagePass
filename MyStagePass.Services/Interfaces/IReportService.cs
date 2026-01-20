using MyStagePass.Model.DTOs;

namespace MyStagePass.Services.Interfaces
{
	public interface IReportService
	{
		Task<SalesReportDto> GetMonthlyReportData(int month, int year);
		byte[] GeneratePdfReport(SalesReportDto data, int month, int year);
	}
}