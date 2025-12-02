using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class InitialEntities : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Countries",
                columns: table => new
                {
                    CountryID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Countries", x => x.CountryID);
                });

            migrationBuilder.CreateTable(
                name: "Genres",
                columns: table => new
                {
                    GenreID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Genres", x => x.GenreID);
                });

            migrationBuilder.CreateTable(
                name: "Statuses",
                columns: table => new
                {
                    StatusID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StatusName = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Statuses", x => x.StatusID);
                });

            migrationBuilder.CreateTable(
                name: "Users",
                columns: table => new
                {
                    UserID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    FirstName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LastName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Username = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Email = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Password = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Salt = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    PhoneNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Image = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Users", x => x.UserID);
                });

            migrationBuilder.CreateTable(
                name: "Cities",
                columns: table => new
                {
                    CityID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CountryID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cities", x => x.CityID);
                    table.ForeignKey(
                        name: "FK_Cities_Countries_CountryID",
                        column: x => x.CountryID,
                        principalTable: "Countries",
                        principalColumn: "CountryID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Admins",
                columns: table => new
                {
                    AdminID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Admins", x => x.AdminID);
                    table.ForeignKey(
                        name: "FK_Admins_Users_UserID",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Customers",
                columns: table => new
                {
                    CustomerID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Customers", x => x.CustomerID);
                    table.ForeignKey(
                        name: "FK_Customers_Users_UserID",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Notifications",
                columns: table => new
                {
                    NotificationID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    Message = table.Column<string>(type: "nvarchar(max)", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    isRead = table.Column<bool>(type: "bit", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Notifications", x => x.NotificationID);
                    table.ForeignKey(
                        name: "FK_Notifications_Users_UserID",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Performers",
                columns: table => new
                {
                    PerformerID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ArtistName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Bio = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    UserID = table.Column<int>(type: "int", nullable: false),
                    IsApproved = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Performers", x => x.PerformerID);
                    table.ForeignKey(
                        name: "FK_Performers_Users_UserID",
                        column: x => x.UserID,
                        principalTable: "Users",
                        principalColumn: "UserID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Locations",
                columns: table => new
                {
                    LocationID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    LocationName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Capacity = table.Column<int>(type: "int", nullable: false),
                    Address = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    CityID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Locations", x => x.LocationID);
                    table.ForeignKey(
                        name: "FK_Locations_Cities_CityID",
                        column: x => x.CityID,
                        principalTable: "Cities",
                        principalColumn: "CityID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Purchases",
                columns: table => new
                {
                    PurchaseID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PurchaseDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CustomerID = table.Column<int>(type: "int", nullable: false),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Purchases", x => x.PurchaseID);
                    table.ForeignKey(
                        name: "FK_Purchases_Customers_CustomerID",
                        column: x => x.CustomerID,
                        principalTable: "Customers",
                        principalColumn: "CustomerID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PerformerGenre",
                columns: table => new
                {
                    PerformerGenreID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PerformerID = table.Column<int>(type: "int", nullable: false),
                    GenreID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PerformerGenre", x => x.PerformerGenreID);
                    table.ForeignKey(
                        name: "FK_PerformerGenre_Genres_GenreID",
                        column: x => x.GenreID,
                        principalTable: "Genres",
                        principalColumn: "GenreID");
                    table.ForeignKey(
                        name: "FK_PerformerGenre_Performers_PerformerID",
                        column: x => x.PerformerID,
                        principalTable: "Performers",
                        principalColumn: "PerformerID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Events",
                columns: table => new
                {
                    EventID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    EventName = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Description = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    TotalTickets = table.Column<int>(type: "int", nullable: false),
                    TicketsSold = table.Column<int>(type: "int", nullable: false),
                    RegularPrice = table.Column<int>(type: "int", nullable: false),
                    VipPrice = table.Column<int>(type: "int", nullable: false),
                    PremiumPrice = table.Column<int>(type: "int", nullable: false),
                    PerformerID = table.Column<int>(type: "int", nullable: false),
                    EventDate = table.Column<DateTime>(type: "datetime2", nullable: false),
                    LocationID = table.Column<int>(type: "int", nullable: false),
                    StatusID = table.Column<int>(type: "int", nullable: false),
                    TotalScore = table.Column<int>(type: "int", nullable: false),
                    RatingCount = table.Column<int>(type: "int", nullable: false),
                    RatingAverage = table.Column<float>(type: "real", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Events", x => x.EventID);
                    table.ForeignKey(
                        name: "FK_Events_Locations_LocationID",
                        column: x => x.LocationID,
                        principalTable: "Locations",
                        principalColumn: "LocationID",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Events_Performers_PerformerID",
                        column: x => x.PerformerID,
                        principalTable: "Performers",
                        principalColumn: "PerformerID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_Events_Statuses_StatusID",
                        column: x => x.StatusID,
                        principalTable: "Statuses",
                        principalColumn: "StatusID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "CustomerFavoriteEvents",
                columns: table => new
                {
                    CustomerFavoriteEventID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CustomerID = table.Column<int>(type: "int", nullable: false),
                    EventID = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomerFavoriteEvents", x => x.CustomerFavoriteEventID);
                    table.ForeignKey(
                        name: "FK_CustomerFavoriteEvents_Customers_CustomerID",
                        column: x => x.CustomerID,
                        principalTable: "Customers",
                        principalColumn: "CustomerID",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CustomerFavoriteEvents_Events_EventID",
                        column: x => x.EventID,
                        principalTable: "Events",
                        principalColumn: "EventID");
                });

            migrationBuilder.CreateTable(
                name: "Reviews",
                columns: table => new
                {
                    ReviewID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CustomerID = table.Column<int>(type: "int", nullable: false),
                    EventID = table.Column<int>(type: "int", nullable: false),
                    RatingValue = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Reviews", x => x.ReviewID);
                    table.ForeignKey(
                        name: "FK_Reviews_Customers_CustomerID",
                        column: x => x.CustomerID,
                        principalTable: "Customers",
                        principalColumn: "CustomerID");
                    table.ForeignKey(
                        name: "FK_Reviews_Events_EventID",
                        column: x => x.EventID,
                        principalTable: "Events",
                        principalColumn: "EventID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Tickets",
                columns: table => new
                {
                    TicketID = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Price = table.Column<int>(type: "int", nullable: false),
                    EventID = table.Column<int>(type: "int", nullable: false),
                    TicketType = table.Column<int>(type: "int", nullable: false),
                    PurchaseID = table.Column<int>(type: "int", nullable: false),
                    QRCodeData = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Tickets", x => x.TicketID);
                    table.ForeignKey(
                        name: "FK_Tickets_Events_EventID",
                        column: x => x.EventID,
                        principalTable: "Events",
                        principalColumn: "EventID");
                    table.ForeignKey(
                        name: "FK_Tickets_Purchases_PurchaseID",
                        column: x => x.PurchaseID,
                        principalTable: "Purchases",
                        principalColumn: "PurchaseID",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.InsertData(
                table: "Countries",
                columns: new[] { "CountryID", "Name" },
                values: new object[,]
                {
                    { 1, "Bosnia and Herzegovina" },
                    { 2, "Croatia" },
                    { 3, "North Macedonia" },
                    { 4, "Montenegro" },
                    { 5, "Serbia" }
                });

            migrationBuilder.InsertData(
                table: "Genres",
                columns: new[] { "GenreID", "Name" },
                values: new object[,]
                {
                    { 1, "Rock" },
                    { 2, "Pop" },
                    { 3, "Jazz" },
                    { 4, "Classical" },
                    { 5, "Electronic" },
                    { 6, "Hip-Hop" },
                    { 7, "Metal" },
                    { 8, "Folk" }
                });

            migrationBuilder.InsertData(
                table: "Statuses",
                columns: new[] { "StatusID", "StatusName" },
                values: new object[,]
                {
                    { 1, "Pending" },
                    { 2, "Approved" },
                    { 3, "Rejected" }
                });

            migrationBuilder.InsertData(
                table: "Users",
                columns: new[] { "UserID", "Email", "FirstName", "Image", "IsActive", "LastName", "Password", "PhoneNumber", "Salt", "Username" },
                values: new object[,]
                {
                    { 1, "admin@example.com", "Admin", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "User", "87uR2UGEwJb+G94YYYqc4IZIbthyTaHA4boQDN5CExA=", "000000000", "IhR/4bRJzroO4bcmtgHGkqYUmN1Wla4zV4czkA3g7ms=", "admin" },
                    { 2, "dzejla@example.com", "Dzejla", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Ramovic", "wVeM+A7xFOWmNz6WUzs23LSzd+Pm7/PplyQ9GpV87Hk=", "111222333", "pvjWq+VujYdSTol9MA3VVhP6EY+Kql6fYFCBASS+d8M=", "dzejla" },
                    { 3, "ilma@example.com", "Ilma", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Karahmet", "uxK0YxJPz9QLsVfw4ee8fL+dM1uUN8vN6WFPCyOAcqA=", "222333444", "BqpqvdzJDc8t1l7ZBXd1IRCWTZWSg/59+fEDHpoVWrQ=", "ilma" },
                    { 4, "jelena@example.com", "Jelena", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Rozga", "TL7rkXHBNDNC3NPpuVp+h5+SnysyzvjZuqnmmJHcFjM=", "333444555", "I4Pn06A7oNUVQ/kUYqo237If6DFHywUzqb6P5HiHbIU=", "jelena" },
                    { 5, "toni@example.com", "Toni", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Cetinski", "mW/8bOiXthVpBSuYPLobPjvy8i+xTfHNmcDqUIlCDU8=", "444555666", "70L4RL1BfNDf3kdFuFnV8CVKa6P0IwCqpBbhGlydWn0=", "toni" },
                    { 6, "zeljko@example.com", "Zeljko", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Samardzic", "yqgTF438f2Lmh9UVeFJUiwqM9ms4pVlRKExytyEcoLc=", "555666777", "cSWM+1tJLPyb+F6cK8ZQDBzo6Cw+A0qKIWsXkmnKUxU=", "zeljko" },
                    { 7, "selma@example.com", "Selma", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Alagic", "3norKUP6vaGTTLxYT6z8ViqMTwel5H9VzDJtvv8UXsc=", "666777888", "IthWo0ZtwYbd7p5WbFFRhzKQwlPrWpoezX88mm5jVRw=", "selmica" },
                    { 8, "eda@example.com", "Eda", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Erdem", "TeYbmcLPN0RiS6SerDD5m48oJE24WAvx009eqCWJK0A=", "777888999", "p4tjDRYIxKl+mM7f+BAEOGwWCOPqIvpJlo5JIoTqKv4=", "eda" },
                    { 9, "tesa@example.com", "Tesa", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Zahirovic", "5DFY+n7My58tZKF07JOHUu8qJjgTkM7r+hRYKT3qRQQ=", "888999000", "c10TpCTlVieWsdcohjgjLNfMA9KgWwybFQ+3U5o9oUM=", "tess" }
                });

            migrationBuilder.InsertData(
                table: "Admins",
                columns: new[] { "AdminID", "UserID" },
                values: new object[] { 1, 1 });

            migrationBuilder.InsertData(
                table: "Cities",
                columns: new[] { "CityID", "CountryID", "Name" },
                values: new object[,]
                {
                    { 1, 1, "Sarajevo" },
                    { 2, 1, "Banja Luka" },
                    { 3, 1, "Tuzla" },
                    { 4, 1, "Zenica" },
                    { 5, 1, "Mostar" },
                    { 6, 1, "Bihać" },
                    { 7, 2, "Zagreb" },
                    { 8, 2, "Split" },
                    { 9, 3, "Skoplje" },
                    { 10, 4, "Podgorica" },
                    { 11, 4, "Budva" },
                    { 12, 4, "Ulcinj" },
                    { 13, 5, "Beograd" },
                    { 14, 5, "Novi Sad" }
                });

            migrationBuilder.InsertData(
                table: "Customers",
                columns: new[] { "CustomerID", "UserID" },
                values: new object[,]
                {
                    { 1, 7 },
                    { 2, 8 },
                    { 3, 9 }
                });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "NotificationID", "CreatedAt", "IsDeleted", "Message", "UserID", "isRead" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 10, 29, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "New performer request waiting for verification!", 1, true },
                    { 2, new DateTime(2025, 10, 29, 10, 30, 0, 0, DateTimeKind.Unspecified), false, "You have some events waiting for approval!", 1, true },
                    { 3, new DateTime(2025, 11, 28, 12, 0, 0, 0, DateTimeKind.Unspecified), false, "Ilma Karahmet added a new event!", 7, false },
                    { 4, new DateTime(2025, 10, 28, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Toni Cetinski added a new event!", 9, true },
                    { 5, new DateTime(2025, 12, 31, 14, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been approved!", 4, false },
                    { 6, new DateTime(2025, 1, 22, 16, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been rejected!", 5, false },
                    { 7, new DateTime(2025, 2, 9, 16, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been rejected!", 3, false }
                });

            migrationBuilder.InsertData(
                table: "Performers",
                columns: new[] { "PerformerID", "ArtistName", "Bio", "IsApproved", "UserID" },
                values: new object[,]
                {
                    { 1, "Dzejlica", "Pop singer from BiH", true, 2 },
                    { 2, "Ilmica", "Rising pop artist", true, 3 },
                    { 3, "Jelena R", "Famous Croatian pop singer", true, 4 },
                    { 4, "Toni", "Popular Croatian pop singer", true, 5 },
                    { 5, "Zeljko", "Serbian pop-folk singer", true, 6 }
                });

            migrationBuilder.InsertData(
                table: "Locations",
                columns: new[] { "LocationID", "Address", "Capacity", "CityID", "LocationName" },
                values: new object[,]
                {
                    { 1, "Titova 1, Sarajevo", 15000, 1, "Arena Sarajevo" },
                    { 2, "Skenderija 3, Sarajevo", 5000, 1, "Skenderija Hall" },
                    { 3, "Zetra 10, Sarajevo", 12000, 1, "Zetra Olympic Hall" },
                    { 4, "Trg Krajine 5, Banja Luka", 8000, 2, "Banja Luka Arena" },
                    { 5, "Stadionska 1, Tuzla", 7000, 3, "Tuzla Stadium" },
                    { 6, "Mostarska 15, Mostar", 4000, 4, "Mostar Music Hall" },
                    { 7, "Dom Sportova 1, Split", 12000, 7, "Split Arena" },
                    { 8, "Avenija Dubrovnik 15, Zagreb", 16000, 8, "Zagreb Arena" },
                    { 9, "Trg Republike 2, Podgorica", 9000, 9, "Podgorica Sports Center" },
                    { 10, "Ušće 5, Beograd", 18000, 10, "Belgrade Arena" }
                });

            migrationBuilder.InsertData(
                table: "PerformerGenre",
                columns: new[] { "PerformerGenreID", "GenreID", "PerformerID" },
                values: new object[,]
                {
                    { 1, 2, 1 },
                    { 4, 2, 2 },
                    { 5, 8, 2 },
                    { 6, 2, 3 },
                    { 7, 5, 3 },
                    { 8, 2, 4 },
                    { 9, 1, 4 },
                    { 10, 8, 5 },
                    { 13, 8, 1 },
                    { 21, 3, 1 }
                });

            migrationBuilder.InsertData(
                table: "Purchases",
                columns: new[] { "PurchaseID", "CustomerID", "IsDeleted", "PurchaseDate" },
                values: new object[,]
                {
                    { 1, 1, false, new DateTime(2025, 10, 27, 12, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 2, false, new DateTime(2025, 10, 28, 15, 30, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Events",
                columns: new[] { "EventID", "Description", "EventDate", "EventName", "LocationID", "PerformerID", "PremiumPrice", "RatingAverage", "RatingCount", "RegularPrice", "StatusID", "TicketsSold", "TotalScore", "TotalTickets", "VipPrice" },
                values: new object[,]
                {
                    { 1, "Rock Concert 2025", new DateTime(2025, 11, 15, 18, 0, 0, 0, DateTimeKind.Unspecified), "Rock Concert", 1, 1, 50, 0f, 0, 30, 1, 200, 0, 15000, 40 },
                    { 2, "Jazz Night 2525", new DateTime(2025, 11, 15, 21, 0, 0, 0, DateTimeKind.Unspecified), "Jazz Night", 1, 2, 50, 0f, 0, 25, 1, 370, 0, 15000, 30 },
                    { 3, "Outdoor pop music festival", new DateTime(2025, 12, 20, 18, 0, 0, 0, DateTimeKind.Unspecified), "Pop Festival", 3, 3, 50, 0f, 0, 25, 1, 700, 0, 12000, 30 },
                    { 4, "Symphony orchestra live performance", new DateTime(2026, 1, 10, 19, 0, 0, 0, DateTimeKind.Unspecified), "Classical Evening", 4, 4, 50, 0f, 0, 25, 3, 50, 0, 8000, 30 }
                });

            migrationBuilder.InsertData(
                table: "CustomerFavoriteEvents",
                columns: new[] { "CustomerFavoriteEventID", "CustomerID", "EventID" },
                values: new object[,]
                {
                    { 1, 1, 1 },
                    { 2, 1, 2 },
                    { 3, 2, 1 },
                    { 4, 2, 3 }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "ReviewID", "CreatedAt", "CustomerID", "EventID", "RatingValue" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 10, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 1, 5 },
                    { 2, new DateTime(2025, 10, 3, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 2, 4 },
                    { 3, new DateTime(2025, 10, 5, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 1, 3 },
                    { 4, new DateTime(2025, 10, 7, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 3, 5 },
                    { 5, new DateTime(2025, 10, 9, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 2, 4 },
                    { 6, new DateTime(2025, 10, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 3, 2 }
                });

            migrationBuilder.InsertData(
                table: "Tickets",
                columns: new[] { "TicketID", "EventID", "IsDeleted", "Price", "PurchaseID", "QRCodeData", "TicketType" },
                values: new object[,]
                {
                    { 1, 1, false, 40, 1, null, 2 },
                    { 2, 1, false, 40, 1, null, 2 },
                    { 3, 3, false, 25, 2, null, 1 },
                    { 4, 3, false, 25, 2, null, 1 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_Admins_UserID",
                table: "Admins",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Cities_CountryID",
                table: "Cities",
                column: "CountryID");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerFavoriteEvents_CustomerID",
                table: "CustomerFavoriteEvents",
                column: "CustomerID");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerFavoriteEvents_EventID_CustomerID",
                table: "CustomerFavoriteEvents",
                columns: new[] { "EventID", "CustomerID" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Customers_UserID",
                table: "Customers",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Events_LocationID",
                table: "Events",
                column: "LocationID");

            migrationBuilder.CreateIndex(
                name: "IX_Events_PerformerID",
                table: "Events",
                column: "PerformerID");

            migrationBuilder.CreateIndex(
                name: "IX_Events_StatusID",
                table: "Events",
                column: "StatusID");

            migrationBuilder.CreateIndex(
                name: "IX_Locations_CityID",
                table: "Locations",
                column: "CityID");

            migrationBuilder.CreateIndex(
                name: "IX_Notifications_UserID",
                table: "Notifications",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_PerformerGenre_GenreID",
                table: "PerformerGenre",
                column: "GenreID");

            migrationBuilder.CreateIndex(
                name: "IX_PerformerGenre_PerformerID_GenreID",
                table: "PerformerGenre",
                columns: new[] { "PerformerID", "GenreID" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Performers_UserID",
                table: "Performers",
                column: "UserID");

            migrationBuilder.CreateIndex(
                name: "IX_Purchases_CustomerID",
                table: "Purchases",
                column: "CustomerID");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_CustomerID",
                table: "Reviews",
                column: "CustomerID");

            migrationBuilder.CreateIndex(
                name: "IX_Reviews_EventID_CustomerID",
                table: "Reviews",
                columns: new[] { "EventID", "CustomerID" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Tickets_EventID",
                table: "Tickets",
                column: "EventID");

            migrationBuilder.CreateIndex(
                name: "IX_Tickets_PurchaseID",
                table: "Tickets",
                column: "PurchaseID");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Admins");

            migrationBuilder.DropTable(
                name: "CustomerFavoriteEvents");

            migrationBuilder.DropTable(
                name: "Notifications");

            migrationBuilder.DropTable(
                name: "PerformerGenre");

            migrationBuilder.DropTable(
                name: "Reviews");

            migrationBuilder.DropTable(
                name: "Tickets");

            migrationBuilder.DropTable(
                name: "Genres");

            migrationBuilder.DropTable(
                name: "Events");

            migrationBuilder.DropTable(
                name: "Purchases");

            migrationBuilder.DropTable(
                name: "Locations");

            migrationBuilder.DropTable(
                name: "Performers");

            migrationBuilder.DropTable(
                name: "Statuses");

            migrationBuilder.DropTable(
                name: "Customers");

            migrationBuilder.DropTable(
                name: "Cities");

            migrationBuilder.DropTable(
                name: "Users");

            migrationBuilder.DropTable(
                name: "Countries");
        }
    }
}
