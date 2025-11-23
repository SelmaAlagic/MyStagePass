using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class addedDbSetForCFEvents : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CustomerFavoriteEvent_Customers_CustomerID",
                table: "CustomerFavoriteEvent");

            migrationBuilder.DropForeignKey(
                name: "FK_CustomerFavoriteEvent_Events_EventID",
                table: "CustomerFavoriteEvent");

            migrationBuilder.DropPrimaryKey(
                name: "PK_CustomerFavoriteEvent",
                table: "CustomerFavoriteEvent");

            migrationBuilder.RenameTable(
                name: "CustomerFavoriteEvent",
                newName: "CustomerFavoriteEvents");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerFavoriteEvent_EventID_CustomerID",
                table: "CustomerFavoriteEvents",
                newName: "IX_CustomerFavoriteEvents_EventID_CustomerID");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerFavoriteEvent_CustomerID",
                table: "CustomerFavoriteEvents",
                newName: "IX_CustomerFavoriteEvents_CustomerID");

            migrationBuilder.AddPrimaryKey(
                name: "PK_CustomerFavoriteEvents",
                table: "CustomerFavoriteEvents",
                column: "CustomerFavoriteEventID");

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerFavoriteEvents_Customers_CustomerID",
                table: "CustomerFavoriteEvents",
                column: "CustomerID",
                principalTable: "Customers",
                principalColumn: "CustomerID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerFavoriteEvents_Events_EventID",
                table: "CustomerFavoriteEvents",
                column: "EventID",
                principalTable: "Events",
                principalColumn: "EventID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_CustomerFavoriteEvents_Customers_CustomerID",
                table: "CustomerFavoriteEvents");

            migrationBuilder.DropForeignKey(
                name: "FK_CustomerFavoriteEvents_Events_EventID",
                table: "CustomerFavoriteEvents");

            migrationBuilder.DropPrimaryKey(
                name: "PK_CustomerFavoriteEvents",
                table: "CustomerFavoriteEvents");

            migrationBuilder.RenameTable(
                name: "CustomerFavoriteEvents",
                newName: "CustomerFavoriteEvent");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerFavoriteEvents_EventID_CustomerID",
                table: "CustomerFavoriteEvent",
                newName: "IX_CustomerFavoriteEvent_EventID_CustomerID");

            migrationBuilder.RenameIndex(
                name: "IX_CustomerFavoriteEvents_CustomerID",
                table: "CustomerFavoriteEvent",
                newName: "IX_CustomerFavoriteEvent_CustomerID");

            migrationBuilder.AddPrimaryKey(
                name: "PK_CustomerFavoriteEvent",
                table: "CustomerFavoriteEvent",
                column: "CustomerFavoriteEventID");

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerFavoriteEvent_Customers_CustomerID",
                table: "CustomerFavoriteEvent",
                column: "CustomerID",
                principalTable: "Customers",
                principalColumn: "CustomerID",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_CustomerFavoriteEvent_Events_EventID",
                table: "CustomerFavoriteEvent",
                column: "EventID",
                principalTable: "Events",
                principalColumn: "EventID");
        }
    }
}
