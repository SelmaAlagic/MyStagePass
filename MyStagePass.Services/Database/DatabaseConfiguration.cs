using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;

namespace MyStagePass.Services.Database
{
	public static class DatabaseConfiguration
	{
		public static void AddDatabaseServices (this IServiceCollection services, string connectionString)
		{
			services.AddDbContext<MyStagePassDbContext>(options => options.UseSqlServer(connectionString));
		}
	}
}