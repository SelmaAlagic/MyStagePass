namespace MyStagePass.Services.Database
{
	public class CustomerFavoriteEvent
	{
		public int CustomerFavoriteEventID {  get; set; } 
		public int CustomerID { get; set; }
		//public Customer Customer { get; set; } = null!;

		public int EventID { get; set; }
		//public Event Event { get; set; } = null!;
	}
}
