using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Text;

namespace MyStagePass.Model.Requests
{
	public class EventUpdateRequest
	{
		[MinLength(5)]
		public string? EventName { get; set; }

		[MinLength(10)]
		public string? Description { get; set; }

		public int? RegularPrice { get; set; }

		public int? VipPrice { get; set; }

		public int? PremiumPrice { get; set; }

		public int? PerformerID { get; set; }

		public DateTime? EventDate { get; set; }

		public int? LocationID { get; set; }

	}
}

