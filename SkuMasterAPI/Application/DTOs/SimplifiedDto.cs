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

        // Image IDs to delete
        public List<int>? DeleteImageIds { get; set; } = new List<int>();

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

        // Size update result
        public SkuSizeDetailDto? UpdatedSizeDetail { get; set; }

        public List<string> Errors { get; set; } = new List<string>();
        public List<string> Warnings { get; set; } = new List<string>();
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
