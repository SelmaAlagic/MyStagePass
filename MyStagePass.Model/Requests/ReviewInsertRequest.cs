using System;
using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class ReviewInsertRequest
	{
		[Required]
		public int CustomerID { get; set; }

		[Required]
		public int EventID { get; set; }

		[Required]
		[Range(1,5, ErrorMessage = "Rating must be between 1 and 5 stars.")]
		public int RatingValue { get; set; } 
	}
}
