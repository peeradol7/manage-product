using Microsoft.EntityFrameworkCore;
using SkuMasterAPI.Application.DTOs;
using SkuMasterAPI.Models;

namespace SkuMasterAPI.Application.Services
{
    public class SkuMasterService : ISkuMasterService
    {
        private readonly TFHDbContext _context;
        private readonly IUrlHelperService _urlHelperService;

        public SkuMasterService(TFHDbContext context, IUrlHelperService urlHelperService)
        {
            _context = context;
            _urlHelperService = urlHelperService;
        }

        public async Task<PaginationResponse<SimpleSkuMasterListDto>> GetPagedListAsync(PaginationRequest request)
        {
            var query = _context.SkuMasters
                .Include(s => s.SkuMasterImages)
                .AsQueryable();

            if (!string.IsNullOrEmpty(request.SearchTerm))
            {
                query = query.Where(s => s.SkuCode.Contains(request.SearchTerm) || 
                                       s.SkuName.Contains(request.SearchTerm));
            }

            if (request.FilterNoImages)
            {
                query = query.Where(s => !s.SkuMasterImages.Any());
            }

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
            var sku = await _context.SkuMasters
                .Include(s => s.SkuMasterImages)
                .Include(s => s.SkuSizeDetails)
                .FirstOrDefaultAsync(s => s.SkuKey == key);

            if (sku == null) return null;

            var sizeDetail = sku.SkuSizeDetails.FirstOrDefault();

            return new SimpleSkuMasterDetailDto
            {
                SkuKey = sku.SkuKey,
                SkuName = sku.SkuName,
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
            return true;
        }
    }
}