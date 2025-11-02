using Microsoft.AspNetCore.Mvc;
using MyStagePass.Services.Database;
using MyStagePass.Services.Services;

namespace MyStagePass.WebAPI.Controllers
{
	[Route("api/[controller]")]
	[ApiController]
	public class CustomerController : ControllerBase
	{
		protected ICustomerService _customerService;

		public CustomerController(ICustomerService service)
		{
			_customerService = service;
		}

		[HttpGet]
		public IEnumerable<Customer> Get()
		{
			return _customerService.Get();
		}

		[HttpGet("{id}")]
		public ActionResult<Customer> Get(int id)
		{
			var customer = _customerService.Get(id);
			if (customer == null)
				return NotFound();

			return customer;
		}

		[HttpPost]
		public ActionResult<Customer> Post([FromBody] Customer customer)
		{
			var createdCustomer = _customerService.Insert(customer);
			return CreatedAtAction(nameof(Get), new { id = createdCustomer.CustomerID }, createdCustomer);
		}

		[HttpDelete("{id}")]
		public ActionResult<Customer> Delete(int id)
		{
			var deletedCustomer = _customerService.Delete(id);
			if (deletedCustomer == null)
				return NotFound();

			return Ok(deletedCustomer);
		}
	}
}
