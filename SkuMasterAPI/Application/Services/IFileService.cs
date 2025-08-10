namespace SkuMasterAPI.Application.Services
{
    public interface IFileService
    {
        Task<string> SaveFileAsync(IFormFile file, string folderPath);
        Task<List<string>> SaveFilesAsync(List<IFormFile> files, string folderPath, int maxFileCount = 7);
        Task<bool> DeleteFileAsync(string filePath);
        string GetFileExtension(string fileName);
        bool IsValidImageFile(IFormFile file);
        void EnsureDirectoryExists(string folderPath);
    }
}
