using Microsoft.EntityFrameworkCore;
using MyStagePass.Model;

namespace MyStagePass.Services.Database
{
	public class MyStagePassDbContext:DbContext
	{
		public MyStagePassDbContext(DbContextOptions<MyStagePassDbContext> options) : base(options)	{}

		public DbSet<Admin> Admin { get; set; }
		public DbSet<City> Cities { get; set; }
		public DbSet<Country> Countries { get; set; }
		public DbSet<Customer> Customers { get; set; }
		public DbSet<Event> Events { get; set; }
		public DbSet<Genre> Genres { get; set; }
		public DbSet<Location> Locations { get; set; }
		public DbSet<Performer> Performers { get; set; }
		public DbSet<Purchase> Purchases { get; set; }
		public DbSet<Status> Statuses { get; set; }
		public DbSet<Ticket> Tickets { get; set; }
		public DbSet<TicketType> TicketTypes { get; set; }
		public DbSet<User> Users { get; set; }

		protected override void OnModelCreating(ModelBuilder modelBuilder)
		{
			base.OnModelCreating(modelBuilder);

			modelBuilder.Entity<User>()
 				.HasIndex(u => u.Email)  //index za pretragu po usernameu i emailu, primjer
				.IsUnique();

			modelBuilder.Entity<User>()
				.HasIndex(u => u.Username)
				.IsUnique();
		}
	}
}
