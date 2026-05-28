using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddedStatusCRUD : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Statuses",
                columns: new[] { "StatusID", "StatusName" },
                values: new object[] { 5, "Sold out" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Statuses",
                keyColumn: "StatusID",
                keyValue: 5);
        }
    }
}
