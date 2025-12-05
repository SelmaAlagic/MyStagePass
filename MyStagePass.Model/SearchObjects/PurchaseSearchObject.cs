using System;

namespace MyStagePass.Model.SearchObjects
{
	public class PurchaseSearchObject : BaseSearchObject
	{
		public int? CustomerID { get; set; }
		public DateTime? DateFrom { get; set; }
		public DateTime? DateTo { get; set; }
	}
}