using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.DTOs;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class ReportService : IReportService
	{
		private readonly MyStagePassDbContext _context;
		private readonly string _turquoiseColor = "#76e3d7";

		public ReportService(MyStagePassDbContext context)
		{
			_context = context;
		}

		public async Task<SalesReportDto> GetMonthlyReportData(int month, int year)
		{
			var events = await _context.Events
				.Include(e => e.Performer)
				.Include(e => e.Location).ThenInclude(l => l.City)
				.Include(e => e.Tickets)
				.Where(e => e.EventDate.Month == month && e.EventDate.Year == year)
				.ToListAsync();

			var report = new SalesReportDto();
			if (!events.Any()) return report;

			report.TotalTicketsSold = events.Sum(e => e.TicketsSold);
			report.TotalRevenue = events.SelectMany(e => e.Tickets).Where(t => !t.IsDeleted).Sum(t => t.Price);

			report.PerformerSales = events.GroupBy(e => e.Performer.ArtistName)
				.Select(g => new ChartItemDto { Name = g.Key ?? "N/A", Value = g.Sum(e => e.TicketsSold) })
				.OrderByDescending(x => x.Value).ToList();

			report.LocationSales = events.GroupBy(e => e.Location.City.Name)
				.Select(g => new ChartItemDto { Name = g.Key ?? "N/A", Value = g.Sum(e => e.TicketsSold) })
				.OrderByDescending(x => x.Value).ToList();

			report.TopPerformer = report.PerformerSales.FirstOrDefault()?.Name ?? "N/A";
			report.TopLocation = report.LocationSales.FirstOrDefault()?.Name ?? "N/A";

			return report;
		}
	}
}