using MyStagePass.Services.Database;
using Microsoft.EntityFrameworkCore;
using MyStagePass.Services.Services;
using MyStagePass.Services.Interfaces;
using System.Text.Json.Serialization;
using Microsoft.OpenApi.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using MyStagePass.WebAPI.Filters;
using DotNetEnv;

var envPath = Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", ".env");
if (File.Exists(envPath))
	Env.Load(envPath);

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

	c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
	{
		In = ParameterLocation.Header,
		Description = "Insert JWT token like: Bearer {token}",
		Name = "Authorization",
		Type = SecuritySchemeType.ApiKey,
		Scheme = "Bearer"
	});

	c.AddSecurityRequirement(new OpenApiSecurityRequirement
	{
		{
			new OpenApiSecurityScheme
			{
				Reference = new OpenApiReference
				{
					Type = ReferenceType.SecurityScheme,
					Id = "Bearer"
				}
			},
			Array.Empty<string>()
		}
	});
});

builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
	.AddJwtBearer(options =>
	{
		options.TokenValidationParameters = new TokenValidationParameters
		{
			ValidateIssuerSigningKey = true,
			IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable("JWT_SECRET_KEY"))),
			ValidateIssuer = false,
			ValidateAudience = false
		};
});

builder.Services.AddControllers(x =>
{
	x.Filters.Add<ErrorFilter>();
})
.AddJsonOptions(x => x.JsonSerializerOptions.ReferenceHandler = ReferenceHandler.IgnoreCycles);
builder.Services.AddScoped<ErrorFilter>();
builder.Services.AddAuthorization();


// Add services to the container.
var dbName = Environment.GetEnvironmentVariable("DB_NAME");
var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD");

if (string.IsNullOrWhiteSpace(dbName))
	throw new InvalidOperationException("DB_NAME missing");
if (string.IsNullOrWhiteSpace(dbPassword))
	throw new InvalidOperationException("DB_PASSWORD missing");

var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";
var trustedConnection = Environment.GetEnvironmentVariable("DB_TRUSTED_CONNECTION") ?? "False";
var connectionString = trustedConnection == "True"
	? $"Server={dbHost};Database={dbName};Trusted_Connection=True;TrustServerCertificate=True;"
	: $"Server={dbHost};Database={dbName};User Id=sa;Password={dbPassword};TrustServerCertificate=True;";

builder.Services.AddDbContext<MyStagePassDbContext>(options => options.UseSqlServer(connectionString));

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();

builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddScoped<ICustomerService, CustomerService>();
builder.Services.AddScoped<IAdminService, AdminService>();
builder.Services.AddScoped<IPerformerService, PerformerService>();
builder.Services.AddScoped<IStatusService, StatusService>();
builder.Services.AddScoped<IEventService, EventService>();
builder.Services.AddScoped<ICityService, CityService>();
builder.Services.AddScoped<IGenreService, GenreService>();
builder.Services.AddScoped<ITicketService, TicketService>();
builder.Services.AddScoped<IPurchaseService, PurchaseService>();
builder.Services.AddScoped<ILocationService, LocationService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<ICountryService, CountryService>();
builder.Services.AddScoped<IReviewService, ReviewService>();
builder.Services.AddScoped<ICustomerFavoriteEventService, CustomerFavoriteEventService>();
builder.Services.AddSingleton<IRabbitMQProducer, RabbitMQProducer>();
builder.Services.AddScoped<IRecommendedService, RecommendedService>();
builder.Services.AddScoped<IReportService, ReportService>();
builder.Services.AddScoped<IPaymentService, PaymentService>();

builder.Services.AddAutoMapper(cfg => { cfg.AddProfile<MappingProfile>(); });

builder.Services.AddCors(options =>
{
	options.AddPolicy("AllowFlutter",
		policy =>
		{
			policy.AllowAnyOrigin()
				  .AllowAnyMethod()
				  .AllowAnyHeader();
		});
});

builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<ICurrentUserService, CurrentUserService>();

Stripe.StripeConfiguration.ApiKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");
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

app.UseCors("AllowFlutter");
app.UseHttpsRedirection();
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();