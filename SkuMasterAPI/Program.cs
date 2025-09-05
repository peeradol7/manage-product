using Microsoft.EntityFrameworkCore;
using SkuMasterAPI.Models;
using SkuMasterAPI.Application.Services;

var builder = WebApplication.CreateBuilder(args);

// Configure encoding for Thai language support
System.Text.Encoding.RegisterProvider(System.Text.CodePagesEncodingProvider.Instance);

// Add services to the container.
builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
    });
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<TFHDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("TFHDatabase")));

// Add Application Services
builder.Services.AddScoped<ISkuMasterService, SkuMasterService>();
builder.Services.AddScoped<IFileService, FileService>();
builder.Services.AddScoped<IUrlHelperService, UrlHelperService>();
builder.Services.AddScoped<IStringCleaningService, StringCleaningService>();

// Add HttpContextAccessor for URL generation
builder.Services.AddHttpContextAccessor();

var app = builder.Build();

// Ensure database is created
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<TFHDbContext>();
    try
    {
        context.Database.EnsureCreated();
        Console.WriteLine("Database ensured/created successfully");
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Database creation error: {ex.Message}");
    }
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// Enable static files serving for images
app.UseStaticFiles();

// Add authorization (if needed in the future)
// app.UseAuthorization();

// Map controller routes
app.MapControllers();

app.Run();
