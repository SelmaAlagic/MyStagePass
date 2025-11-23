namespace MyStagePass.Model.Models
{
	public class CustomerFavoriteEvent
	{
		public int CustomerFavoriteEventID { get; set; }
		public int CustomerID { get; set; }
		public virtual Customer Customer { get; set; } = null!;
		public int EventID { get; set; }
		public virtual Event Event { get; set; } = null!;
	}
}