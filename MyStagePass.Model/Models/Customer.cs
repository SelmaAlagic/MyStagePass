using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class Customer
    {
        public int CustomerID { get; set; }
        public int UserID { get; set; }
        public virtual User User { get; set; } = null!;
		public virtual ICollection<CustomerFavoriteEvent> FavoriteEvents { get; set; } = new List<CustomerFavoriteEvent>();
		public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
		public virtual ICollection<Purchase> Purchases { get; set; } = new List<Purchase>();
	}
}