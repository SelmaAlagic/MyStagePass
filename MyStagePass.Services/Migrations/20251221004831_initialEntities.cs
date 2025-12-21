using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace MyStagePass.Services.Migrations
{
    /// <inheritdoc />
    public partial class initialEntities : Migration
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
                    { 8, "Folk" },
                    { 9, "Pop-Folk" }
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
                    { 3, "ilma@example.com", "Ilma", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Karahmet", "uxK0YxJPz9QLsVfw4ee8fL+dM1uUN8vN6WFPCyOAcqA=", "222333444", "BqpqvdzJDc8t1l7ZBXd1IRCWTZWSg/59+fEDHpoVWrQ=", "ilmaak" },
                    { 4, "jelena@example.com", "Jelena", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Rozga", "TL7rkXHBNDNC3NPpuVp+h5+SnysyzvjZuqnmmJHcFjM=", "333444555", "I4Pn06A7oNUVQ/kUYqo237If6DFHywUzqb6P5HiHbIU=", "jelena" },
                    { 5, "toni@example.com", "Toni", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Cetinski", "mW/8bOiXthVpBSuYPLobPjvy8i+xTfHNmcDqUIlCDU8=", "444555666", "70L4RL1BfNDf3kdFuFnV8CVKa6P0IwCqpBbhGlydWn0=", "toniii" },
                    { 6, "zeljko@example.com", "Zeljko", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Samardzic", "yqgTF438f2Lmh9UVeFJUiwqM9ms4pVlRKExytyEcoLc=", "555666777", "cSWM+1tJLPyb+F6cK8ZQDBzo6Cw+A0qKIWsXkmnKUxU=", "zeljko" },
                    { 7, "adi.sose@music.ba", "Adi", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Sose", "AFrPHkJgGwem4HcBxjOQVIAb4Q28BzVVHX/ZN6Q9xRo=", "062100200", "BT3f8UtxcoBLisQB/FJxwuqqnOay2ljl/QVUEBJvTmI=", "adiadi" },
                    { 8, "mirza.selimovic@music.ba", "Mirza", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Selimovic", "t65o+TDWMg3wZqvSauac7Za9O+WSYLUCCTZd16LPQ9c=", "062300400", "ND4TT9G7L0CPqEUZSZPt01WwWVfygp8IjBinRgUKpAo=", "mirza" },
                    { 9, "marija.serifovic@music.rs", "Marija", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Serifovic", "n0UVopmYJy/g6js2r+XAweB02IzjO/y8FsWdqNy/BrY=", "062500600", "x0YMxizLpEYY6lYHkWqcaYw9V+Yyvg83y+Iy10IqLWw=", "marija" },
                    { 10, "andjela.ignjatovic@music.rs", "Andjela", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Ignjatovic", "ca1n8phe9qcWgzl7zmBl0aJyuvxut+GMkUK+L6pcfkk=", "062888999", "mZzvr89UfKLoIUbL71pQvqThUqsYQ7egDS7A5aRF21g=", "breskvica" },
                    { 11, "selma@example.com", "Selma", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Alagic", "3norKUP6vaGTTLxYT6z8ViqMTwel5H9VzDJtvv8UXsc=", "666777888", "IthWo0ZtwYbd7p5WbFFRhzKQwlPrWpoezX88mm5jVRw=", "selmica" },
                    { 12, "eda@example.com", "Eda", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Erdem", "TeYbmcLPN0RiS6SerDD5m48oJE24WAvx009eqCWJK0A=", "777888999", "p4tjDRYIxKl+mM7f+BAEOGwWCOPqIvpJlo5JIoTqKv4=", "edaer" },
                    { 13, "tesa@example.com", "Tesa", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Zahirovic", "5DFY+n7My58tZKF07JOHUu8qJjgTkM7r+hRYKT3qRQQ=", "888999000", "c10TpCTlVieWsdcohjgjLNfMA9KgWwybFQ+3U5o9oUM=", "tesaza" },
                    { 14, "amar.hadzic@example.com", "Amar", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Hadzic", "/fq/ZbEHiyr+6qHRPVl8fFYkHOBMowMiRfUH3Of3x1E=", "061111222", "FCzcfULb99fc3b7Qjy+heBwjPKhOmNqedHHS3JjGIfI=", "amarh" },
                    { 15, "lejla.besic@example.com", "Lejla", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Besic", "7erFCNVSn07ADEKFvD1GGV3nuZNEcpCUYwt7qLN3nkQ=", "061333444", "l88utjIAbSXngCFU3vPPYI+6sP7WdmSXeXpzqcS2qdM=", "lejla" },
                    { 16, "senad.alagic@example.com", "Senad", new byte[] { 137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 4, 0, 0, 0, 181, 28, 12, 2, 0, 0, 0, 11, 73, 68, 65, 84, 120, 218, 99, 252, 255, 2, 0, 2, 5, 1, 0, 239, 159, 224, 185, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130 }, true, "Alagic", "963sbRGs1agjPtAZPUtFAFdS3c84DlPA3FFRsVR2/3A=", "061777888", "Oxh+ozoEh9xY6lApHpi3ICxYcBdqNSpI+dikiXpjZqw=", "senad" }
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
                    { 1, 11 },
                    { 2, 12 },
                    { 3, 13 },
                    { 4, 14 },
                    { 5, 15 },
                    { 6, 16 }
                });

            migrationBuilder.InsertData(
                table: "Notifications",
                columns: new[] { "NotificationID", "CreatedAt", "IsDeleted", "Message", "UserID", "isRead" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 10, 29, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "New performer request waiting for verification!", 1, true },
                    { 2, new DateTime(2025, 10, 29, 10, 30, 0, 0, DateTimeKind.Unspecified), false, "You have some events waiting for approval!", 1, true },
                    { 3, new DateTime(2025, 1, 15, 12, 0, 0, 0, DateTimeKind.Unspecified), false, "Adi Sose added a new event!", 11, false },
                    { 4, new DateTime(2025, 1, 20, 15, 0, 0, 0, DateTimeKind.Unspecified), false, "Mirza Selimovic added a new event!", 12, true },
                    { 5, new DateTime(2025, 2, 1, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Jelena Rozga added a new event!", 13, false },
                    { 6, new DateTime(2025, 2, 10, 14, 0, 0, 0, DateTimeKind.Unspecified), false, "Marija Serifovic added a new event!", 15, false },
                    { 7, new DateTime(2025, 2, 12, 9, 0, 0, 0, DateTimeKind.Unspecified), false, "Dzejla Ramovic added a new event!", 11, true },
                    { 8, new DateTime(2025, 1, 5, 10, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been approved!", 9, true },
                    { 9, new DateTime(2025, 1, 22, 16, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been rejected!", 2, false },
                    { 10, new DateTime(2025, 1, 10, 11, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been approved!", 7, true },
                    { 11, new DateTime(2025, 2, 9, 16, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been rejected!", 10, false },
                    { 12, new DateTime(2025, 2, 11, 12, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been approved!", 3, false },
                    { 13, new DateTime(2025, 1, 15, 8, 0, 0, 0, DateTimeKind.Unspecified), false, "Your event has been approved!", 8, true }
                });

            migrationBuilder.InsertData(
                table: "Performers",
                columns: new[] { "PerformerID", "ArtistName", "Bio", "IsApproved", "UserID" },
                values: new object[,]
                {
                    { 1, "Dzejla Ramovic", "Pop singer from BiH", true, 2 },
                    { 2, "Ilma Karahmet", "Rising pop artist", true, 3 },
                    { 3, "Jelena Rozga", "Famous Croatian pop singer", true, 4 },
                    { 4, "Toni Cetinski", "Popular Croatian pop singer", true, 5 },
                    { 5, "Zeljko Samardzic", "Serbian pop-folk singer", true, 6 },
                    { 6, "Adi Sose", "Vocalist known for unique style", true, 7 },
                    { 7, "Mirza Selimovic", "Pop-folk singer from BiH", true, 8 },
                    { 8, "Marija Serifovic", "Eurovision winner and pop star", true, 9 },
                    { 9, "Breskvica", "Modern pop and trap artist", true, 10 }
                });

            migrationBuilder.InsertData(
                table: "Locations",
                columns: new[] { "LocationID", "Address", "Capacity", "CityID", "LocationName" },
                values: new object[,]
                {
                    { 1, "Titova 1", 15000, 1, "Arena Sarajevo" },
                    { 2, "Skenderija 3", 5000, 1, "Skenderija Hall" },
                    { 3, "Zetra 10", 12000, 1, "Zetra Olympic Hall" },
                    { 4, "Trg Krajine 5", 8000, 2, "Banja Luka Arena" },
                    { 5, "Stadionska 1", 7000, 3, "Tuzla Stadium" },
                    { 6, "Mostarska 15", 4000, 5, "Mostar Music Hall" },
                    { 7, "Dom Sportova 1", 12000, 8, "Split Arena" },
                    { 8, "Avenija Dubrovnik 15", 16000, 7, "Zagreb Arena" },
                    { 9, "Trg Republike 2", 9000, 10, "Podgorica Sports Center" },
                    { 10, "Ušće 5", 18000, 13, "Belgrade Arena" },
                    { 11, "Teodora Kolokotronisa", 10000, 2, "Kastel Fortress" },
                    { 12, "Bosne Srebrene", 5000, 3, "Mejdan Hall" },
                    { 13, "Bulevar Kulina bana", 15000, 4, "Bilino Polje" },
                    { 14, "Aleja šehida", 6200, 4, "Arena Zenica" },
                    { 15, "Bijeli Brijeg", 9000, 5, "Stadion pod Bijelim Brijegom" },
                    { 16, "Luke bb", 3000, 6, "Dvorana Luke" },
                    { 17, "Borići", 8000, 6, "Stadion pod Borićima" },
                    { 18, "Trg sportova 11", 7000, 7, "Dom Sportova" },
                    { 19, "8. Mediteranskih igara 2", 34000, 8, "Stadion Poljud" },
                    { 20, "Bulevar 8. Septemvri", 10000, 9, "Boris Trajkovski Arena" },
                    { 21, "Aminta Treti", 33000, 9, "National Arena Toshe Proeski" },
                    { 22, "Vaka Đurovića", 15000, 10, "Stadion pod Goricom" },
                    { 23, "Topliš bb", 5000, 11, "Top Hill" },
                    { 24, "Plaža Jaz", 30000, 11, "Jaz Beach Arena" },
                    { 25, "Velika Plaža", 20000, 12, "Velika Plaža Stage" },
                    { 26, "Bulevar Teuta", 3000, 12, "Ulcinj Open Hall" },
                    { 27, "Milentija Popovića 9", 4000, 13, "Sava Centar" },
                    { 28, "Sutjeska 2", 11000, 14, "SPENS Hall" },
                    { 29, "Petrovaradin", 40000, 14, "Petrovaradin Fortress" }
                });

            migrationBuilder.InsertData(
                table: "PerformerGenre",
                columns: new[] { "PerformerGenreID", "GenreID", "PerformerID" },
                values: new object[,]
                {
                    { 1, 2, 2 },
                    { 2, 9, 2 },
                    { 3, 2, 3 },
                    { 4, 2, 4 },
                    { 5, 8, 4 },
                    { 6, 1, 5 },
                    { 7, 2, 5 },
                    { 8, 2, 6 },
                    { 9, 9, 6 },
                    { 10, 2, 7 },
                    { 11, 2, 8 },
                    { 12, 9, 8 },
                    { 13, 2, 9 }
                });

            migrationBuilder.InsertData(
                table: "Purchases",
                columns: new[] { "PurchaseID", "CustomerID", "IsDeleted", "PurchaseDate" },
                values: new object[,]
                {
                    { 1, 1, false, new DateTime(2025, 2, 1, 12, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 2, 1, false, new DateTime(2025, 2, 5, 14, 30, 0, 0, DateTimeKind.Unspecified) },
                    { 3, 1, false, new DateTime(2025, 2, 10, 9, 15, 0, 0, DateTimeKind.Unspecified) },
                    { 4, 2, false, new DateTime(2025, 1, 20, 10, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 5, 2, false, new DateTime(2025, 2, 8, 11, 45, 0, 0, DateTimeKind.Unspecified) },
                    { 6, 3, false, new DateTime(2025, 2, 11, 16, 20, 0, 0, DateTimeKind.Unspecified) },
                    { 7, 5, false, new DateTime(2025, 1, 30, 12, 0, 0, 0, DateTimeKind.Unspecified) },
                    { 8, 5, false, new DateTime(2025, 2, 12, 15, 10, 0, 0, DateTimeKind.Unspecified) },
                    { 9, 6, false, new DateTime(2025, 2, 14, 18, 0, 0, 0, DateTimeKind.Unspecified) }
                });

            migrationBuilder.InsertData(
                table: "Events",
                columns: new[] { "EventID", "Description", "EventDate", "EventName", "LocationID", "PerformerID", "PremiumPrice", "RatingAverage", "RatingCount", "RegularPrice", "StatusID", "TicketsSold", "TotalScore", "TotalTickets", "VipPrice" },
                values: new object[,]
                {
                    { 1, "A journey back to the golden era of music with timeless hits and spectacular production.", new DateTime(2024, 10, 10, 20, 0, 0, 0, DateTimeKind.Unspecified), "Retro Night Spectacle", 13, 6, 100, 4.8f, 100, 30, 2, 18000, 480, 18000, 60 },
                    { 2, "An emotional live experience featuring the most beautiful ballads of the decade.", new DateTime(2024, 11, 5, 21, 0, 0, 0, DateTimeKind.Unspecified), "Heartbeat Tour", 7, 4, 120, 4.9f, 100, 35, 2, 12000, 490, 12000, 70 },
                    { 3, "An intimate atmosphere showcasing raw emotions through special acoustic arrangements.", new DateTime(2024, 11, 25, 20, 30, 0, 0, DateTimeKind.Unspecified), "Acoustic Unplugged Night", 18, 5, 150, 4.5f, 100, 40, 2, 6500, 450, 7000, 80 },
                    { 4, "The hottest winter night featuring top-tier rhythms and a clubbing atmosphere to remember.", new DateTime(2024, 12, 20, 23, 0, 0, 0, DateTimeKind.Unspecified), "Winter Club Party", 23, 9, 90, 4.2f, 100, 25, 2, 5000, 420, 5000, 50 },
                    { 5, "A glamorous New Year's celebration with an exclusive musical program and premium entertainment.", new DateTime(2024, 12, 31, 22, 0, 0, 0, DateTimeKind.Unspecified), "New Year's Eve Gala", 6, 2, 150, 4.7f, 100, 50, 2, 4000, 470, 4000, 100 },
                    { 6, "Vocal domination and energy that pushes the boundaries of modern pop music.", new DateTime(2025, 1, 10, 20, 0, 0, 0, DateTimeKind.Unspecified), "The Power of Voice", 2, 3, 80, 4.6f, 100, 20, 2, 4200, 460, 5000, 40 },
                    { 7, "The perfect prelude to the holiday of love featuring the most romantic local melodies.", new DateTime(2025, 2, 5, 21, 0, 0, 0, DateTimeKind.Unspecified), "Valentine's Warmup", 12, 8, 90, 4.8f, 100, 25, 2, 5000, 480, 5000, 50 },
                    { 8, "An audio-visual spectacle in the largest arena that will leave you breathless.", new DateTime(2025, 2, 10, 20, 0, 0, 0, DateTimeKind.Unspecified), "The Arena Experience", 8, 9, 130, 5f, 100, 35, 2, 16000, 500, 16000, 75 },
                    { 9, "A special concert evening dedicated to love in the heart of Sarajevo.", new DateTime(2025, 2, 14, 20, 0, 0, 0, DateTimeKind.Unspecified), "Valentine's Live Special", 1, 7, 90, 0f, 0, 25, 2, 8000, 0, 15000, 50 },
                    { 10, "A major pop concert designed to be the highlight of the winter tour season.", new DateTime(2025, 2, 22, 22, 0, 0, 0, DateTimeKind.Unspecified), "Canceled Pop Show", 26, 2, 70, 0f, 0, 20, 3, 0, 0, 3000, 40 },
                    { 11, "A traditional concert dedicated to all ladies with flowers, emotions, and songs.", new DateTime(2025, 3, 8, 20, 0, 0, 0, DateTimeKind.Unspecified), "Women's Day Spectacle", 14, 3, 80, 0f, 0, 20, 1, 2500, 0, 6200, 40 },
                    { 12, "Awakening of spring with new energy and the premiere of upcoming singles.", new DateTime(2025, 3, 15, 21, 0, 0, 0, DateTimeKind.Unspecified), "Spring Live Tour", 4, 8, 85, 0f, 0, 20, 2, 3100, 0, 8000, 45 },
                    { 13, "An exclusive night in a prestigious setting with top-tier musicians and surprise guests.", new DateTime(2025, 3, 28, 20, 0, 0, 0, DateTimeKind.Unspecified), "Sava Center Exclusive", 27, 4, 160, 0f, 0, 45, 1, 3800, 0, 4000, 90 },
                    { 14, "Vocal magic that captures hearts across the region as part of a major tour.", new DateTime(2025, 4, 5, 20, 0, 0, 0, DateTimeKind.Unspecified), "Vocal Magic Live", 28, 9, 110, 0f, 0, 30, 2, 5000, 0, 11000, 60 },
                    { 15, "A fusion of powerful sounds and pop melodies in a legendary sports arena.", new DateTime(2025, 4, 12, 20, 30, 0, 0, DateTimeKind.Unspecified), "Pop Rock Evening", 2, 5, 100, 0f, 0, 30, 1, 1500, 0, 5000, 60 },
                    { 16, "An outdoor summer festival planned to gather thousands of music lovers.", new DateTime(2025, 4, 25, 22, 0, 0, 0, DateTimeKind.Unspecified), "Rejected Summer Fest", 26, 9, 90, 0f, 0, 25, 3, 0, 0, 3000, 50 },
                    { 17, "A grand concert under the stars in a massive stadium setting.", new DateTime(2025, 5, 10, 21, 0, 0, 0, DateTimeKind.Unspecified), "Stadium Open Air", 15, 7, 80, 0f, 0, 20, 2, 4500, 0, 9000, 45 },
                    { 18, "A night to remember at the ancient fortress with premium sound and light shows.", new DateTime(2025, 5, 17, 21, 0, 0, 0, DateTimeKind.Unspecified), "Kastel Fortress Spectacle", 11, 6, 95, 0f, 0, 25, 1, 3000, 0, 10000, 50 },
                    { 19, "The biggest concert of the artist's career in the legendary Olympic hall.", new DateTime(2025, 5, 24, 20, 30, 0, 0, DateTimeKind.Unspecified), "Zetra Hall Live", 3, 2, 100, 0f, 0, 25, 2, 5200, 0, 12000, 55 },
                    { 20, "Closing the spring season with a massive festival lineup at the fortress.", new DateTime(2025, 5, 31, 19, 0, 0, 0, DateTimeKind.Unspecified), "Balkan Spring Festival", 29, 8, 200, 0f, 0, 40, 1, 12000, 0, 40000, 100 }
                });

            migrationBuilder.InsertData(
                table: "CustomerFavoriteEvents",
                columns: new[] { "CustomerFavoriteEventID", "CustomerID", "EventID" },
                values: new object[,]
                {
                    { 1, 1, 9 },
                    { 2, 1, 14 },
                    { 3, 1, 19 },
                    { 4, 2, 12 },
                    { 5, 2, 17 },
                    { 6, 3, 13 },
                    { 7, 5, 11 },
                    { 8, 5, 20 },
                    { 9, 6, 18 }
                });

            migrationBuilder.InsertData(
                table: "Reviews",
                columns: new[] { "ReviewID", "CreatedAt", "CustomerID", "EventID", "RatingValue" },
                values: new object[,]
                {
                    { 1, new DateTime(2024, 10, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 1, 5 },
                    { 2, new DateTime(2024, 10, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 1, 5 },
                    { 3, new DateTime(2024, 10, 12, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 1, 4 },
                    { 4, new DateTime(2024, 11, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 2, 5 },
                    { 5, new DateTime(2024, 11, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 2, 5 },
                    { 6, new DateTime(2024, 11, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 3, 5 },
                    { 7, new DateTime(2024, 11, 26, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 3, 4 },
                    { 8, new DateTime(2024, 12, 21, 0, 0, 0, 0, DateTimeKind.Unspecified), 6, 4, 4 },
                    { 9, new DateTime(2024, 12, 22, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 4, 3 },
                    { 10, new DateTime(2025, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 5, 5 },
                    { 11, new DateTime(2025, 1, 2, 0, 0, 0, 0, DateTimeKind.Unspecified), 5, 5, 4 },
                    { 12, new DateTime(2025, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 6, 5 },
                    { 13, new DateTime(2025, 1, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 4, 6, 4 },
                    { 14, new DateTime(2025, 2, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 3, 7, 5 },
                    { 15, new DateTime(2025, 2, 6, 0, 0, 0, 0, DateTimeKind.Unspecified), 6, 7, 5 },
                    { 16, new DateTime(2025, 2, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 1, 8, 5 },
                    { 17, new DateTime(2025, 2, 11, 0, 0, 0, 0, DateTimeKind.Unspecified), 2, 8, 5 }
                });

            migrationBuilder.InsertData(
                table: "Tickets",
                columns: new[] { "TicketID", "EventID", "IsDeleted", "Price", "PurchaseID", "QRCodeData", "TicketType" },
                values: new object[,]
                {
                    { 1, 9, false, 50, 1, null, 2 },
                    { 2, 9, false, 50, 1, null, 2 },
                    { 3, 9, false, 50, 1, null, 2 },
                    { 4, 14, false, 110, 2, null, 3 },
                    { 5, 19, false, 25, 3, null, 1 },
                    { 6, 19, false, 25, 3, null, 1 },
                    { 7, 12, false, 20, 4, null, 1 },
                    { 8, 12, false, 20, 4, null, 1 },
                    { 9, 17, false, 45, 5, null, 2 },
                    { 10, 13, false, 160, 6, null, 3 },
                    { 11, 13, false, 160, 6, null, 3 },
                    { 12, 11, false, 20, 7, null, 1 },
                    { 13, 19, false, 55, 8, null, 2 },
                    { 14, 19, false, 55, 8, null, 2 },
                    { 15, 20, false, 40, 9, null, 1 },
                    { 16, 20, false, 40, 9, null, 1 },
                    { 17, 20, false, 40, 9, null, 1 }
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
