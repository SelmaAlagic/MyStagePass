using MyStagePass.Services.Database;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Services.Services;
using MyStagePass.Services.Interfaces;
using System.Text.Json.Serialization;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSwaggerGen(c =>
{
	c.SwaggerDoc("v1", new OpenApiInfo
	{
		Title = "MyStagePass.WebAPI",
		Version = "v1"
	});

	c.CustomSchemaIds(type =>
	{
		if (type.IsGenericType)
		{
			var genericTypeName = type.GetGenericTypeDefinition().Name.Split('`')[0];
			var genericArgs = string.Join("", type.GetGenericArguments().Select(t => t.Name));
			return $"{genericTypeName}Of{genericArgs}";
		}

		if (type.Namespace?.StartsWith("MyStagePass.Model") == true)
		{
			return type.Name;
		}
		return type.FullName?.Replace("+", ".");
	});

});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
	.AddJwtBearer(options =>
	{
		options.TokenValidationParameters = new TokenValidationParameters
		{
			ValidateIssuerSigningKey = true,
			IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration.GetSection("AppSettings:Token").Value ?? "my-secret-key-minimum-32-characters-long!@#$%")),
			ValidateIssuer = false,
			ValidateAudience = false
		};
	});

// Add services to the container.
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") ?? "Server=localhost\\SQLEXPRESS;Database=MyStagePassDummy;Trusted_Connection=True;TrustServerCertificate=True;MultipleActiveResultSets=true"; //konekcija na bazu ukoliko nemamo u appsetting.json vec definiran default connection
builder.Services.AddDatabaseServices(connectionString);

builder.Services.AddControllers()
	.AddJsonOptions(x =>
		x.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles);
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddTransient<IUserService, UserService>();
builder.Services.AddTransient<ICustomerService, CustomerService>();
builder.Services.AddTransient<IAdminService, AdminService>();
builder.Services.AddTransient<IPerformerService, PerformerService>();
builder.Services.AddTransient<IEventService, EventService>();
builder.Services.AddTransient<ICityService, CityService>();
builder.Services.AddTransient<IGenreService, GenreService>();
builder.Services.AddTransient<ITicketService, TicketService>();


builder.Services.AddAutoMapper(cfg =>
{
	cfg.AddProfile<MappingProfile>();
});

var app = builder.Build();

using (var scope = app.Services.CreateScope())
{
	var dbContext=scope.ServiceProvider.GetRequiredService<MyStagePassDbContext>();
	dbContext.Database.Migrate(); 
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
	app.UseSwagger();
	app.UseSwaggerUI();
}


app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
