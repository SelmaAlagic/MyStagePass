namespace MyStagePass.Services.Database
{
	public class CustomerFavoriteEvent
	{
		public int CustomerFavoriteEventID {  get; set; } 
		public int CustomerID { get; set; }
		public int EventID { get; set; }
	}
}
