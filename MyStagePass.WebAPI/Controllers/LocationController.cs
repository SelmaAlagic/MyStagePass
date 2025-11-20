using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Models;
using MyStagePass.Model.Requests;
using MyStagePass.Model.SearchObjects;
using MyStagePass.Services.Interfaces;

namespace MyStagePass.WebAPI.Controllers
{
	public class LocationController : BaseCRUDController<Location, LocationSearchObject, LocationInsertRequest, LocationUpdateRequest>
	{
		public LocationController(ILogger<BaseController<Location, LocationSearchObject>> logger, ILocationService service) : base(logger, service)
		{
		}
	}
}
