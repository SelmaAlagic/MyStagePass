using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdatedDbCobtext : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Events_Locations_LocationID",
                table: "Events");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Locations_LocationID",
                table: "Events",
                column: "LocationID",
                principalTable: "Locations",
                principalColumn: "LocationID",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Events_Locations_LocationID",
                table: "Events");

            migrationBuilder.AddForeignKey(
                name: "FK_Events_Locations_LocationID",
                table: "Events",
                column: "LocationID",
                principalTable: "Locations",
                principalColumn: "LocationID",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
