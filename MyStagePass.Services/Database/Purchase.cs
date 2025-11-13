using System.ComponentModel.DataAnnotations.Schema;

namespace MyStagePass.Services.Database
{
	public class Purchase
	{
		public int PurchaseID { get; set; }
		public DateTime PurchaseDate { get; set; }
		public int CustomerID {  get; set; }
		//public virtual Customer Customer { get; set; } = null!;
		public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

		[NotMapped]
		public int Total => Tickets.Sum(i => i.Price);
	}
}
//provjeriti da li je bolje da kupovina podrazumijeva samo jednu kartu ili njih vise kao sto je sada stavljeno?