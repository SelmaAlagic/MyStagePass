using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles = "Admin")]
	public class CustomerController : BaseCRUDController<Customer, CustomerSearchObject, CustomerInsertRequest, CustomerUpdateRequest>
	{
		private readonly ICustomerService _customerService;
		public CustomerController(ILogger<BaseController<Customer, CustomerSearchObject>> logger, ICustomerService service) : base(logger, service)
		{
			_customerService = service;
		}

		[AllowAnonymous]
		[HttpPost("register")]
		public override Task<Customer> Insert([FromBody] CustomerInsertRequest insert)
		{
			return base.Insert(insert);
		}

		[Authorize(Roles = "Admin,Customer")]
		[HttpPut("{id}")]
		public override async Task<Customer> Update(int id, [FromBody] CustomerUpdateRequest update)
		{
			var isAdmin = User.IsInRole("Admin");
			if (!isAdmin)
			{
				var customerIdClaim = User.FindFirst("CustomerID")?.Value;
				if (string.IsNullOrEmpty(customerIdClaim))
					throw new UnauthorizedAccessException("Invalid token");
				int tokenCustomerId = int.Parse(customerIdClaim);
				if (tokenCustomerId != id)
					throw new UnauthorizedAccessException("You can only update your own profile");
			}
			return await _customerService.Update(id, update);
		}
	}
}