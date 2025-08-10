namespace SkuMasterAPI.Application.Services
{
    public class FileService : IFileService
    {
        private readonly string[] _allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp" };
        private readonly long _maxFileSize = 10 * 1024 * 1024; // 10MB

        public async Task<string> SaveFileAsync(IFormFile file, string folderPath)
        {
            if (file == null || file.Length == 0)
                throw new ArgumentException("File is null or empty");

            if (!IsValidImageFile(file))
                throw new ArgumentException("Invalid file type. Only image files are allowed.");

            if (file.Length > _maxFileSize)
                throw new ArgumentException($"File size exceeds maximum limit of {_maxFileSize / (1024 * 1024)}MB");

            EnsureDirectoryExists(folderPath);

            var fileExtension = GetFileExtension(file.FileName);
            var newFileName = $"{Guid.NewGuid()}{fileExtension}";
            var filePath = Path.Combine(folderPath, newFileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await file.CopyToAsync(stream);
            }

            return newFileName;
        }

        public async Task<List<string>> SaveFilesAsync(List<IFormFile> files, string folderPath)
        {
            var savedFiles = new List<string>();

            foreach (var file in files)
            {
                if (file != null && file.Length > 0)
                {
                    try
                    {
                        var fileName = await SaveFileAsync(file, folderPath);
                        savedFiles.Add(fileName);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error saving file {file.FileName}: {ex.Message}");
                        throw;
                    }
                }
            }

            return savedFiles;
        }

        public async Task<bool> DeleteFileAsync(string filePath)
        {
            try
            {
                if (File.Exists(filePath))
                {
                    await Task.Run(() => File.Delete(filePath));
                    return true;
                }
                return false;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting file {filePath}: {ex.Message}");
                return false;
            }
        }

        public string GetFileExtension(string fileName)
        {
            return Path.GetExtension(fileName).ToLowerInvariant();
        }

        public bool IsValidImageFile(IFormFile file)
        {
            if (file == null || file.Length == 0)
                return false;

            var extension = GetFileExtension(file.FileName);

            if (!_allowedExtensions.Contains(extension))
                return false;

            // Check MIME type
            var allowedMimeTypes = new[]
            {
                "image/jpeg", "image/jpg", "image/png",
                "image/gif", "image/bmp", "image/webp"
            };

            return allowedMimeTypes.Contains(file.ContentType.ToLowerInvariant());
        }

        public void EnsureDirectoryExists(string folderPath)
        {
            if (!Directory.Exists(folderPath))
            {
                Directory.CreateDirectory(folderPath);
            }
        }
    }
}
