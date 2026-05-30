using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.DTOs;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class ReportService : IReportService
	{
		private readonly MyStagePassDbContext _context;
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
			report.TotalRevenue = events.SelectMany(e => e.Tickets).Sum(t => t.Price);

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

		public async Task<CancelledEventsReportDto> GetCancelledEventsReport(int cityId)
		{
			var city = await _context.Cities.FindAsync(cityId);

			var cancelledEvents = await _context.Events
				.Include(e => e.Location).ThenInclude(l => l.City)
				.Include(e => e.Tickets).ThenInclude(t => t.Purchase)
				.Where(e => e.Location.CityID == cityId && e.StatusID == Status.CancelledID)
				.ToListAsync();

			var items = cancelledEvents.Select(e => new CancelledEventItem
			{
				EventName = e.EventName,
				LocationName = e.Location.LocationName,
				EventDate = e.EventDate,
				TicketsSold = e.TicketsSold,
				RefundsNeeded = e.Tickets.Count(t => t.PurchaseID != 0),
				TotalRefundAmount = e.Tickets.Where(t => t.PurchaseID != 0).Sum(t => (decimal)t.Price)
			}).ToList();

			return new CancelledEventsReportDto
			{
				CityName = city?.Name ?? "N/A",
				TotalCancelledEvents = items.Count,
				TotalTicketsSold = items.Sum(i => i.TicketsSold),
				TotalRefundsNeeded = items.Sum(i => i.RefundsNeeded),
				Events = items
			};
		}
	}
}