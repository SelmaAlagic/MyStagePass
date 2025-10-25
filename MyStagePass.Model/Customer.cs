using System;
using System.Collections.Generic;
using System.Text;

namespace MyStagePass.Model
{
	public class Customer
	{
		public int CustomerID {  get; set; }
		public int UserID {  get; set; }
		public virtual User User { get; set; } = null!;
		public ICollection<Event> FavoriteEvents { get; set; } = new List<Event>();
		public ICollection<Performer> FavoritePerformers { get; set; } = new List<Performer>();
		public ICollection<Purchase> Purchases { get; set; } = new List<Purchase>();

	}
}
