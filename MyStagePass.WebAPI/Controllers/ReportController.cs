using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.DTOs;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles = "Admin")]
	public class ReportsController : ControllerBase
	{
		private readonly IReportService _reportService;

		public ReportsController(IReportService reportService)
		{
			_reportService = reportService;
		}

		[HttpGet]
		public async Task<SalesReportDto> Get(int month, int year)
		{
			return await _reportService.GetMonthlyReportData(month, year);
		}

		[HttpGet("export-pdf")]
		public async Task<IActionResult> ExportPdf([FromQuery] int month, [FromQuery] int year)
		{
			var data = await _reportService.GetMonthlyReportData(month, year);
			var pdfBytes = _reportService.GeneratePdfReport(data, month, year);
			return File(pdfBytes, "application/pdf", $"Izvjestaj_{month}_{year}.pdf");
		}
	}
}