using System.Collections.Generic;

namespace MyStagePass.Model.DTOs
{
	public class EventRecommendation
	{
		public string EventName { get; set; }
		public string PerformerName { get; set; }
		public string EventDate { get; set; }
		public string CityName {  get; set; }
		public Dictionary<string, int> TicketPrices { get; set; } = new Dictionary<string, int>();
		public double SimilarityScore { get; set; }
	}
}