namespace SkuMasterAPI.Application.DTOs
{
    public class PaginationRequest
    {
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 20;

        public int GetSkip() => (Page - 1) * PageSize;
        public int GetTake() => PageSize;
    }

    public class PaginationResponse<T>
    {
        public List<T> Data { get; set; } = new List<T>();
        public int CurrentPage { get; set; }
        public int PageSize { get; set; }
        public int TotalCount { get; set; }
        public int TotalPages { get; set; }
        public bool HasPreviousPage { get; set; }
        public bool HasNextPage { get; set; }
    }

    public class SkuMasterListDto
    {
        public int SkuKey { get; set; }
        public string SkuCode { get; set; } = string.Empty;
        public string SkuName { get; set; } = string.Empty;
        public string? SkuEName { get; set; }
        public string SkuEnable { get; set; } = string.Empty;
        public List<string> ImageUrls { get; set; } = new List<string>();
    }

    public class SkuMasterDetailDto
    {
        public int SkuKey { get; set; }
        public string SkuCode { get; set; } = string.Empty;
        public string SkuName { get; set; } = string.Empty;
        public string? SkuEName { get; set; }
        public string? SkuBarcode { get; set; }
        public string SkuEnable { get; set; } = string.Empty;
        public string SkuPEnable { get; set; } = string.Empty;
        public string? SkuMsg1 { get; set; }
        public string? SkuMsg2 { get; set; }
        public string? SkuMsg3 { get; set; }
        public string? SkuSpec { get; set; }
        public string? SkuUsage { get; set; }
        public string? SkuRemark { get; set; }
        public List<SkuMasterImageDetailDto> Images { get; set; } = new List<SkuMasterImageDetailDto>();
        public List<SkuSizeDetailDto> SizeDetails { get; set; } = new List<SkuSizeDetailDto>();
    }

    public class SkuMasterImageDetailDto
    {
        public int Id { get; set; }
        public string ImageName { get; set; } = string.Empty;
        public string ImageUrl { get; set; } = string.Empty;
    }
}
