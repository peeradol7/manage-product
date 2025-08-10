namespace SkuMasterAPI.Application.Services
{
    public class UrlHelperService : IUrlHelperService
    {
        private readonly IHttpContextAccessor _httpContextAccessor;

        public UrlHelperService(IHttpContextAccessor httpContextAccessor)
        {
            _httpContextAccessor = httpContextAccessor;
        }

        public string GetBaseUrl()
        {
            var request = _httpContextAccessor.HttpContext?.Request;
            if (request == null)
                return "https://localhost:7071"; // Default fallback

            var scheme = request.Scheme;
            var host = request.Host.Value;

            return $"{scheme}://{host}";
        }

        public string GetImageUrl(string imagePath)
        {
            if (string.IsNullOrEmpty(imagePath))
                return string.Empty;

            // If imagePath already starts with http, return as is
            if (imagePath.StartsWith("http://") || imagePath.StartsWith("https://"))
                return imagePath;

            // If imagePath doesn't start with /, add it
            if (!imagePath.StartsWith("/"))
                imagePath = "/" + imagePath;

            var baseUrl = GetBaseUrl();
            return $"{baseUrl}{imagePath}";
        }

        public List<string> GetImageUrls(IEnumerable<string> imagePaths)
        {
            return imagePaths.Where(path => !string.IsNullOrEmpty(path))
                           .Select(GetImageUrl)
                           .ToList();
        }
    }
}

