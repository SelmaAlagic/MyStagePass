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
	public class CustomerController : BaseCRUDController<Customer, CustomerSearchObject, CustomerInsertRequest, CustomerUpdateRequest>
	{
		public CustomerController(ILogger<BaseController<Customer, CustomerSearchObject>> logger, ICustomerService service) : base(logger, service)
		{
		}

		[AllowAnonymous]
		[HttpPost("register")]
		public override Task<Customer> Insert([FromBody] CustomerInsertRequest insert)
		{
			return base.Insert(insert);
		}
	}
}