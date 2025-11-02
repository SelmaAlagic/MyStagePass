using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace MyStagePass.Services.Database.Seed
{
	public static class TicketTypeData
	{
		public static void SeedData(this EntityTypeBuilder<TicketType> entity)
		{
			entity.HasData(
				new TicketType { TicketTypeID = 1, TicketTypeName = "Regular" },
				new TicketType { TicketTypeID = 2, TicketTypeName = "VIP" },
				new TicketType { TicketTypeID = 3, TicketTypeName = "Premium" }
			);
		}
	}
}
