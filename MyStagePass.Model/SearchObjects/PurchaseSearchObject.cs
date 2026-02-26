using System;
using System.Text.Json.Serialization;

namespace MyStagePass.Model.SearchObjects
{
	public class PurchaseSearchObject : BaseSearchObject
	{
		[JsonIgnore]
		public int? CustomerID { get; set; }
		public DateTime? DateFrom { get; set; }
		public DateTime? DateTo { get; set; }
	}
}