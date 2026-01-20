using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.DTOs;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;
using QuestPDF.Infrastructure;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using SkiaSharp;

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

		public byte[] GeneratePdfReport(SalesReportDto data, int month, int year)
		{
			QuestPDF.Settings.License = LicenseType.Community;

			return Document.Create(container =>
			{
				container.Page(page =>
				{
					page.Margin(1, Unit.Centimetre);
					page.PageColor(Colors.White);
					page.Size(PageSizes.A4);

					page.Header().PaddingBottom(15).Column(col =>
					{
						col.Item().AlignCenter().Text("SALES OVERVIEW").FontSize(20).Bold().FontColor(Colors.Blue.Darken3);
						col.Item().AlignCenter().Text($"{month}/{year}.").FontSize(14).FontColor(Colors.Grey.Medium);
					});

					page.Content().Column(col =>
					{
						col.Item().PaddingTop(25).Row(row =>
						{
							row.RelativeItem().Component(new MetricCard("Total Tickets", data.TotalTicketsSold.ToString()));
							row.Spacing(8);
							row.RelativeItem().Component(new MetricCard("Total Revenue", $"{data.TotalRevenue} KM"));
							row.Spacing(8);
							row.RelativeItem().Component(new MetricCard("Top Performer", data.TopPerformer));
							row.Spacing(8);
							row.RelativeItem().Component(new MetricCard("Top City", data.TopLocation));
						});

						col.Item().PaddingTop(35).AlignCenter().Text("Top performers by tickets sale").FontSize(12).SemiBold();
						col.Item().PaddingTop(20).AlignCenter().Height(230).Image(GenerateBarChart(data.PerformerSales));

						col.Item().PaddingTop(30).AlignCenter().Text("Top locations by tickets sale").FontSize(12).SemiBold();
						col.Item().PaddingTop(15).AlignCenter().Height(230).Image(GenerateBarChart(data.LocationSales));
					});

					page.Footer().AlignCenter().Text(x => {
						x.Span("MyStagePass Analytics - Page ");
						x.CurrentPageNumber();
					});
				});
			}).GeneratePdf();
		}

		private byte[] GenerateBarChart(List<ChartItemDto> items)
		{
			if (items == null || !items.Any())
			{
				using var emptySurface = SKSurface.Create(new SKImageInfo(1, 1));
				return emptySurface.Snapshot().Encode(SKEncodedImageFormat.Png, 100).ToArray();
			}

			int width = 700;
			int height = 400;
			using var surface = SKSurface.Create(new SKImageInfo(width, height));
			var canvas = surface.Canvas;
			canvas.Clear(SKColors.White);

			var barPaint = new SKPaint { Color = SKColor.Parse(_turquoiseColor), IsAntialias = true };
			var textPaint = new SKPaint { Color = SKColors.Black, TextSize = 13, IsAntialias = true };
			var linePaint = new SKPaint { Color = SKColors.LightGray, StrokeWidth = 1 };

			float maxValue = items.Max(x => x.Value);
			maxValue = (float)Math.Ceiling(maxValue / 100) * 100;
			if (maxValue == 0) maxValue = 100;

			float leftMargin = 60;
			float rightMargin = 40;
			float bottomMargin = 70;
			float topMargin = 30;

			float chartHeight = height - topMargin - bottomMargin;
			float chartTotalWidth = width * 0.6f;
			float chartStartX = (width - chartTotalWidth) / 2;

			float barWidth = 40;
			float gap = 35;
			float contentWidth = items.Count * barWidth + (items.Count - 1) * gap;
			float barsStartX = chartStartX + (chartTotalWidth - contentWidth) / 2;

			int steps = 5;
			for (int i = 0; i <= steps; i++)
			{
				float y = height - bottomMargin - (i * (chartHeight / steps));
				float val = (maxValue / steps) * i;
				canvas.DrawText(val.ToString(), leftMargin - 40, y + 5, textPaint);
				float lineStartX = chartStartX - 10;
				float lineEndX = chartStartX + chartTotalWidth + 10;
				canvas.DrawLine(lineStartX, y, lineEndX, y, linePaint);
			}

			for (int i = 0; i < items.Count; i++)
			{
				float barHeight = (items[i].Value / maxValue) * chartHeight;
				float x = barsStartX + (i * (barWidth + gap));
				float yTop = height - bottomMargin - barHeight;
				float yBottom = height - bottomMargin;

				canvas.DrawRect(new SKRect(x, yTop, x + barWidth, yBottom), barPaint);

				float labelX = x + (barWidth / 2);
				float labelY = yBottom + 22;

				string label = items[i].Name;
				if (label.Length > 12)
					label = label.Substring(0, 10) + ".";

				canvas.DrawText(label, labelX, labelY, new SKPaint
				{
					Color = SKColors.Black,
					TextSize = 11,
					IsAntialias = true,
					Typeface = SKTypeface.FromFamilyName("Arial", SKFontStyle.Bold),
					TextAlign = SKTextAlign.Center
				});

				canvas.DrawText(
					items[i].Value.ToString(),
					labelX,
					yTop - 5,
					new SKPaint
					{
						Color = SKColors.Black,
						TextSize = 11,
						IsAntialias = true,
						Typeface = SKTypeface.FromFamilyName("Arial", SKFontStyle.Bold),
						TextAlign = SKTextAlign.Center
					});
			}

			return surface.Snapshot().Encode(SKEncodedImageFormat.Png, 100).ToArray();
		}
	}

	public class MetricCard : IComponent
	{
		private string Title { get; }
		private string Value { get; }
		public MetricCard(string title, string value) { Title = title; Value = value; }

		public void Compose(IContainer container)
		{
			container
				.Border(1.0f)
				.BorderColor(Colors.Black)
				.CornerRadius(8)
				.Padding(10)
				.Column(col => {
					col.Item().AlignCenter().Text(Title).FontSize(10).FontColor(Colors.Black);
					col.Item().AlignCenter().Text(Value).FontSize(12).Bold();
				});
		}
	}
}