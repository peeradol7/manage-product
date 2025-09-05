using Microsoft.EntityFrameworkCore;
using System.Text.Json.Serialization.Metadata;
using SkuMasterAPI.Models;
using SkuMasterAPI.Application.Services;

var builder = WebApplication.CreateBuilder(args);

System.Text.Encoding.RegisterProvider(System.Text.CodePagesEncodingProvider.Instance);

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
        options.JsonSerializerOptions.PropertyNamingPolicy = null;
        options.JsonSerializerOptions.TypeInfoResolver = new DefaultJsonTypeInfoResolver();
    });

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.Services.AddDbContext<TFHDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("TFHDatabase")));

builder.Services.AddScoped<ISkuMasterService, SkuMasterService>();
builder.Services.AddScoped<IFileService, FileService>();
builder.Services.AddScoped<IUrlHelperService, UrlHelperService>();
builder.Services.AddScoped<IStringCleaningService, StringCleaningService>();

builder.Services.AddHttpContextAccessor();

var app = builder.Build();

// Test database connection
using (var scope = app.Services.CreateScope())

{
    var context = scope.ServiceProvider.GetRequiredService<TFHDbContext>();
    try
    {
        // Test connection first
        var canConnect = await context.Database.CanConnectAsync();
        if (canConnect)
        {
            Console.WriteLine("Database connection successful");
            context.Database.EnsureCreated();
            Console.WriteLine("Database ensured/created successfully");
        }
        else
        {
            Console.WriteLine("Cannot connect to database");
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Database connection error: {ex.Message}");
        Console.WriteLine("Please check:");
        Console.WriteLine("1. SQL Server is running");
        Console.WriteLine("2. Connection string is correct");
        Console.WriteLine("3. Network connectivity to database server");
    }
}

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseStaticFiles();

app.MapControllers();

app.Run();
