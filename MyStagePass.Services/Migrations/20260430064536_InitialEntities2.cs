using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialEntities2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserID",
                keyValue: 13,
                column: "Email",
                value: "tesa@zahirovic.com");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserID",
                keyValue: 15,
                column: "Username",
                value: "lejla.besic");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserID",
                keyValue: 16,
                column: "Password",
                value: "7wwiWDTpeJt/BWscFVDkz5mkdDvZnZWPMJ4o/fnWXLE=");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserID",
                keyValue: 13,
                column: "Email",
                value: "tesa@example.com");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserID",
                keyValue: 15,
                column: "Username",
                value: "lejla");

            migrationBuilder.UpdateData(
                table: "Users",
                keyColumn: "UserID",
                keyValue: 16,
                column: "Password",
                value: "7wwiWDTpeJt/BWscFVDkz5mkdDvZnZWPMJ4o/fnWXLE=\"");
        }
    }
}
