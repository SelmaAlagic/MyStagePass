using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class AdminData
	{
		public static void SeedData(this EntityTypeBuilder<Admin> entity)
		{
			entity.HasData(new Admin() { AdminID = 1, UserID = 1 });
		}
	}
}
