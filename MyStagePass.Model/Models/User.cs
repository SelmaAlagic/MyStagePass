using System.Collections.Generic;
using System.Linq;
using System.Text.Json.Serialization;

namespace MyStagePass.Model.Models
{
    public class User
    {
        public int UserID { get; set; }
        public string? FirstName { get; set; }
        public string? LastName { get; set; }
        public string? Username { get; set; }
        public string? Email { get; set; }

		[JsonIgnore]
        public string? Password { get; set; }

		[JsonIgnore]
		public string? Salt { get; set; }

        public string? PhoneNumber { get; set; }
        public byte[]? Image { get; set; }
        public bool IsActive { get; set; } = true;
		public virtual ICollection<Notification> Notifications { get; set; } = new List<Notification>();
		public ICollection<Performer> Performers { get; set; } = new List<Performer>();
		public ICollection<Customer> Customers { get; set; } = new List<Customer>();
		public virtual ICollection<Admin> Admins { get; set; } = new List<Admin>();
		public string Role
		{
			get
			{
				if (Admins?.Any() == true) return "Admin";
				if (Performers?.Any() == true) return "Performer";
				if (Customers?.Any() == true) return "Customer";
				return "User";
			}
		}
	}
}