using Microsoft.EntityFrameworkCore;
using MyStagePass.Model.DTOs;
using MyStagePass.Services.Database;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.Services.Services
{
	public class RecommendedService : IRecommendedService
	{
		private readonly MyStagePassDbContext _context;

		public RecommendedService(MyStagePassDbContext context)
		{
			_context = context;
		}

		public async Task<List<EventRecommendation>> GetRecommendationsForCustomerAsync(int customerId, int topN = 10)
		{
			var favoriteEventIds = await _context.CustomerFavoriteEvents
				.Where(f => f.CustomerID == customerId)
				.Select(f => f.EventID)
				.ToListAsync();

			var purchasedEventIds = await _context.Purchases
				.Where(p => p.CustomerID == customerId && !p.IsDeleted)
				.SelectMany(p => p.Tickets)
				.Where(t => !t.IsDeleted)
				.Select(t => t.EventID)
				.Distinct()
				.ToListAsync();

			var allInteractedEventIds = favoriteEventIds.Concat(purchasedEventIds).Distinct().ToList();

			if (!allInteractedEventIds.Any())
				return await GetPopularEventsAsync(topN);

			var interactedEvents = await _context.Events
				.Include(e => e.Performer).ThenInclude(p => p.Genres).ThenInclude(pg => pg.Genre)
				.Include(e => e.Location).ThenInclude(l => l.City)
				.Where(e => allInteractedEventIds.Contains(e.EventID))
				.ToListAsync();

			var userProfile = BuildUserProfile(interactedEvents, purchasedEventIds);

			var availableEvents = await _context.Events
				.Include(e => e.Performer).ThenInclude(p => p.Genres).ThenInclude(pg => pg.Genre)
				.Include(e => e.Location).ThenInclude(l => l.City)
				.Include(e => e.Tickets)
				.Where(e => e.EventDate > DateTime.Now)
				.Where(e => !allInteractedEventIds.Contains(e.EventID))
				.ToListAsync();

			var recommendations = new List<EventRecommendation>();

			foreach (var ev in availableEvents)
			{
				var similarity = CalculateSimilarity(userProfile, ev);

				recommendations.Add(new EventRecommendation
				{
					EventName = ev.EventName,
					PerformerName = ev.Performer?.ArtistName ?? "",
					EventDate = ev.EventDate.ToString("dd.MM.yyyy. HH:mm"),
					CityName = ev.Location?.City?.Name ?? "Unknown",

					TicketPrices = new Dictionary<string, int>
					{
						{ "Regular", ev.RegularPrice },
						{ "VIP", ev.VipPrice },
						{ "Premium", ev.PremiumPrice }
					},
					SimilarityScore = Math.Round(similarity.TotalScore * 100, 2)
				});
			}
			return recommendations.OrderByDescending(r => r.SimilarityScore).Take(topN).ToList();
		}

		private UserProfile BuildUserProfile(List<Database.Event> interactedEvents, List<int> purchasedEventIds)
		{
			var profile = new UserProfile();
			var weightedEvents = interactedEvents.Select(ev =>
			{
				double weight = purchasedEventIds.Contains(ev.EventID) ? 3.0 : 1.0;
				return new { Event = ev, Weight = weight };
			}).ToList();

			var totalWeight = weightedEvents.Sum(x => x.Weight);

			var genreScores = new Dictionary<string, double>();
			foreach (var item in weightedEvents)
			{
				var genres = item.Event.Performer?.Genres
					?.Select(pg => pg.Genre?.Name)
					.Where(g => !string.IsNullOrEmpty(g))
					.ToList() ?? new List<string>();

				foreach (var genre in genres)
				{
					if (!genreScores.ContainsKey(genre))
						genreScores[genre] = 0;
					genreScores[genre] += item.Weight;
				}
			}
			profile.GenrePreferences = genreScores.ToDictionary(x => x.Key, x => x.Value / totalWeight);

			var cityScores = new Dictionary<string, double>();
			foreach (var item in weightedEvents)
			{
				var city = item.Event.Location?.City?.Name ?? "Unknown";
				if (!cityScores.ContainsKey(city))
					cityScores[city] = 0;
				cityScores[city] += item.Weight;
			}
			profile.CityPreferences = cityScores.ToDictionary(x => x.Key, x => x.Value / totalWeight);

			var artistScores = new Dictionary<string, double>();
			foreach (var item in weightedEvents)
			{
				var artist = item.Event.Performer?.ArtistName ?? "Unknown";
				if (!artistScores.ContainsKey(artist))
					artistScores[artist] = 0;
				artistScores[artist] += item.Weight;
			}
			profile.ArtistPreferences = artistScores.ToDictionary(x => x.Key, x => x.Value / totalWeight);

			profile.AveragePricePreference = weightedEvents.Sum(x => (double)x.Event.RegularPrice * x.Weight) / totalWeight;

			return profile;
		}

		private (double TotalScore, Dictionary<string, double> Reasons) CalculateSimilarity(UserProfile profile, Database.Event ev)
		{
			var reasons = new Dictionary<string, double>();
			var eventGenres = ev.Performer?.Genres?.Select(pg => pg.Genre?.Name).Where(g => !string.IsNullOrEmpty(g)).ToList() ?? new List<string>();

			double genreScore = 0;
			if (eventGenres.Any())
			{
				foreach (var genre in eventGenres)
					if (profile.GenrePreferences.ContainsKey(genre))
						genreScore += profile.GenrePreferences[genre];

				genreScore /= eventGenres.Count;
			}
			reasons["Genre"] = genreScore;

			var city = ev.Location?.City?.Name ?? "";
			double cityScore = profile.CityPreferences.ContainsKey(city) ? profile.CityPreferences[city] : 0.1;
			reasons["City"] = cityScore;

			var artist = ev.Performer?.ArtistName ?? "";
			double artistScore = profile.ArtistPreferences.ContainsKey(artist) ? profile.ArtistPreferences[artist] : 0;
			reasons["Artist"] = artistScore;

			double priceDifference = Math.Abs((double)ev.RegularPrice - profile.AveragePricePreference);
			double maxPriceDiff = profile.AveragePricePreference * 0.5;
			double priceScore = Math.Max(0, 1 - (priceDifference / maxPriceDiff));
			reasons["Price"] = priceScore;

			double totalScore = (genreScore * 0.40) + (cityScore * 0.20) + (artistScore * 0.30) + (priceScore * 0.10);

			return (totalScore, reasons);
		}

		private async Task<List<EventRecommendation>> GetPopularEventsAsync(int topN)
		{
			var popularEvents = await _context.Events
				.Include(e => e.Performer).ThenInclude(p => p.Genres).ThenInclude(pg => pg.Genre)
				.Include(e => e.Location).ThenInclude(l => l.City)
				.Include(e => e.Tickets)
				.Where(e => e.EventDate > DateTime.Now)
				.OrderByDescending(e => e.TicketsSold)
				.Take(topN)
				.ToListAsync();

			return popularEvents.Select(e => new EventRecommendation
			{
				EventName = e.EventName,
				PerformerName = e.Performer?.ArtistName ?? "",
				EventDate = e.EventDate.ToString("dd.MM.yyyy. HH:mm"),
				CityName = e.Location?.City?.Name ?? "Unknonwn",

				TicketPrices = new Dictionary<string, int>
				{
					{ "Regular", e.RegularPrice },
					{ "VIP", e.VipPrice },
					{ "Premium", e.PremiumPrice }
				},
				SimilarityScore = 50.0
			}).ToList();
		}

		private class UserProfile
		{
			public Dictionary<string, double> GenrePreferences { get; set; } = new();
			public Dictionary<string, double> CityPreferences { get; set; } = new();
			public Dictionary<string, double> ArtistPreferences { get; set; } = new();
			public double AveragePricePreference { get; set; }
		}
	}
}