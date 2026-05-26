using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	[Authorize(Roles = Roles.Customer)]
	public class CustomerController : BaseCRUDController<Customer, CustomerSearchObject, CustomerInsertRequest, CustomerUpdateRequest>
	{
		private readonly ICustomerService _customerService;
		private readonly ICurrentUserService _currentUserService;
		public CustomerController(ILogger<BaseController<Customer, CustomerSearchObject>> logger, ICustomerService service, ICurrentUserService currentUserService) : base(logger, service)
		{
			_customerService = service;
			_currentUserService = currentUserService;
		}

		[AllowAnonymous]
		[HttpPost("register")]
		public override Task<Customer> Insert([FromBody] CustomerInsertRequest insert)
		{
			return base.Insert(insert);
		}

		[Authorize(Roles = Roles.Admin + "," + Roles.Customer)]
		[HttpPut("{id}")]
		public override async Task<Customer> Update(int id, [FromBody] CustomerUpdateRequest update)
		{
			var isAdmin = User.IsInRole(Roles.Admin);
			if (!isAdmin && _currentUserService.GetCustomerId() != id)
				throw new UnauthorizedAccessException("You can only update your own profile.");

			return await _customerService.Update(id, update);
		}
	}
}