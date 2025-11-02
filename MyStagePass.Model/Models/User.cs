using System.Collections.Generic;

namespace MyStagePass.Model.Models
{
    public class User
    {
        public int UserID { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }

        //public string? Password { get; set; }

        //public string? Salt { get; set; }
        public string? PhoneNumber { get; set; }
        public byte[]? Image { get; set; }
        public bool IsActive { get; set; }
        public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
		public ICollection<Performer> Performers { get; set; } = new List<Performer>();
		public ICollection<Customer> Customers { get; set; } = new List<Customer>();
		public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
		public int AdminID { get; set; }
		public virtual Admin Admin { get; set; } = null!;

	}
}
