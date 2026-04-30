using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.ML;
using Microsoft.ML.Trainers;
using MyStagePass.Model.DTOs;
using MyStagePass.Services.Database;

namespace MyStagePass.Services.Services
{
	public class RecommendedService : IRecommendedService
	{
		private readonly MyStagePassDbContext _context;
		private readonly ILogger<RecommendedService> _logger;
		private readonly ICurrentUserService _currentUserService;

		private static MLContext? _ml;
		private static ITransformer? _model;
		private static PredictionEngine<EventInteraction, EventPrediction>? _predEngine;
		private static readonly object _lock = new object();
		private static DateTime _lastTrained = DateTime.MinValue;

		private static readonly string _modelPath = Path.Combine(
			AppContext.BaseDirectory, "recommender-model.ml");

		public RecommendedService(
			MyStagePassDbContext context,
			ILogger<RecommendedService> logger,
			ICurrentUserService currentUserService)
		{
			_context = context;
			_logger = logger;
			_currentUserService=currentUserService;
		}

		private int GetCurrentCustomerId()
		{
			var id = _currentUserService.GetCustomerId();
			if (id == 0)
				throw new UnauthorizedAccessException("Customer ID not found in token.");
			return id;
		}

		private class EventInteraction
		{
			public float CustomerId { get; set; }
			public float EventId { get; set; }
			public float Label { get; set; }
		}

		private class EventPrediction
		{
			public float Score { get; set; }
		}

		private async Task EnsureModelTrainedAsync()
		{
			if (_model != null && (DateTime.UtcNow - _lastTrained).TotalHours < 1)
				return;

			List<EventInteraction> allInteractions;

			var purchases = await _context.Purchases
				.Where(p => !p.IsDeleted)
				.SelectMany(p => p.Tickets.Where(t => !t.IsDeleted)
					.Select(t => new EventInteraction
					{
						CustomerId = p.CustomerID,
						EventId = t.EventID,
						Label = 3f
					}))
				.ToListAsync();

			var favorites = await _context.CustomerFavoriteEvents
				.Select(f => new EventInteraction
				{
					CustomerId = f.CustomerID,
					EventId = f.EventID,
					Label = 1f
				})
				.ToListAsync();

			allInteractions = purchases.Concat(favorites).ToList();

			if (allInteractions.Count < 5)
			{
				_model = null;
				return;
			}

			lock (_lock)
			{
				if (_model != null && (DateTime.UtcNow - _lastTrained).TotalHours < 1)
					return;

				_ml = new MLContext(seed: 42);

				if (_model == null && File.Exists(_modelPath))
				{
					try
					{
						_model = _ml.Model.Load(_modelPath, out _);
						_predEngine = _ml.Model
							.CreatePredictionEngine<EventInteraction, EventPrediction>(_model);
						_lastTrained = File.GetLastWriteTimeUtc(_modelPath);
						_logger.LogInformation(
							"Recommender model učitan s diska: {Path}", _modelPath);

						if ((DateTime.UtcNow - _lastTrained).TotalHours < 1)
							return;
					}
					catch (Exception ex)
					{
						_logger.LogWarning(ex,
							"Učitavanje modela s diska nije uspjelo, treniram novi.");
						_model = null;
					}
				}

				var data = _ml.Data.LoadFromEnumerable(allInteractions);

				var pipeline = _ml.Transforms.Conversion.MapValueToKey(
						outputColumnName: "CustomerIdKey",
						inputColumnName: nameof(EventInteraction.CustomerId))
					.Append(_ml.Transforms.Conversion.MapValueToKey(
						outputColumnName: "EventIdKey",
						inputColumnName: nameof(EventInteraction.EventId)))
					.Append(_ml.Recommendation().Trainers.MatrixFactorization(
						new MatrixFactorizationTrainer.Options
						{
							MatrixColumnIndexColumnName = "CustomerIdKey",
							MatrixRowIndexColumnName = "EventIdKey",
							LabelColumnName = nameof(EventInteraction.Label),
							NumberOfIterations = 20,
							ApproximationRank = 8
						}));

				_model = pipeline.Fit(data);

				_predEngine = _ml.Model
					.CreatePredictionEngine<EventInteraction, EventPrediction>(_model);

				try
				{
					_ml.Model.Save(_model, data.Schema, _modelPath);
					_logger.LogInformation(
						"Recommender model sačuvan na disk: {Path}", _modelPath);
				}
				catch (Exception ex)
				{
					_logger.LogWarning(ex, "Čuvanje modela na disk nije uspjelo.");
				}

				_lastTrained = DateTime.UtcNow;
				_logger.LogInformation(
					"Matrix factorization model treniran na {Count} interakcija.",
					allInteractions.Count);
			}
		}

		private float GetCollaborativeScore(int customerId, int eventId)
		{
			if (_predEngine == null)
				return 0f;

			try
			{
				lock (_lock)
				{
					var prediction = _predEngine.Predict(new EventInteraction
					{
						CustomerId = customerId,
						EventId = eventId,
						Label = 0
					});
					return Math.Max(0f, prediction.Score);
				}
			}
			catch (Exception ex)
			{
				_logger.LogWarning(ex,
					"Predikcija nije uspjela za korisnika {CustomerId}, dogadjaj {EventId}.",
					customerId, eventId);
				return 0f;
			}
		}

		public async Task<List<EventRecommendation>> GetRecommendationsForCustomerAsync(int topN = 10)
		{
			var customerId = GetCurrentCustomerId();

			await EnsureModelTrainedAsync();

			var purchasedEventIds = await _context.Purchases
				.Where(p => p.CustomerID == customerId && !p.IsDeleted)
				.SelectMany(p => p.Tickets)
				.Where(t => !t.IsDeleted)
				.Select(t => t.EventID)
				.Distinct()
				.ToListAsync();

			var favoriteEventIds = await _context.CustomerFavoriteEvents
				.Where(f => f.CustomerID == customerId)
				.Select(f => f.EventID)
				.ToListAsync();

			var allInteractedEventIds = purchasedEventIds
				.Concat(favoriteEventIds)
				.Distinct()
				.ToList();

			var availableEvents = await _context.Events
				.Include(e => e.Performer)
					.ThenInclude(p => p.Genres)
						.ThenInclude(pg => pg.Genre)
				.Include(e => e.Location)
					.ThenInclude(l => l.City)
				.Where(e => e.EventDate > DateTime.UtcNow
						 && e.StatusID != Status.CancelledID
						 && e.StatusID == Status.ApprovedID
						 && !allInteractedEventIds.Contains(e.EventID))
				.ToListAsync();

			if (!availableEvents.Any())
				return new List<EventRecommendation>();

			if (!allInteractedEventIds.Any())
				return GetPopularEvents(availableEvents, topN);

			return await GetHybridRecommendationsAsync(
				availableEvents, allInteractedEventIds, purchasedEventIds, customerId, topN);
		}

		private async Task<List<EventRecommendation>> GetHybridRecommendationsAsync(
			List<Database.Event> availableEvents,
			List<int> interactedEventIds,
			List<int> purchasedIds,
			int customerId,
			int topN)
		{
			var interactedEvents = await _context.Events
				.Include(e => e.Performer)
					.ThenInclude(p => p.Genres)
						.ThenInclude(pg => pg.Genre)
				.Include(e => e.Location)
				.Where(e => interactedEventIds.Contains(e.EventID))
				.ToListAsync();

			var purchasedEventIds = new HashSet<int>(purchasedIds);

			var preferredCityIds = interactedEvents
				.Where(e => e.Location?.CityID != null)
				.Select(e => e.Location!.CityID)
				.Distinct()
				.ToList();

			var genreWeights = new Dictionary<int, float>();
			foreach (var ev in interactedEvents)
			{
				float weight = purchasedEventIds.Contains(ev.EventID) ? 3f : 1f;
				foreach (var g in ev.Performer?.Genres ?? Enumerable.Empty<PerformerGenre>())
				{
					if (!genreWeights.ContainsKey(g.GenreID))
						genreWeights[g.GenreID] = 0f;
					genreWeights[g.GenreID] += weight;
				}
			}

			var topGenreIds = genreWeights
				.OrderByDescending(x => x.Value)
				.Take(3)
				.Select(x => x.Key)
				.ToList();

			var preferredPerformerIds = interactedEvents
				.Select(e => e.PerformerID)
				.Distinct()
				.ToList();

			var avgPrice = interactedEvents
				.Where(e => e.RegularPrice > 0)
				.Select(e => (double)e.RegularPrice)
				.DefaultIfEmpty(0)
				.Average();

			var avgRating = interactedEvents
				.Where(e => e.RatingAverage > 0)
				.Select(e => (double)e.RatingAverage)
				.DefaultIfEmpty(0)
				.Average();

			var scored = availableEvents.Select(ev =>
			{
				var eventGenreIds = ev.Performer?.Genres?
					.Select(g => g.GenreID).ToList() ?? new List<int>();

				float genreScore = eventGenreIds
					.Where(g => genreWeights.ContainsKey(g))
					.Sum(g => genreWeights[g]);

				float performerScore = preferredPerformerIds.Contains(ev.PerformerID) ? 20f : 0f;

				float ratingScore = 0f;
				if (ev.RatingAverage > 0)
				{
					ratingScore = ev.RatingAverage * 3f;
					if (ev.RatingAverage > avgRating && avgRating > 0)
						ratingScore += 5f;
				}

				float priceScore = 0f;
				if (avgPrice > 0 && ev.RegularPrice > 0)
				{
					double priceDiff = Math.Abs(ev.RegularPrice - avgPrice) / avgPrice;
					priceScore = priceDiff < 0.3 ? 5f : priceDiff < 0.6 ? 2f : 0f;
				}

				float locationScore = preferredCityIds.Contains(ev.Location?.CityID ?? -1) ? 10f : 0f;

				float contentScore = genreScore + performerScore + ratingScore + priceScore + locationScore;

				float collaborativeScore = GetCollaborativeScore(customerId, ev.EventID) * 5f;

				float totalScore = contentScore + collaborativeScore;
				return (Event: ev, Score: totalScore, CollaborativeScore: collaborativeScore);
			})
			.Where(x => x.Score > 0)
			.OrderByDescending(x => x.Score)
			.Take(topN)
			.ToList();

			if (!scored.Any())
				return GetPopularEvents(availableEvents, topN);

			var topGenreName = topGenreIds.Any()
				? (await _context.Genres.FindAsync(topGenreIds.First()))?.Name ?? "similar"
				: "similar";

			return scored
				.Select(s => MapToRecommendation(s.Event, s.Score, topGenreName, avgRating, s.CollaborativeScore > 0))
				.ToList();
		}

		private List<EventRecommendation> GetPopularEvents(
			List<Database.Event> events, int topN)
		{
			return events
				.OrderByDescending(e => e.TicketsSold)
				.Take(topN)
				.Select(e => MapToRecommendation(e, e.TicketsSold, null, 0, false))
				.ToList();
		}

		private EventRecommendation MapToRecommendation(
			Database.Event ev,
			double score,
			string? topGenreName,
			double userAvgRating,
			bool hasCollaborativeBoost)
		{
			string reason;

			if (topGenreName == null)
			{
				reason = "Trending — this event is among the most popular right now.";
			}
			else
			{
				var parts = new List<string>();

				if (ev.Performer?.Genres?.Any() == true)
					parts.Add($"matches your preferred {topGenreName} genre");

				if (ev.RatingAverage > 0)
				{
					if (userAvgRating > 0 && ev.RatingAverage > userAvgRating)
						parts.Add($"is rated above your usual events ({ev.RatingAverage:F1}★)");
					else
						parts.Add($"has a strong rating of {ev.RatingAverage:F1}★");
				}

				if (hasCollaborativeBoost)
					parts.Add("is popular among users with similar taste");

				reason = parts.Any()
					? $"Recommended because this event {string.Join(" and ", parts)}."
					: $"Recommended based on your activity in {topGenreName} events.";
			}

			return new EventRecommendation
			{
				EventName = ev.EventName,
				PerformerName = ev.Performer?.ArtistName ?? "",
				EventDate = ev.EventDate,
				CityName = ev.Location?.City?.Name ?? "Unknown",
				TicketPrices = new Dictionary<string, int>
				{
					{ "Regular", ev.RegularPrice },
					{ "VIP", ev.VipPrice },
					{ "Premium", ev.PremiumPrice }
				},
				SimilarityScore = Math.Round(score, 2),
				RecommendationReason = reason
			};
		}
	}
}