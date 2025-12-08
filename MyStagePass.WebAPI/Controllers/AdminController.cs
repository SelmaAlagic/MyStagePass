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
	public class AdminController : BaseCRUDController<Admin, AdminSearchObject, AdminInsertRequest, AdminUpdateRequest>
	{
		public AdminController(ILogger<BaseController<Admin, AdminSearchObject>> logger, IAdminService service) : base(logger, service)
		{
		}

		public override Task<Admin> Insert([FromBody] AdminInsertRequest insert)
		{
			return base.Insert(insert);
		}
	}
}