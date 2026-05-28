using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class FixedEventSeed2 : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 1,
                columns: new[] { "ApprovedByAdminID", "EventDate", "StatusChangedAt" },
                values: new object[] { 1, new DateTime(2026, 7, 10, 20, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 2, 1, 10, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 2,
                columns: new[] { "RatingAverage", "RatingCount", "TotalScore" },
                values: new object[] { 0f, 0, 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 5,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { 1, "Don't like the concept!", 0f, 0, new DateTime(2025, 3, 20, 10, 0, 0, 0, DateTimeKind.Unspecified), 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 6,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { 1, "Don't like the concept!", 0f, 0, new DateTime(2024, 5, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 7,
                columns: new[] { "CancellationReason", "StatusChangedAt", "StatusID" },
                values: new object[] { null, new DateTime(2024, 5, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), 2 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 9,
                columns: new[] { "ApprovedByAdminID", "StatusChangedAt" },
                values: new object[] { 1, new DateTime(2024, 6, 20, 10, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 10,
                columns: new[] { "RatingAverage", "RatingCount", "TotalScore" },
                values: new object[] { 0f, 0, 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 12,
                columns: new[] { "ApprovedByAdminID", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { 1, 0f, 0, new DateTime(2026, 3, 10, 10, 0, 0, 0, DateTimeKind.Unspecified), 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 13,
                columns: new[] { "ApprovedByAdminID", "StatusChangedAt" },
                values: new object[] { 1, new DateTime(2025, 11, 20, 10, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 14,
                columns: new[] { "ApprovedByAdminID", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { 1, 0f, 0, new DateTime(2025, 7, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 15,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { 1, "Don't like the concept!", 0f, 0, new DateTime(2024, 6, 10, 10, 0, 0, 0, DateTimeKind.Unspecified), 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 17,
                columns: new[] { "ApprovedByAdminID", "EventDate", "StatusChangedAt" },
                values: new object[] { 1, new DateTime(2026, 5, 31, 22, 0, 0, 0, DateTimeKind.Unspecified), new DateTime(2025, 12, 5, 10, 0, 0, 0, DateTimeKind.Unspecified) });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 19,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { 1, "Don't like the concept!", 0f, 0, new DateTime(2025, 3, 15, 10, 0, 0, 0, DateTimeKind.Unspecified), 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 20,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { 1, "Don't like the concept!", 0f, 0, new DateTime(2024, 4, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), 0 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 21,
                columns: new[] { "ApprovedByAdminID", "StatusChangedAt" },
                values: new object[] { 1, new DateTime(2025, 10, 20, 10, 0, 0, 0, DateTimeKind.Unspecified) });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 1,
                columns: new[] { "ApprovedByAdminID", "EventDate", "StatusChangedAt" },
                values: new object[] { null, new DateTime(2026, 5, 10, 20, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 2,
                columns: new[] { "RatingAverage", "RatingCount", "TotalScore" },
                values: new object[] { 4.63f, 89, 412 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 5,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { null, null, 4.7f, 234, null, 1100 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 6,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { null, null, 4.62f, 187, null, 865 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 7,
                columns: new[] { "CancellationReason", "StatusChangedAt", "StatusID" },
                values: new object[] { "Artist cancelled due to health reasons.", new DateTime(2025, 3, 15, 14, 0, 0, 0, DateTimeKind.Unspecified), 4 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 9,
                columns: new[] { "ApprovedByAdminID", "StatusChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 10,
                columns: new[] { "RatingAverage", "RatingCount", "TotalScore" },
                values: new object[] { 4.56f, 156, 712 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 12,
                columns: new[] { "ApprovedByAdminID", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { null, 4.64f, 278, null, 1290 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 13,
                columns: new[] { "ApprovedByAdminID", "StatusChangedAt" },
                values: new object[] { null, null });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 14,
                columns: new[] { "ApprovedByAdminID", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { null, 4.7f, 67, null, 315 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 15,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { null, null, 4.59f, 145, null, 665 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 17,
                columns: new[] { "ApprovedByAdminID", "EventDate", "StatusChangedAt" },
                values: new object[] { null, new DateTime(2026, 12, 31, 22, 0, 0, 0, DateTimeKind.Unspecified), null });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 19,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { null, null, 4.61f, 203, null, 935 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 20,
                columns: new[] { "ApprovedByAdminID", "CancellationReason", "RatingAverage", "RatingCount", "StatusChangedAt", "TotalScore" },
                values: new object[] { null, null, 4.57f, 267, null, 1220 });

            migrationBuilder.UpdateData(
                table: "Events",
                keyColumn: "EventID",
                keyValue: 21,
                columns: new[] { "ApprovedByAdminID", "StatusChangedAt" },
                values: new object[] { null, null });
        }
    }
}
