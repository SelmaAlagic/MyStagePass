using System.ComponentModel.DataAnnotations;

namespace MyStagePass.Model.Requests
{
	public class CustomerFavoriteEventInsertRequest
	{
		[Required]
		public int CustomerID { get; set; }

		[Required]
		public int EventID { get; set; }
	}
}