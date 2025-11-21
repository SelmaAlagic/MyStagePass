using Microsoft.EntityFrameworkCore;
using MyStagePass.Model;
using MyStagePass.Model.Models;
using MyStagePass.Services.Database.Seed;

namespace MyStagePass.Services.Database
{
	public partial class MyStagePassDbContext:DbContext
	{
		public MyStagePassDbContext(DbContextOptions<MyStagePassDbContext> options) : base(options)	{}

		public DbSet<Admin> Admins { get; set; }
		public DbSet<City> Cities { get; set; }
		public DbSet<Country> Countries { get; set; }
		public DbSet<Customer> Customers { get; set; }
		public DbSet<Event> Events { get; set; }
		public DbSet<Genre> Genres { get; set; }
		public DbSet<Location> Locations { get; set; }
		public DbSet<Notification> Notifications { get; set; }
		public DbSet<Performer> Performers { get; set; }
		public DbSet<Purchase> Purchases { get; set; }
		public DbSet<Review> Reviews { get; set; }
		public DbSet<Status> Statuses { get; set; }
		public DbSet<Ticket> Tickets { get; set; }
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

			modelBuilder.Entity<CustomerFavoriteEvent>(entity =>
			{
				entity.HasKey(ce => ce.CustomerFavoriteEventID);

				entity.HasIndex(ce => new { ce.EventID, ce.CustomerID })
					.IsUnique();

				entity.HasOne(ce => ce.Customer)  
					.WithMany(c => c.FavoriteEvents)
					.HasForeignKey(e => e.CustomerID)
					.OnDelete(DeleteBehavior.Cascade);

				entity.HasOne(ce => ce.Event)  
					.WithMany(ev => ev.FavoritedByCustomers)
					.HasForeignKey(e => e.EventID)
					.OnDelete(DeleteBehavior.ClientCascade);
			});

			modelBuilder.Entity<Ticket>(entity =>
			{
				entity.HasKey(t => t.TicketID);

				entity.Property(t => t.TicketType)
					.HasConversion<int>();

				//Purchase -> Ticket (brisanje Purchase briše karte)
				entity.HasOne(t => t.Purchase)
					.WithMany(p => p.Tickets)
					.HasForeignKey(t => t.PurchaseID)
					.OnDelete(DeleteBehavior.Cascade); 

				//Event -> Ticket (brisanje Event briše karte)
				entity.HasOne(t => t.Event)
					.WithMany(e => e.Tickets)
					.HasForeignKey(t => t.EventID)
					.OnDelete(DeleteBehavior.ClientCascade);
			});

			modelBuilder.Entity<Review>(entity =>
			{
				entity.HasKey(r => r.ReviewID);

				entity.HasIndex(r => new { r.EventID, r.CustomerID })
					  .IsUnique();

				entity.HasOne(r => r.Event)
					.WithMany(r => r.Reviews)
					.HasForeignKey(e => e.EventID)
					.OnDelete(DeleteBehavior.Cascade); //Kada se obriše event obriše se review

				entity.HasOne(r => r.Customer)
					.WithMany(r => r.Reviews)
					.HasForeignKey(u => u.CustomerID)
					.OnDelete(DeleteBehavior.ClientCascade); //kad se obrise customer ne obrise se review jer je ocjena bitna za prosjek ocjene izvodjaca, ali ne odzivljava setnull, pogledati sutra to
			});

			//var user = await _context.Users   --> kod client casacde-a svakog moram includeati u ovom slucaju reviews kad se brise user, i kod brisanja eventa onda isto za favoritevents...
			//.Include(u => u.Reviews)  
			//.FirstOrDefaultAsync(u => u.UserID == userId);

			modelBuilder.Entity<City>(entity =>
			{
				entity.HasOne(c => c.Country)
					.WithMany(co => co.Cities)
					.HasForeignKey(n => n.CountryID)
					.OnDelete(DeleteBehavior.Cascade);
			});

			modelBuilder.Entity<User>(entity =>
			{
				entity.HasMany(u => u.Admins)
					.WithOne(a => a.User)
					.HasForeignKey(a => a.UserID)
					.OnDelete(DeleteBehavior.Cascade);

				entity.HasMany(u => u.Performers)
					.WithOne(p => p.User)
					.HasForeignKey(p => p.UserID)
					.OnDelete(DeleteBehavior.Cascade);

				entity.HasMany(u => u.Customers)
					.WithOne(c => c.User)
					.HasForeignKey(c => c.UserID)
					.OnDelete(DeleteBehavior.Cascade);
			});

			modelBuilder.Entity<PerformerGenre>(entity =>
			{
				entity.HasKey(pg => pg.PerformerGenreID);

				entity.HasIndex(ce => new { ce.PerformerID, ce.GenreID })
				.IsUnique();

				entity.HasOne(p => p.Performer)
					.WithMany(g => g.Genres)
					.HasForeignKey(p => p.PerformerID)
					.OnDelete(DeleteBehavior.Cascade); 

				entity.HasOne(g => g.Genre)
					.WithMany(pg => pg.Performers)
					.HasForeignKey(g => g.GenreID)
					.OnDelete(DeleteBehavior.ClientCascade); 
			});

			modelBuilder.Entity<Location>(entity =>
			{
				entity.HasOne(c => c.City)
					.WithMany(l => l.Locations)
					.HasForeignKey(n => n.CityID)
					.OnDelete(DeleteBehavior.Cascade);
			});

			modelBuilder.Entity<Notification>(entity =>
			{
				entity.HasOne<User>()
					.WithMany(u => u.Notifications)
					.HasForeignKey(n => n.UserID)
					.OnDelete(DeleteBehavior.Cascade); // brisanje User -> briše sve njegove Notification
			});

			modelBuilder.Entity<Purchase>(entity =>
			{
				entity.HasOne<Customer>()
					.WithMany(co => co.Purchases)
					.HasForeignKey(n => n.CustomerID)
					.OnDelete(DeleteBehavior.Cascade);

			});

			modelBuilder.Entity<Event>(entity =>
			{
				entity.HasOne(c => c.Status)
					.WithMany(co => co.Events)
					.HasForeignKey(n => n.StatusID); //po defautu je restrict ili no action, ako brisem event status je netaknut, a ako hocu obrisati status, necu moci jer ima event sa istim

				entity.HasOne(e => e.Location)
				   .WithMany(l => l.Events)
				   .HasForeignKey(e => e.LocationID)
				   .OnDelete(DeleteBehavior.Restrict);
			});

			modelBuilder.Entity<Admin>().SeedData();
			modelBuilder.Entity<City>().SeedData();
			modelBuilder.Entity<Country>().SeedData();
			modelBuilder.Entity<Customer>().SeedData();
			modelBuilder.Entity<CustomerFavoriteEvent>().SeedData();
			modelBuilder.Entity<Event>().SeedData();
			modelBuilder.Entity<Genre>().SeedData();
			modelBuilder.Entity<Location>().SeedData();
			modelBuilder.Entity<Notification>().SeedData();
			modelBuilder.Entity<Performer>().SeedData();
			modelBuilder.Entity<PerformerGenre>().SeedData();
			modelBuilder.Entity<Purchase>().SeedData();
			modelBuilder.Entity<Review>().SeedData();
			modelBuilder.Entity<Status>().SeedData();
			modelBuilder.Entity<Ticket>().SeedData();
			modelBuilder.Entity<User>().SeedData();

			OnModelCreatingPartial(modelBuilder);
		}
		partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
	}
}
