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
                // Remove "(DENR)" from SkuName if present
                item.SkuName = RemoveDenrTag(item.SkuName);
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
            // Get SkuMaster with images
            var sku = await _context.SkuMasters
                .Include(s => s.SkuMasterImages)
                .FirstOrDefaultAsync(s => s.SkuKey == key);

            if (sku == null) return null;

            // Get size details with a separate query to avoid caching issues
            var sizeDetail = await _context.SkuSizeDetails
                .AsNoTracking() // Don't track this query to get fresh data
                .FirstOrDefaultAsync(s => s.MasterId == key);

            Console.WriteLine($"GetDetailByKeyAsync for SKU {key}: Found size detail = {sizeDetail != null}");

            return new SimpleSkuMasterDetailDto
            {
                SkuKey = sku.SkuKey,
                SkuName = RemoveDenrTag(sku.SkuName), // Remove "(DENR)" if present
                ImageUrls = _urlHelperService.GetImageUrls(sku.SkuMasterImages.Select(img => img.ImageName)),
                Width = sizeDetail?.Width,
                Length = sizeDetail?.Length,
                Height = sizeDetail?.Height,
                Weight = sizeDetail?.Weight
            };
        }

        public async Task<bool> UpdateBasicInfoAsync(int key, UpdateSkuMasterBasicDto dto)
        {
            var sku = await _context.SkuMasters.FindAsync(key);
            if (sku == null) return false;

            if (!string.IsNullOrEmpty(dto.SkuName))
            {
                sku.SkuName = dto.SkuName;
            }

            if (dto.SkuPrice.HasValue)
            {
                sku.SkuPrice = dto.SkuPrice.Value;
            }

            await _context.SaveChangesAsync();

            _context.ChangeTracker.Clear();

            return true;
        }

        public async Task<List<string>> GetDatabaseTablesAsync()
        {
            var tables = new List<string>();

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

        public async Task<List<SkuMaster>> SearchByNameAsync(string name)
        {
            return await _context.SkuMasters
                .Where(s => s.SkuName.Contains(name))
                .OrderBy(s => s.SkuName)
                .ToListAsync();
        }

        /// <summary>
        /// Remove "(DENR)" tag from product name
        /// </summary>
        private string RemoveDenrTag(string skuName)
        {
            if (string.IsNullOrEmpty(skuName))
                return skuName;

            // Remove "(DENR)" with various formats
            return skuName
                .Replace("(DENR)", "", StringComparison.OrdinalIgnoreCase)
                .Replace("( DENR )", "", StringComparison.OrdinalIgnoreCase)
                .Replace("(DENR )", "", StringComparison.OrdinalIgnoreCase)
                .Replace("( DENR)", "", StringComparison.OrdinalIgnoreCase)
                .Replace("[DENR]", "", StringComparison.OrdinalIgnoreCase)
                .Trim(); // Remove leading/trailing spaces
        }
    }
}