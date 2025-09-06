using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SkuMasterAPI.Models;
using SkuMasterAPI.Application.DTOs;
using SkuMasterAPI.Application.Services;

namespace SkuMasterAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SkuMasterImageController : ControllerBase
    {
        private readonly TFHDbContext _context;
        private readonly IFileService _fileService;
        private readonly IWebHostEnvironment _environment;
        private readonly IStringCleaningService _stringCleaningService;

        public SkuMasterImageController(
            TFHDbContext context,
            IFileService fileService,
            IWebHostEnvironment environment,
            IStringCleaningService stringCleaningService)
        {
            _context = context;
            _fileService = fileService;
            _environment = environment;
            _stringCleaningService = stringCleaningService;
        }

        /// <summary>
        /// Update SkuMaster: Name, Images and Size details
        /// </summary>
        [HttpPost("update")]
        public async Task<ActionResult<UpdateSkuMasterResponseDto>> UpdateSkuMaster([FromForm] UpdateSkuMasterDto dto)
        {
            var response = new UpdateSkuMasterResponseDto();

            try
            {
                var skuMaster = await _context.SkuMasters.FindAsync(dto.SkuKey);
                if (skuMaster == null)
                {
                    response.Success = false;
                    response.Message = "SkuMaster not found";
                    response.Errors.Add($"SkuMaster with key {dto.SkuKey} not found");
                    return BadRequest(response);
                }

                if (!string.IsNullOrEmpty(dto.SkuName))
                {
                    // Only update SkuName if it's actually different to avoid unnecessary changes
                    if (skuMaster.SkuName != dto.SkuName)
                    {
                        Console.WriteLine($"Updating SkuName for SKU {dto.SkuKey}: '{skuMaster.SkuName}' -> '{dto.SkuName}'");
                        skuMaster.SkuName = dto.SkuName;
                    }
                    else
                    {
                        Console.WriteLine($"SkuName unchanged for SKU {dto.SkuKey}: '{skuMaster.SkuName}'");
                    }
                }

                // Handle deletion by fileName (preferred method)
                if (dto.DeleteImageFileNames?.Any() == true)
                {
                    foreach (var fileName in dto.DeleteImageFileNames)
                    {
                        var imageToDelete = await _context.SkuMasterImages
                            .FirstOrDefaultAsync(img => img.MasterId == dto.SkuKey && img.ImageName.Contains(fileName));

                        if (imageToDelete != null)
                        {
                            // Delete physical file
                            var imagePath = Path.Combine(_environment.WebRootPath ?? _environment.ContentRootPath, "images", "skumasters");
                            var fullPath = Path.Combine(imagePath, fileName);
                            await _fileService.DeleteFileAsync(fullPath);

                            // Delete from database
                            _context.SkuMasterImages.Remove(imageToDelete);
                            response.DeletedImageFileNames.Add(fileName);
                        }
                        else
                        {
                            response.Warnings.Add($"Image with fileName '{fileName}' not found or doesn't belong to this SkuMaster");
                        }
                    }
                }

                // Handle deletion by ID (backward compatibility)
                if (dto.DeleteImageIds?.Any() == true)
                {
                    foreach (var imageId in dto.DeleteImageIds)
                    {
                        var imageToDelete = await _context.SkuMasterImages.FindAsync(imageId);
                        if (imageToDelete != null && imageToDelete.MasterId == dto.SkuKey)
                        {
                            // Delete physical file
                            var imagePath = Path.Combine(_environment.WebRootPath ?? _environment.ContentRootPath, "images", "skumasters");
                            var fileName = Path.GetFileName(imageToDelete.ImageName);
                            var fullPath = Path.Combine(imagePath, fileName);
                            await _fileService.DeleteFileAsync(fullPath);

                            // Delete from database
                            _context.SkuMasterImages.Remove(imageToDelete);
                            response.DeletedImageIds.Add(imageId);
                        }
                        else
                        {
                            response.Warnings.Add($"Image with ID {imageId} not found or doesn't belong to this SkuMaster");
                        }
                    }
                }

                if (dto.NewImages?.Any() == true)
                {
                    // Check total image count after deletion but before adding new ones
                    var currentImageCount = await _context.SkuMasterImages
                        .CountAsync(img => img.MasterId == dto.SkuKey);

                    var deletedCount = (dto.DeleteImageIds?.Count ?? 0) + (dto.DeleteImageFileNames?.Count ?? 0);
                    var remainingImages = currentImageCount - deletedCount;
                    var newImagesCount = dto.NewImages.Count;
                    var totalAfterUpload = remainingImages + newImagesCount;

                    if (totalAfterUpload > 7)
                    {
                        response.Success = false;
                        response.Message = $"Total images would exceed limit. Current: {remainingImages}, Adding: {newImagesCount}, Limit: 7";
                        return BadRequest(response);
                    }

                    var imagesFolder = Path.Combine(_environment.WebRootPath ?? _environment.ContentRootPath, "images", "skumasters");
                    _fileService.EnsureDirectoryExists(imagesFolder);

                    foreach (var image in dto.NewImages)
                    {
                        try
                        {
                            if (image != null && image.Length > 0)
                            {
                                var fileName = await _fileService.SaveFileAsync(image, imagesFolder);
                                var relativePath = $"/images/skumasters/{fileName}";

                                var skuMasterImage = new SkuMasterImage
                                {
                                    MasterId = dto.SkuKey,
                                    ImageName = relativePath
                                };

                                _context.SkuMasterImages.Add(skuMasterImage);
                                await _context.SaveChangesAsync();

                                response.UploadedImages.Add(new SkuMasterImageDto
                                {
                                    Id = skuMasterImage.Id,
                                    MasterId = skuMasterImage.MasterId,
                                    ImageName = skuMasterImage.ImageName,
                                    ImagePath = relativePath,
                                    CreatedDate = DateTime.Now
                                });
                            }
                        }
                        catch (Exception ex)
                        {
                            response.Errors.Add($"Error uploading {image.FileName}: {ex.Message}");
                        }
                    }
                }

                if (dto.Width.HasValue || dto.Length.HasValue || dto.Height.HasValue || dto.Weight.HasValue)
                {
                    var existingSizeDetail = await _context.SkuSizeDetails
                        .FirstOrDefaultAsync(s => s.MasterId == dto.SkuKey);

                    if (existingSizeDetail != null)
                    {
                        // Update existing size detail
                        if (dto.Width.HasValue) existingSizeDetail.Width = dto.Width;
                        if (dto.Length.HasValue) existingSizeDetail.Length = dto.Length;
                        if (dto.Height.HasValue) existingSizeDetail.Height = dto.Height;
                        if (dto.Weight.HasValue) existingSizeDetail.Weight = dto.Weight;
                        existingSizeDetail.DateTimeUpdate = DateTime.Now;

                        _context.Entry(existingSizeDetail).State = EntityState.Modified;
                    }
                    else
                    {
                        existingSizeDetail = new SkuSizeDetail
                        {
                            MasterId = dto.SkuKey,
                            Width = dto.Width,
                            Length = dto.Length,
                            Height = dto.Height,
                            Weight = dto.Weight,
                            DateTimeUpdate = DateTime.Now
                        };
                        _context.SkuSizeDetails.Add(existingSizeDetail);
                    }

                    response.UpdatedSizeDetail = new SkuSizeDetailDto
                    {
                        Id = existingSizeDetail.Id,
                        MasterId = existingSizeDetail.MasterId,
                        Width = existingSizeDetail.Width,
                        Length = existingSizeDetail.Length,
                        Height = existingSizeDetail.Height,
                        Weight = existingSizeDetail.Weight,
                        DateTimeUpdate = existingSizeDetail.DateTimeUpdate
                    };
                }

                // Save all changes
                var saveResult = await _context.SaveChangesAsync();
                Console.WriteLine($"SaveChanges result: {saveResult} changes saved for SKU {dto.SkuKey}");

                // Clear change tracker to ensure fresh data on next query
                _context.ChangeTracker.Clear();

                response.Success = true;
                response.Message = "SkuMaster updated successfully";
                response.UpdatedSkuName = skuMaster.SkuName;

                return Ok(response);
            }
            catch (Exception ex)
            {
                response.Success = false;
                response.Message = "An error occurred during update";
                response.Errors.Add(ex.Message);
                return StatusCode(500, response);
            }
        }
    }
}