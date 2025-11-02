using Microsoft.EntityFrameworkCore;
using MyStagePass.Services.Database;

namespace MyStagePass.Services.Services
{
	public class CustomerService : ICustomerService
	{
		private readonly MyStagePassDbContext _context;

		public CustomerService(MyStagePassDbContext context)
		{
			_context = context;
		}

		// Dobavljanje svih customer-a
		public List<Customer> Get()
		{
			return _context.Customers.Include(x => x.Reviews).Include(x => x.FavoriteEvents).Include(x => x.Purchases).ToList();
		}

		// Dobavljanje po ID-u
		public Customer Get(int id)
		{
			return _context.Customers.Include(x => x.Reviews).Include(x => x.FavoriteEvents).Include(x => x.Purchases).FirstOrDefault(x => x.CustomerID == id);
		}

		// Unos novog customer-a
		public Customer Insert(Customer customer)
		{
			_context.Customers.Add(customer);
			_context.SaveChanges();
			return customer;
		}

		// Brisanje i vraćanje obrisanog objekta
		public Customer Delete(int id)
		{
			var customer = _context.Customers.FirstOrDefault(x => x.CustomerID == id);
			if (customer == null)
				return null;

			_context.Customers.Remove(customer);
			_context.SaveChanges();
			return customer;
		}
	}
}
