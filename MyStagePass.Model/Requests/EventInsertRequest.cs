using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace MyStagePass.Model.Requests
{
	public class EventInsertRequest
	{
		[Required]
		[MinLength(5)]
		public string EventName { get; set; }

		[Required]
		[MinLength(10)]
		public string Description { get; set; }

		[Required]
		[Range(1, int.MaxValue, ErrorMessage = "Price must be greater than 0")]
		public int RegularPrice { get; set; }

		[Required]
		[Range(1, int.MaxValue, ErrorMessage = "Price must be greater than 0")]
		public int VipPrice { get; set; }

		[Required]
		[Range(1, int.MaxValue, ErrorMessage = "Price must be greater than 0")]
		public int PremiumPrice { get; set; }

		[JsonIgnore]
		public int PerformerID { get; set; }

		[Required]
		public DateTime EventDate { get; set; }

		[Required]
		public int LocationID { get; set; }
	}
}