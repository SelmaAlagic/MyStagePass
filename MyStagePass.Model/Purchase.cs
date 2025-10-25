using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;

namespace MyStagePass.Model
{
	public class Purchase
	{
		public int PurchaseID { get; set; }
		public DateTime PurchaseDate { get; set; }
		public int CustomerID {  get; set; }
		public virtual Customer Customer { get; set; } = null!;
		public virtual ICollection<Ticket> Tickets { get; set; } = new List<Ticket>();

		[NotMapped]
		public float Total => Tickets.Sum(i => i.Price);
	}
}
