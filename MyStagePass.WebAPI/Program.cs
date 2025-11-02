using MyStagePass.Services.Database;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Services.Services;
using MyStagePass.Services.Interfaces;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Server=localhost\\SQLEXPRESS;Database=MyStagePassDummy;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"; //konekcija na bazu ukoliko nemamo u appsetting.json vec definiran default connection
builder.Services.AddDatabaseServices(connectionString);

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
//builder.Services.AddTransient<IUserService, DummyUserService>();
builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<ICustomerService, CustomerService>();

builder.Services.AddAutoMapper(cfg =>
{
	cfg.AddProfile<MappingProfile>();
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
	var dbContext=scope.ServiceProvider.GetRequiredService<MyStagePassDbContext>();
	//dbContext.Database.EnsureCreated(); //pravi bazu samo ako vec ne postoji, ne primjenjuje migracije
	dbContext.Database.Migrate(); //pravi bazu ako ne postoji, azurira bazu i primjenjuje sve do tada neprimijenjene migracije ako vec postoji
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
