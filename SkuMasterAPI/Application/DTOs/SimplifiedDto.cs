using System.ComponentModel.DataAnnotations;

namespace SkuMasterAPI.Application.DTOs
{
    // Keep only necessary DTOs
    public class SkuMasterImageDto
    {
        public int Id { get; set; }
        public int MasterId { get; set; }
        public string ImageName { get; set; } = string.Empty;
        public string? ImagePath { get; set; }
        public DateTime? CreatedDate { get; set; }
    }

    public class SkuSizeDetailDto
    {
        public int Id { get; set; }
        public int MasterId { get; set; }
        public decimal? Width { get; set; }
        public decimal? Length { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
        public DateTime DateTimeUpdate { get; set; }
    }
    public class UpdateSkuMasterDto
    {
        [Required]
        public int SkuKey { get; set; }

        public string? SkuName { get; set; }

        public List<IFormFile>? NewImages { get; set; } = new List<IFormFile>();

        // Image IDs to delete (deprecated - use DeleteImageFileNames instead)
        public List<int>? DeleteImageIds { get; set; } = new List<int>();

        // Image file names to delete (new preferred method)
        public List<string>? DeleteImageFileNames { get; set; } = new List<string>();

        public decimal? Width { get; set; }
        public decimal? Length { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
    }

    public class UpdateSkuMasterResponseDto
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;

        // Updated name
        public string? UpdatedSkuName { get; set; }

        // Upload results
        public List<SkuMasterImageDto> UploadedImages { get; set; } = new List<SkuMasterImageDto>();
        public List<int> DeletedImageIds { get; set; } = new List<int>();
        public List<string> DeletedImageFileNames { get; set; } = new List<string>();

        // Size update result
        public SkuSizeDetailDto? UpdatedSizeDetail { get; set; }

        public List<string> Errors { get; set; } = new List<string>();
        public List<string> Warnings { get; set; } = new List<string>();

        // Add properties for mobile compatibility (lowercase) - using JsonPropertyName to avoid conflicts
        [System.Text.Json.Serialization.JsonPropertyName("success")]
        public bool success => Success;

        [System.Text.Json.Serialization.JsonPropertyName("message")]
        public string message => Message;

        [System.Text.Json.Serialization.JsonPropertyName("updatedSkuName")]
        public string? updatedSkuName => UpdatedSkuName;

        [System.Text.Json.Serialization.JsonPropertyName("uploadedImageUrls")]
        public List<string> uploadedImageUrls => UploadedImages.Select(img => img.ImagePath ?? img.ImageName).ToList();

        [System.Text.Json.Serialization.JsonPropertyName("deletedImageIds")]
        public List<int> deletedImageIds => DeletedImageIds;

        [System.Text.Json.Serialization.JsonPropertyName("deletedImageFileNames")]
        public List<string> deletedImageFileNames => DeletedImageFileNames;

        [System.Text.Json.Serialization.JsonPropertyName("updatedSizeDetail")]
        public SkuSizeDetailDto? updatedSizeDetail => UpdatedSizeDetail;

        [System.Text.Json.Serialization.JsonPropertyName("warnings")]
        public List<string> warnings => Warnings;
    }

    // Simplified Detail DTO for response
    public class SimpleSkuMasterDetailDto
    {
        public int SkuKey { get; set; }
        public string SkuName { get; set; } = string.Empty;
        public List<string> ImageUrls { get; set; } = new List<string>();
        public decimal? Width { get; set; }
        public decimal? Length { get; set; }
        public decimal? Height { get; set; }
        public decimal? Weight { get; set; }
    }

    // Simplified List DTO
    public class SimpleSkuMasterListDto
    {
        public int SkuKey { get; set; }
        public string SkuCode { get; set; } = string.Empty;
        public string SkuName { get; set; } = string.Empty;
        public List<string> ImageUrls { get; set; } = new List<string>();
        public int? SkuPrice { get; set; }
    }

    // DTO for updating basic info
    public class UpdateSkuMasterBasicDto
    {
        public string? SkuName { get; set; }
        public int? SkuPrice { get; set; }
    }
}
