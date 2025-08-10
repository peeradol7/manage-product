using Microsoft.EntityFrameworkCore;
using SkuMasterAPI.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Add Entity Framework
builder.Services.AddDbContext<TFHDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("TFHDatabase")));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

// SkuMaster API endpoints
app.MapGet("/api/skumaster", async (TFHDbContext db) =>
{
    return await db.SkuMasters.ToListAsync();
})
.WithName("GetAllSkuMasters")
.WithOpenApi();

app.MapGet("/api/skumaster/{key}", async (int key, TFHDbContext db) =>
{
    return await db.SkuMasters.FindAsync(key) is SkuMaster sku
        ? Results.Ok(sku)
        : Results.NotFound();
})
.WithName("GetSkuMasterByKey")
.WithOpenApi();

app.MapGet("/api/skumaster/{key}/images", async (int key, TFHDbContext db) =>
{
    var skuWithImages = await db.SkuMasters
        .Include(s => s.SkuMasterImages)
        .FirstOrDefaultAsync(s => s.SkuKey == key);
    
    if (skuWithImages == null)
        return Results.NotFound();
    
    return Results.Ok(skuWithImages);
})
.WithName("GetSkuMasterWithImages")
.WithOpenApi();

app.MapGet("/api/skumaster/code/{code}", async (string code, TFHDbContext db) =>
{
    return await db.SkuMasters.FirstOrDefaultAsync(s => s.SkuCode == code) is SkuMaster sku
        ? Results.Ok(sku)
        : Results.NotFound();
})
.WithName("GetSkuMasterByCode")
.WithOpenApi();

app.MapPost("/api/skumaster", async (SkuMaster sku, TFHDbContext db) =>
{
    db.SkuMasters.Add(sku);
    await db.SaveChangesAsync();
    return Results.Created($"/api/skumaster/{sku.SkuKey}", sku);
})
.WithName("CreateSkuMaster")
.WithOpenApi();

app.MapPut("/api/skumaster/{key}", async (int key, SkuMaster inputSku, TFHDbContext db) =>
{
    var sku = await db.SkuMasters.FindAsync(key);
    if (sku is null) return Results.NotFound();

    // Update basic properties - be careful with this as many fields might be system controlled
    sku.SkuCode = inputSku.SkuCode;
    sku.SkuName = inputSku.SkuName;
    sku.SkuEName = inputSku.SkuEName;
    sku.SkuBarcode = inputSku.SkuBarcode;
    sku.SkuEnable = inputSku.SkuEnable;
    sku.SkuPEnable = inputSku.SkuPEnable;
    sku.SkuMsg1 = inputSku.SkuMsg1;
    sku.SkuMsg2 = inputSku.SkuMsg2;
    sku.SkuMsg3 = inputSku.SkuMsg3;
    sku.SkuSpec = inputSku.SkuSpec;
    sku.SkuUsage = inputSku.SkuUsage;
    sku.SkuRemark = inputSku.SkuRemark;

    await db.SaveChangesAsync();
    return Results.NoContent();
})
.WithName("UpdateSkuMaster")
.WithOpenApi();

app.MapDelete("/api/skumaster/{key}", async (int key, TFHDbContext db) =>
{
    if (await db.SkuMasters.FindAsync(key) is SkuMaster sku)
    {
        db.SkuMasters.Remove(sku);
        await db.SaveChangesAsync();
        return Results.NoContent();
    }
    return Results.NotFound();
})
.WithName("DeleteSkuMaster")
.WithOpenApi();

// SkuMasterImage API endpoints
app.MapGet("/api/skumasterimage", async (TFHDbContext db) =>
{
    return await db.SkuMasterImages.Include(i => i.SkuMaster).ToListAsync();
})
.WithName("GetAllSkuMasterImages")
.WithOpenApi();

app.MapGet("/api/skumasterimage/{id}", async (int id, TFHDbContext db) =>
{
    return await db.SkuMasterImages.Include(i => i.SkuMaster).FirstOrDefaultAsync(i => i.Id == id) is SkuMasterImage image
        ? Results.Ok(image)
        : Results.NotFound();
})
.WithName("GetSkuMasterImageById")
.WithOpenApi();

app.MapGet("/api/skumasterimage/master/{masterId}", async (int masterId, TFHDbContext db) =>
{
    var images = await db.SkuMasterImages.Where(i => i.MasterId == masterId).ToListAsync();
    return Results.Ok(images);
})
.WithName("GetSkuMasterImagesByMasterId")
.WithOpenApi();

app.MapPost("/api/skumasterimage", async (SkuMasterImage image, TFHDbContext db) =>
{
    // Validate that the SkuMaster exists
    var skuMaster = await db.SkuMasters.FindAsync(image.MasterId);
    if (skuMaster == null)
    {
        return Results.BadRequest("SkuMaster with the specified MasterId does not exist.");
    }

    db.SkuMasterImages.Add(image);
    await db.SaveChangesAsync();
    return Results.Created($"/api/skumasterimage/{image.Id}", image);
})
.WithName("CreateSkuMasterImage")
.WithOpenApi();

app.MapPut("/api/skumasterimage/{id}", async (int id, SkuMasterImage inputImage, TFHDbContext db) =>
{
    var image = await db.SkuMasterImages.FindAsync(id);
    if (image is null) return Results.NotFound();

    // Validate that the SkuMaster exists if MasterId is being changed
    if (image.MasterId != inputImage.MasterId)
    {
        var skuMaster = await db.SkuMasters.FindAsync(inputImage.MasterId);
        if (skuMaster == null)
        {
            return Results.BadRequest("SkuMaster with the specified MasterId does not exist.");
        }
    }

    image.MasterId = inputImage.MasterId;
    image.ImageName = inputImage.ImageName;

    await db.SaveChangesAsync();
    return Results.NoContent();
})
.WithName("UpdateSkuMasterImage")
.WithOpenApi();

app.MapDelete("/api/skumasterimage/{id}", async (int id, TFHDbContext db) =>
{
    if (await db.SkuMasterImages.FindAsync(id) is SkuMasterImage image)
    {
        db.SkuMasterImages.Remove(image);
        await db.SaveChangesAsync();
        return Results.NoContent();
    }
    return Results.NotFound();
})
.WithName("DeleteSkuMasterImage")
.WithOpenApi();

app.Run();
