using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateNotificationSeed2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 16);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "NotificationID", "CreatedAt", "IsDeleted", "Message", "Title", "UserID", "isRead" },
                values: new object[,]
                {
                    { 8, new DateTime(2025, 3, 16, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been approved! You can now submit events.", "Account Status Update", 2, true },
                    { 9, new DateTime(2025, 1, 18, 9, 0, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been approved! You can now submit events.", "Account Status Update", 3, true },
                    { 10, new DateTime(2025, 3, 20, 11, 0, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been rejected. Please contact support for more information.", "Account Status Update", 4, false },
                    { 11, new DateTime(2024, 3, 1, 8, 0, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been approved! You can now submit events.", "Account Status Update", 5, true },
                    { 12, new DateTime(2024, 3, 1, 8, 30, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been approved! You can now submit events.", "Account Status Update", 6, true },
                    { 13, new DateTime(2024, 3, 1, 9, 0, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been approved! You can now submit events.", "Account Status Update", 7, true },
                    { 14, new DateTime(2024, 3, 1, 9, 30, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been approved! You can now submit events.", "Account Status Update", 8, true },
                    { 15, new DateTime(2025, 3, 26, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been rejected. Please contact support for more information.", "Account Status Update", 9, false },
                    { 16, new DateTime(2024, 3, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Your performer account has been approved! You can now submit events.", "Account Status Update", 10, true }
                });
        }
    }
}
