using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using MyStagePass.Model.Helpers;
using System.Net;

namespace MyStagePass.WebAPI.Filters
{
	public class ErrorFilter : ExceptionFilterAttribute
	{
		private readonly ILogger<ErrorFilter> _logger;

		public ErrorFilter(ILogger<ErrorFilter> logger)
		{
			_logger = logger;
		}

		public override void OnException(ExceptionContext context)
		{
			if (context.Exception is UserException)
			{
				context.ModelState.AddModelError("error", context.Exception.Message);
				context.HttpContext.Response.StatusCode = (int)HttpStatusCode.BadRequest;
			}
			else
			{
				_logger.LogError(context.Exception, "Unhandled exception");
				context.ModelState.AddModelError("ERROR", "Server side error");
				context.HttpContext.Response.StatusCode = (int)HttpStatusCode.InternalServerError;
			}
			var list = context.ModelState.Where(x => x.Value.Errors.Count() > 0)
					.ToDictionary(x => x.Key, y => y.Value.Errors.Select(z => z.ErrorMessage));

			context.Result = new JsonResult(new { errors = list });
		}
	}
}
