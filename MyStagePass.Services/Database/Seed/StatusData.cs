using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class StatusData
	{
		public static void SeedData(this EntityTypeBuilder<Status> entity)
		{
			entity.HasData(
				new Status { StatusID = 1, StatusName = "Pending" },
				new Status { StatusID = 2, StatusName = "Approved" },
				new Status { StatusID = 3, StatusName = "Rejected" }
			);
		}
	}
}
