using System.Text.Json.Serialization;

namespace MyStagePass.Model.SearchObjects
{
	public class TicketSearchObject : BaseSearchObject
	{
		[JsonIgnore]
		public int? CustomerID { get; set; }
	}
}
