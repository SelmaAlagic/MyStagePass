using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateSeedData : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 5,
                column: "RatingAverage",
                value: 4.7f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 10,
                column: "RatingAverage",
                value: 4.56f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 12,
                column: "RatingAverage",
                value: 4.64f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 14,
                column: "RatingAverage",
                value: 4.7f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 17,
                column: "RatingAverage",
                value: 4.64f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 19,
                column: "RatingAverage",
                value: 4.61f);

            migrationBuilder.InsertData(
                table: "Purchases",
                columns: new[] { "PurchaseID", "CustomerID", "IsDeleted", "IsRefunded", "PaymentIntentId", "PurchaseDate" },
                values: new object[,]
                {
                    { 25, 1, false, null, null, new DateTime(2025, 4, 1, 10, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 26, 2, false, null, null, new DateTime(2025, 4, 2, 11, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Tickets",
                columns: new[] { "TicketID", "EventID", "IsDeleted", "Price", "PurchaseID", "TicketType" },
                values: new object[,]
                {
                    { 37, 15, false, 20, 25, 1 },
                    { 38, 15, false, 20, 26, 1 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 37);

            migrationBuilder.DeleteData(
                table: "Tickets",
                keyColumn: "TicketID",
                keyValue: 38);

            migrationBuilder.DeleteData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 25);

            migrationBuilder.DeleteData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 26);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 5,
                column: "RatingAverage",
                value: 0f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 10,
                column: "RatingAverage",
                value: 0f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 12,
                column: "RatingAverage",
                value: 0f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 14,
                column: "RatingAverage",
                value: 0f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 17,
                column: "RatingAverage",
                value: 0f);

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 19,
                column: "RatingAverage",
                value: 0f);
        }
    }
}
