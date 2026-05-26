using System;
using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class EventUpdateRequest
	{
		[MinLength(5)]
		public string? EventName { get; set; }

		[MinLength(10)]
		public string? Description { get; set; }

		[Range(1, int.MaxValue, ErrorMessage = "Price must be greater than 0")]
		public int? RegularPrice { get; set; }

		[Range(1, int.MaxValue, ErrorMessage = "Price must be greater than 0")]
		public int? VipPrice { get; set; }

		[Range(1, int.MaxValue, ErrorMessage = "Price must be greater than 0")]
		public int? PremiumPrice { get; set; }

		public int? PerformerID { get; set; }
		public DateTime? EventDate { get; set; }
	}
}