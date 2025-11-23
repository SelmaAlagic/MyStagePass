using System;
using System.ComponentModel.DataAnnotations;

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
		public int RegularPrice { get; set; }

		[Required]
		public int VipPrice { get; set; }

		[Required]
		public int PremiumPrice { get; set; }

		[Required]
		public int PerformerID { get; set; }

		[Required]
		public DateTime EventDate { get; set; }

		[Required]
		public int LocationID { get; set; }
	}
}