namespace SkuMasterAPI.Application.Services
{
    public interface IUrlHelperService
    {
        string GetImageUrl(string imagePath);
        string GetBaseUrl();
        List<string> GetImageUrls(IEnumerable<string> imagePaths);
    }
}

