using MyStagePass.Services.Database;

namespace MyStagePass.Services.Services
{
	public interface ICustomerService
	{
		List<Customer> Get();
		Customer Get(int id);
		Customer Insert(Customer customer);
		Customer Delete(int id);
	}
}
