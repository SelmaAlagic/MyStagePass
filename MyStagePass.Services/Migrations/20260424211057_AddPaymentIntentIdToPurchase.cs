using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class AddPaymentIntentIdToPurchase : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PaymentIntentId",
                table: "Purchases",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 1,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 2,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 3,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 4,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 5,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 6,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 7,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 8,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 9,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 10,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 11,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 12,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 13,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 14,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 15,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 16,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 17,
                column: "PaymentIntentId",
                value: null);

            migrationBuilder.UpdateData(
                table: "Purchases",
                keyColumn: "PurchaseID",
                keyValue: 18,
                column: "PaymentIntentId",
                value: null);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "PaymentIntentId",
                table: "Purchases");
        }
    }
}
