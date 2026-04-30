using System.ComponentModel.DataAnnotations.Schema;

namespace MyStagePass.Services.Database
{
	public class Purchase
	{
		public int PurchaseID { get; set; }
		public DateTime PurchaseDate { get; set; }
		public virtual Customer Customer { get; set; } = null!;
		public int CustomerID {  get; set; }
		public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();
		public bool IsDeleted { get; set; } = false;
		public string? PaymentIntentId { get; set; }
		public bool? IsRefunded { get; set; }

		[NotMapped]
		public int Total => Tickets.Sum(i => i.Price);
	}
}
