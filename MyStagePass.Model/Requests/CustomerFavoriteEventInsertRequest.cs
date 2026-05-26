using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace MyStagePass.Model.Requests
{
	public class CustomerFavoriteEventInsertRequest
	{
		[JsonIgnore]
		public int CustomerID { get; set; }

		[Required]
		public int EventID { get; set; }
	}
}