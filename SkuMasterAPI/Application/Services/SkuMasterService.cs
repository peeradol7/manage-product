using Microsoft.EntityFrameworkCore;
using SkuMasterAPI.Application.DTOs;
using SkuMasterAPI.Models;

namespace SkuMasterAPI.Application.Services
{
    public class SkuMasterService : ISkuMasterService
    {
        private readonly TFHDbContext _context;
        private readonly IUrlHelperService _urlHelperService;
        private readonly IStringCleaningService _stringCleaningService;

        public SkuMasterService(TFHDbContext context, IUrlHelperService urlHelperService, IStringCleaningService stringCleaningService)
        {
            _context = context;
            _urlHelperService = urlHelperService;
            _stringCleaningService = stringCleaningService;
        }

        public async Task<PaginationResponse<SimpleSkuMasterListDto>> GetPagedListAsync(PaginationRequest request)
        {
            var query = _context.SkuMasters
                .Include(s => s.SkuMasterImages)
                .AsQueryable();

            if (!string.IsNullOrEmpty(request.SearchTerm))
            {
                var cleanedSearchTerm = _stringCleaningService.CleanSearchTerm(request.SearchTerm);

                if (!string.IsNullOrEmpty(cleanedSearchTerm))
                {
                    var originalWords = request.SearchTerm.Split(' ', StringSplitOptions.RemoveEmptyEntries);

                    var cleanedWords = originalWords
                        .Select(word => _stringCleaningService.CleanSearchTerm(word))
                        .Where(word => !string.IsNullOrEmpty(word))
                        .ToArray();

                    foreach (var word in cleanedWords)
                    {
                        query = query.Where(s =>
                            EF.Functions.Like(s.SkuName.Replace(" ", ""), $"%{word}%"));
                    }
                }
            }

            if (request.FilterNoImages)
            {
                query = query.Where(s => !s.SkuMasterImages.Any());
            }

            query = query.OrderBy(s => s.SkuName);

            var totalCount = await query.CountAsync();

            var items = await query
                .Skip(request.GetSkip())
                .Take(request.GetTake())
                .Select(s => new SimpleSkuMasterListDto
                {
                    SkuKey = s.SkuKey,
                    SkuCode = s.SkuCode,
                    SkuName = s.SkuName,
                    ImageUrls = s.SkuMasterImages.Select(img => img.ImageName).ToList(),
                    SkuPrice = s.SkuPrice
                })
                .ToListAsync();

            foreach (var item in items)
            {
                item.ImageUrls = _urlHelperService.GetImageUrls(item.ImageUrls);
            }

            var totalPages = (int)Math.Ceiling((double)totalCount / request.PageSize);

            return new PaginationResponse<SimpleSkuMasterListDto>
            {
                Data = items,
                CurrentPage = request.Page,
                PageSize = request.PageSize,
                TotalCount = totalCount,
                TotalPages = totalPages,
                HasPreviousPage = request.Page > 1,
                HasNextPage = request.Page < totalPages
            };
        }

        public async Task<SimpleSkuMasterDetailDto?> GetDetailByKeyAsync(int key)
        {
            // Use a single optimized query to get all data at once
            var result = await _context.SkuMasters
                .Where(s => s.SkuKey == key)
                .Select(s => new
                {
                    SkuMaster = s,
                    Images = s.SkuMasterImages.Select(img => img.ImageName).ToList(),
                    SizeDetail = s.SkuSizeDetails.FirstOrDefault()
                })
                .FirstOrDefaultAsync();

            if (result == null) return null;

            return new SimpleSkuMasterDetailDto
            {
                SkuKey = result.SkuMaster.SkuKey,
                SkuName = result.SkuMaster.SkuName,
                ImageUrls = _urlHelperService.GetImageUrls(result.Images),
                Width = result.SizeDetail?.Width,
                Length = result.SizeDetail?.Length,
                Height = result.SizeDetail?.Height,
                Weight = result.SizeDetail?.Weight
            };
        }

        public async Task<bool> UpdateBasicInfoAsync(int key, UpdateSkuMasterBasicDto dto)
        {
            var sku = await _context.SkuMasters.FindAsync(key);
            if (sku == null) return false;

            if (!string.IsNullOrEmpty(dto.SkuName))
            {
                // Clean the SkuName: remove spaces and keep only letters
                var cleanedSkuName = _stringCleaningService.CleanText(dto.SkuName);
                sku.SkuName = !string.IsNullOrEmpty(cleanedSkuName) ? cleanedSkuName : dto.SkuName;
            }

            if (dto.SkuPrice.HasValue)
            {
                sku.SkuPrice = dto.SkuPrice.Value;
            }

            await _context.SaveChangesAsync();

            // Clear change tracker to ensure fresh data on next query
            _context.ChangeTracker.Clear();

            return true;
        }

        public async Task<List<string>> GetDatabaseTablesAsync()
        {
            var tables = new List<string>();

            // Get table names from sys.tables
            var tableNames = await _context.Database.SqlQueryRaw<string>(
                "SELECT name FROM sys.tables ORDER BY name").ToListAsync();

            tables.AddRange(tableNames);

            return tables;
        }

        public async Task<object> GetSampleDataAsync()
        {
            // Get sample data from SKUMASTER table
            var sampleSku = await _context.SkuMasters
                .Include(s => s.SkuMasterImages)
                .FirstOrDefaultAsync();

            if (sampleSku == null)
            {
                return new { message = "No data found in SKUMASTER table" };
            }

            // Query SkuSizeDetails separately to ensure fresh data
            var sizeDetail = await _context.SkuSizeDetails
                .FirstOrDefaultAsync(s => s.MasterId == sampleSku.SkuKey);

            return new
            {
                skuKey = sampleSku.SkuKey,
                skuName = sampleSku.SkuName,
                skuCode = sampleSku.SkuCode,
                skuPrice = sampleSku.SkuPrice,
                imageCount = sampleSku.SkuMasterImages.Count,
                hasSizeDetail = sizeDetail != null,
                sizeDetail = sizeDetail != null ? new
                {
                    width = sizeDetail.Width,
                    length = sizeDetail.Length,
                    height = sizeDetail.Height,
                    weight = sizeDetail.Weight
                } : null
            };
        }
    }
}