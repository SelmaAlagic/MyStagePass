using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class UpdateNotificationSeed : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 41);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 42);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 43);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 44);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 45);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 46);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 47);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 48);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 49);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 50);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 51);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 52);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 53);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 54);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 55);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 56);

            migrationBuilder.DeleteData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 57);

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 1,
                columns: new[] { "Message", "Title" },
                values: new object[] { "Performer Dzejla Ramovic has registered and is waiting for verification!", "New Performer Registration" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 2,
                columns: new[] { "Message", "Title" },
                values: new object[] { "Performer Jelena Rozga has registered and is waiting for verification!", "New Performer Registration" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 3,
                columns: new[] { "Message", "Title", "isRead" },
                values: new object[] { "Performer Marija Serifovic has registered and is waiting for verification!", "New Performer Registration", true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 4,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2025, 3, 10, 16, 20, 0, 0, DateTimeKind.Unspecified), "Ilma Karahmet submitted a new event for approval!", "New Event Submitted" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 5,
                columns: new[] { "CreatedAt", "Message" },
                values: new object[] { new DateTime(2025, 3, 5, 13, 10, 0, 0, DateTimeKind.Unspecified), "Toni Cetinski submitted a new event for approval!" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 6,
                columns: new[] { "CreatedAt", "Message", "Title", "isRead" },
                values: new object[] { new DateTime(2025, 1, 30, 10, 15, 0, 0, DateTimeKind.Unspecified), "Zeljko Samardzic submitted a new event for approval!", "New Event Submitted", false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 7,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 1, 10, 30, 0, 0, DateTimeKind.Unspecified), "Prljavo Kazaliste submitted a new event for approval!", "New Event Submitted", 1, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 8,
                columns: new[] { "CreatedAt", "Message", "Title", "isRead" },
                values: new object[] { new DateTime(2025, 3, 16, 10, 0, 0, 0, DateTimeKind.Unspecified), "Your performer account has been approved! You can now submit events.", "Account Status Update", true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 9,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2025, 1, 18, 9, 0, 0, 0, DateTimeKind.Unspecified), "Your performer account has been approved! You can now submit events.", "Account Status Update" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 10,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 3, 20, 11, 0, 0, 0, DateTimeKind.Unspecified), "Your performer account has been rejected. Please contact support for more information.", "Account Status Update", 4 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 11,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 3, 1, 8, 0, 0, 0, DateTimeKind.Unspecified), "Your performer account has been approved! You can now submit events.", "Account Status Update", 5, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 12,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 3, 1, 8, 30, 0, 0, DateTimeKind.Unspecified), "Your performer account has been approved! You can now submit events.", "Account Status Update", 6 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 13,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 3, 1, 9, 0, 0, 0, DateTimeKind.Unspecified), "Your performer account has been approved! You can now submit events.", "Account Status Update", 7, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 14,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 3, 1, 9, 30, 0, 0, DateTimeKind.Unspecified), "Your performer account has been approved! You can now submit events.", "Account Status Update", 8 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 15,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 3, 26, 10, 0, 0, 0, DateTimeKind.Unspecified), "Your performer account has been rejected. Please contact support for more information.", "Account Status Update", 9, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 16,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 3, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "Your performer account has been approved! You can now submit events.", "Account Status Update", 10 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 17,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 1, 20, 14, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Ilma Karahmet - Debut Concert' has been approved!", "Event Status Update", 3, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 18,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 12, 11, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Ilma Karahmet - Acoustic Evening' has been approved!", "Event Status Update", 3, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 19,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2024, 3, 10, 13, 0, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Split Summer Nights' has been approved!", "Event Status Update" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 20,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2024, 9, 5, 16, 15, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Sarajevo Winter' has been approved!", "Event Status Update" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 21,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 12, 12, 9, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Banja Luka Special' has been rejected.", "Event Status Update", 5, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 22,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2024, 5, 20, 12, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Zeljko Samardzic - Belgrade Classics' has been approved!", "Event Status Update" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 23,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2025, 2, 1, 10, 15, 0, 0, DateTimeKind.Unspecified), "Your event 'Zeljko Samardzic - Zenica Live' has been rejected.", "Event Status Update" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 24,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 11, 15, 13, 20, 0, 0, DateTimeKind.Unspecified), "Your event 'Adi Sose - Jazz Night' has been approved!", "Event Status Update", 7 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 25,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 6, 20, 9, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Adi Sose - Akustik Session' has been approved!", "Event Status Update", 7, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 26,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 4, 10, 14, 0, 0, 0, DateTimeKind.Unspecified), "Your event 'Mirza Selimovic - Folk Spectacle' has been approved!", "Event Status Update", 8 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 27,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 22, 15, 15, 0, 0, DateTimeKind.Unspecified), "Your event 'Mirza Selimovic - Bihac Summer' has been rejected.", "Event Status Update", 8, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 28,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 6, 15, 13, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Prljavo Kazaliste - Sarajevo Rock Night' has been approved!", "Event Status Update", 10 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 29,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 3, 10, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Prljavo Kazaliste - 40 Years Anniversary' has been rejected.", "Event Status Update", 10, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 30,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 12, 5, 11, 20, 0, 0, DateTimeKind.Unspecified), "Toni Cetinski has announced a new event in Banja Luka!", "New Event From Favorite Performer", 11 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 31,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 1, 30, 13, 45, 0, 0, DateTimeKind.Unspecified), "Prljavo Kazaliste has announced a new anniversary concert!", "New Event From Favorite Performer", 11, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 32,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 1, 25, 16, 30, 0, 0, DateTimeKind.Unspecified), "Zeljko Samardzic has announced a new event!", "New Event From Favorite Performer", 12, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 33,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 5, 11, 45, 0, 0, DateTimeKind.Unspecified), "Ilma Karahmet has announced a new acoustic evening!", "New Event From Favorite Performer", 12, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 34,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 11, 10, 9, 30, 0, 0, DateTimeKind.Unspecified), "Adi Sose has announced a new Jazz Night!", "New Event From Favorite Performer", 13 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 35,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 2, 18, 10, 20, 0, 0, DateTimeKind.Unspecified), "Mirza Selimovic has announced a new event in Bihac!", "New Event From Favorite Performer", 13 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 36,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 1, 15, 14, 45, 0, 0, DateTimeKind.Unspecified), "Ilma Karahmet has announced a new debut concert!", "New Event From Favorite Performer", 14, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 37,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 1, 25, 16, 15, 0, 0, DateTimeKind.Unspecified), "Zeljko Samardzic has announced a new event in Zenica!", "New Event From Favorite Performer", 15 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 38,
                columns: new[] { "Message", "Title", "UserID" },
                values: new object[] { "Prljavo Kazaliste has announced a new Split Open Air concert!", "New Event From Favorite Performer", 15 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 39,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 1, 30, 13, 20, 0, 0, DateTimeKind.Unspecified), "Prljavo Kazaliste has announced a 40 Years Anniversary concert!", "New Event From Favorite Performer", 16, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 40,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "Toni Cetinski has announced a new event in Zagreb Arena!", "New Event From Favorite Performer", 16, true });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 1,
                columns: new[] { "Message", "Title" },
                values: new object[] { "New performer request (Dzejla Ramovic) waiting for verification!", "New Performer Request" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 2,
                columns: new[] { "Message", "Title" },
                values: new object[] { "New performer request (Jelena Rozga) waiting for verification!", "New Performer Request" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 3,
                columns: new[] { "Message", "Title", "isRead" },
                values: new object[] { "New performer request (Marija Serifovic) waiting for verification!", "New Performer Request", false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 4,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2025, 3, 22, 10, 0, 0, 0, DateTimeKind.Unspecified), "3 events pending approval for approved performers!", "Events Pending Approval" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 5,
                columns: new[] { "CreatedAt", "Message" },
                values: new object[] { new DateTime(2025, 3, 10, 16, 20, 0, 0, DateTimeKind.Unspecified), "Ilma Karahmet submitted a new event for approval" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 6,
                columns: new[] { "CreatedAt", "Message", "Title", "isRead" },
                values: new object[] { new DateTime(2025, 3, 5, 13, 10, 0, 0, DateTimeKind.Unspecified), "Toni Cetinski submitted 2 new events for approval", "New Events Submitted", true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 7,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 3, 15, 9, 35, 0, 0, DateTimeKind.Unspecified), "Your performer application has been received and is pending review", "Application Received", 2, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 8,
                columns: new[] { "CreatedAt", "Message", "Title", "isRead" },
                values: new object[] { new DateTime(2025, 3, 20, 10, 0, 0, 0, DateTimeKind.Unspecified), "Your application is still under review by admin", "Application Under Review", false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 9,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2025, 1, 20, 14, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Ilma Karahmet - Debut Concert' has been approved!", "Event Approved" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 10,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 2, 10, 11, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Ilma Karahmet - Acoustic Evening' is pending approval", "Event Pending Approval", 3 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 11,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 15, 9, 0, 0, 0, DateTimeKind.Unspecified), "5 customers have added your events to favorites!", "New Favorites", 3, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 12,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 3, 18, 11, 20, 0, 0, DateTimeKind.Unspecified), "Your performer application has been received and is pending review", "Application Received", 4 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 13,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 3, 25, 10, 30, 0, 0, DateTimeKind.Unspecified), "Your application is still under review by admin", "Application Under Review", 4, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 14,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 3, 10, 13, 0, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Split Summer Nights' has been approved!", "Event Approved", 5 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 15,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 9, 5, 16, 15, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Sarajevo Winter' has been approved!", "Event Approved", 5, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 16,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 4, 15, 10, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Mostar Bridge Concert' has been approved!", "Event Approved", 5 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 17,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 12, 10, 9, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Banja Luka Special' is pending approval", "Event Pending Approval", 5, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 18,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 5, 14, 20, 0, 0, DateTimeKind.Unspecified), "Your event 'Toni Cetinski - Zagreb Arena' is pending approval", "Event Pending Approval", 5, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 19,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2025, 1, 20, 11, 0, 0, 0, DateTimeKind.Unspecified), "8 customers have added your events to favorites!", "New Favorites" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 20,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2024, 9, 1, 9, 0, 0, 0, DateTimeKind.Unspecified), "Congratulations! Your event 'Split Summer Nights' reached 234 reviews with 4.70 average rating!", "Rating Milestone" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 21,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 5, 20, 12, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Zeljko Samardzic - Belgrade Classics' has been approved!", "Event Approved", 6, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 22,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2024, 8, 25, 15, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Zeljko Samardzic - Sarajevo Ballads' has been approved!", "Event Approved" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 23,
                columns: new[] { "CreatedAt", "Message", "Title" },
                values: new object[] { new DateTime(2025, 1, 30, 10, 15, 0, 0, DateTimeKind.Unspecified), "Your event 'Zeljko Samardzic - Zenica Live' is pending approval", "Event Pending Approval" });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 24,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 3, 5, 11, 0, 0, 0, DateTimeKind.Unspecified), "Your event 'Zeljko Samardzic - Novi Sad Festival' has been approved!", "Event Approved", 6 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 25,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 1, 14, 30, 0, 0, DateTimeKind.Unspecified), "6 customers have added your events to favorites!", "New Favorites", 6, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 26,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 11, 15, 13, 20, 0, 0, DateTimeKind.Unspecified), "Your event 'Adi Sose - Jazz Night' has been approved!", "Event Approved", 7 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 27,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 6, 20, 9, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Adi Sose - Akustik Session' has been approved!", "Event Approved", 7, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 28,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 1, 10, 16, 0, 0, 0, DateTimeKind.Unspecified), "3 customers have added your events to favorites!", "New Favorites", 7 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 29,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 12, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), "Your Akustik Session event got 4.70 average rating from 67 reviews!", "Rating Milestone", 7, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 30,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 4, 10, 14, 0, 0, 0, DateTimeKind.Unspecified), "Your event 'Mirza Selimovic - Folk Spectacle' has been approved!", "Event Approved", 8 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 31,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 7, 5, 11, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Mirza Selimovic - New Year's Eve' has been approved!", "Event Approved", 8, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 32,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 20, 15, 15, 0, 0, DateTimeKind.Unspecified), "Your event 'Mirza Selimovic - Bihac Summer' is pending approval", "Event Pending Approval", 8, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 33,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 1, 5, 12, 45, 0, 0, DateTimeKind.Unspecified), "4 customers have added your events to favorites!", "New Favorites", 8, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 34,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 3, 20, 14, 50, 0, 0, DateTimeKind.Unspecified), "Your performer application has been received and is pending review", "Application Received", 9 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 35,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2025, 3, 25, 9, 15, 0, 0, DateTimeKind.Unspecified), "Your application is still under review by admin", "Application Under Review", 9 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 36,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 1, 10, 30, 0, 0, DateTimeKind.Unspecified), "Your event 'Prljavo Kazaliste - 40 Years Anniversary' is pending approval", "Event Pending Approval", 10, false });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 37,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID" },
                values: new object[] { new DateTime(2024, 6, 15, 13, 45, 0, 0, DateTimeKind.Unspecified), "Your event 'Prljavo Kazaliste - Sarajevo Rock Night' has been approved!", "Event Approved", 10 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 38,
                columns: new[] { "Message", "Title", "UserID" },
                values: new object[] { "Your event 'Prljavo Kazaliste - Split Open Air' has been approved!", "Event Approved", 10 });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 39,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2024, 10, 10, 11, 0, 0, 0, DateTimeKind.Unspecified), "Your event 'Prljavo Kazaliste - Mostar Rock Fest' has been approved!", "Event Approved", 10, true });

            migrationBuilder.UpdateData(
                table: "Notifications",
                keyColumn: "NotificationID",
                keyValue: 40,
                columns: new[] { "CreatedAt", "Message", "Title", "UserID", "isRead" },
                values: new object[] { new DateTime(2025, 2, 15, 14, 0, 0, 0, DateTimeKind.Unspecified), "5 customers have added your events to favorites!", "New Favorites", 10, false });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "NotificationID", "CreatedAt", "IsDeleted", "Message", "Title", "UserID", "isRead" },
                values: new object[,]
                {
                    { 41, new DateTime(2024, 12, 5, 11, 20, 0, 0, DateTimeKind.Unspecified), false, "Toni Cetinski added a new event in Banja Luka!", "New Event Available", 11, true },
                    { 42, new DateTime(2025, 1, 30, 13, 45, 0, 0, DateTimeKind.Unspecified), false, "Prljavo Kazaliste added a new anniversary concert!", "New Event Available", 11, false },
                    { 43, new DateTime(2025, 1, 25, 16, 30, 0, 0, DateTimeKind.Unspecified), false, "Zeljko Samardzic event in Zenica is now available!", "New Event Available", 11, true },
                    { 44, new DateTime(2025, 2, 1, 10, 15, 0, 0, DateTimeKind.Unspecified), false, "One of your favorite performers (Toni Cetinski) has a new event!", "New Event From Favorite Performer", 11, false },
                    { 45, new DateTime(2024, 7, 10, 9, 0, 0, 0, DateTimeKind.Unspecified), false, "Zeljko Samardzic at EXIT Festival was a huge success!", "Event Update", 12, true },
                    { 46, new DateTime(2024, 12, 1, 14, 30, 0, 0, DateTimeKind.Unspecified), false, "Mirza Selimovic New Year's Eve event is coming up!", "Upcoming Event", 12, true },
                    { 47, new DateTime(2025, 2, 5, 11, 45, 0, 0, DateTimeKind.Unspecified), false, "Ilma Karahmet acoustic evening tickets now available!", "Tickets Available", 12, false },
                    { 48, new DateTime(2024, 11, 10, 9, 30, 0, 0, DateTimeKind.Unspecified), false, "Adi Sose Jazz Night is coming soon!", "Upcoming Event", 13, true },
                    { 49, new DateTime(2024, 7, 25, 15, 0, 0, 0, DateTimeKind.Unspecified), false, "Ilma Karahmet Tuzla Summer Fest reviews are in - 4.63 rating!", "Event Reviews In", 13, true },
                    { 50, new DateTime(2025, 2, 18, 10, 20, 0, 0, DateTimeKind.Unspecified), false, "Mirza Selimovic Bihac Summer event is now pending approval", "Event Pending Approval", 13, false },
                    { 51, new DateTime(2025, 1, 15, 14, 45, 0, 0, DateTimeKind.Unspecified), false, "Ilma Karahmet debut concert tickets selling fast!", "Tickets Selling Fast", 14, true },
                    { 52, new DateTime(2025, 3, 9, 11, 0, 0, 0, DateTimeKind.Unspecified), false, "Zeljko Samardzic Sarajevo Ballads event has ended - check reviews!", "Event Ended", 14, false },
                    { 53, new DateTime(2025, 1, 25, 16, 15, 0, 0, DateTimeKind.Unspecified), false, "Zeljko Samardzic Zenica Live tickets now available!", "Tickets Available", 15, true },
                    { 54, new DateTime(2024, 8, 28, 10, 30, 0, 0, DateTimeKind.Unspecified), false, "Prljavo Kazaliste Split Open Air was amazing - 4.57 rating!", "Event Rating", 15, true },
                    { 55, new DateTime(2025, 2, 15, 13, 45, 0, 0, DateTimeKind.Unspecified), false, "Toni Cetinski Sarajevo Winter event photos available!", "Event Update", 15, false },
                    { 56, new DateTime(2025, 1, 30, 13, 20, 0, 0, DateTimeKind.Unspecified), false, "Prljavo Kazaliste 40 Years Anniversary concert announced!", "New Event Available", 16, false },
                    { 57, new DateTime(2025, 2, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Toni Cetinski Zagreb Arena event is now pending approval", "Event Pending Approval", 16, true }
                });
        }
    }
}
