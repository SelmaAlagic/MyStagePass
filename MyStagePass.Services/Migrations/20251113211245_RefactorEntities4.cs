using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class RefactorEntities4 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_TicketTypes_TicketTypeID",
                table: "Tickets");

            migrationBuilder.DropTable(
                name: "TicketTypes");

            migrationBuilder.DropIndex(
                name: "IX_Tickets_TicketTypeID",
                table: "Tickets");

            migrationBuilder.RenameColumn(
                name: "TicketTypeID",
                table: "Tickets",
                newName: "TicketType");

            migrationBuilder.RenameColumn(
                name: "TicketsAvailable",
                table: "Events",
                newName: "VipPrice");

            migrationBuilder.AlterColumn<int>(
                name: "Price",
                table: "Tickets",
                type: "int",
                nullable: false,
                oldClrType: typeof(float),
                oldType: "real");

            migrationBuilder.AddColumn<int>(
                name: "PremiumPrice",
                table: "Events",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "RegularPrice",
                table: "Events",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<int>(
                name: "TotalTickets",
                table: "Events",
                type: "int",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 1,
                columns: new[] { "Description", "PremiumPrice", "RegularPrice", "TicketsSold", "TotalTickets", "VipPrice" },
                values: new object[] { "Rock Concert 2025", 50, 30, 200, 15000, 40 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 2,
                columns: new[] { "Description", "PremiumPrice", "RegularPrice", "TicketsSold", "TotalTickets", "VipPrice" },
                values: new object[] { "Jazz Night 2525", 50, 25, 370, 15000, 30 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 3,
                columns: new[] { "PremiumPrice", "RegularPrice", "TicketsSold", "TotalTickets", "VipPrice" },
                values: new object[] { 50, 25, 700, 12000, 30 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 4,
                columns: new[] { "PremiumPrice", "RegularPrice", "TotalTickets", "VipPrice" },
                values: new object[] { 50, 25, 8000, 30 });

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 1,
                columns: new[] { "Price", "TicketType" },
                values: new object[] { 40, 2 });

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 2,
                columns: new[] { "EventID", "Price" },
                values: new object[] { 1, 40 });

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 3,
                column: "Price",
                value: 25);

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 4,
                columns: new[] { "EventID", "Price", "TicketType" },
                values: new object[] { 3, 25, 1 });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PremiumPrice",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "RegularPrice",
                table: "Events");

            migrationBuilder.DropColumn(
                name: "TotalTickets",
                table: "Events");

            migrationBuilder.RenameColumn(
                name: "TicketType",
                table: "Tickets",
                newName: "TicketTypeID");

            migrationBuilder.RenameColumn(
                name: "VipPrice",
                table: "Events",
                newName: "TicketsAvailable");

            migrationBuilder.AlterColumn<float>(
                name: "Price",
                table: "Tickets",
                type: "real",
                nullable: false,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.CreateTable(
                name: "TicketTypes",
                columns: table => new
                {
                    TicketTypeID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    TicketTypeName = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TicketTypes", x => x.TicketTypeID);
                });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 1,
                columns: new[] { "Description", "TicketsAvailable", "TicketsSold" },
                values: new object[] { null, 200, 50 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 2,
                columns: new[] { "Description", "TicketsAvailable", "TicketsSold" },
                values: new object[] { null, 100, 30 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 3,
                columns: new[] { "TicketsAvailable", "TicketsSold" },
                values: new object[] { 1000, 300 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 4,
                column: "TicketsAvailable",
                value: 150);

            migrationBuilder.InsertData(
                table: "TicketTypes",
                columns: new[] { "TicketTypeID", "TicketTypeName" },
                values: new object[,]
                {
                    { 1, "Regular" },
                    { 2, "VIP" },
                    { 3, "Premium" }
                });

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 1,
                columns: new[] { "Price", "TicketTypeID" },
                values: new object[] { 50f, 1 });

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 2,
                columns: new[] { "EventID", "Price" },
                values: new object[] { 2, 30f });

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 3,
                column: "Price",
                value: 60f);

            migrationBuilder.UpdateData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 4,
                columns: new[] { "EventID", "Price", "TicketTypeID" },
                values: new object[] { 1, 40f, 3 });

            migrationBuilder.CreateIndex(
                name: "IX_Tickets_TicketTypeID",
                table: "Tickets",
                column: "TicketTypeID");

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_TicketTypes_TicketTypeID",
                table: "Tickets",
                column: "TicketTypeID",
                principalTable: "TicketTypes",
                principalColumn: "TicketTypeID",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
