using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class FixedEventSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 2,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { 1, "Location unavailable due to technical issues.", new DateTime(2024, 6, 1, 10, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 7,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { 1, "Artist cancelled due to health reasons.", new DateTime(2025, 3, 15, 14, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 8,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { 1, "Insufficient ticket sales, event not viable.", new DateTime(2025, 12, 10, 9, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 10,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { 1, "Venue permit revoked by city authorities.", new DateTime(2025, 9, 1, 11, 0, 0, 0, DateTimeKind.Unspecified) });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 2,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 7,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 8,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { null, null, null });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 10,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "StatusChangedAt" },
                values: new object[] { null, null, null });
        }
    }
}
