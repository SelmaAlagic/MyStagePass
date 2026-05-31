using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdatedPerformerGenreSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.InsertData(
                table: "PerformerGenre",
                columns: new[] { "PerformerGenreID", "GenreID", "PerformerID" },
                values: new object[,]
                {
                    { 18, 8, 10 },
                    { 19, 9, 10 }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "PerformerGenre",
                keyColumn: "PerformerGenreID",
                keyValue: 18);

            migrationBuilder.DeleteData(
                table: "PerformerGenre",
                keyColumn: "PerformerGenreID",
                keyValue: 19);
        }
    }
}
