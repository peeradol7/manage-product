using SkuMasterAPI.Application.DTOs;

namespace SkuMasterAPI.Application.Services
{
    public interface ISkuMasterService
    {
        Task<PaginationResponse<SimpleSkuMasterListDto>> GetPagedListAsync(PaginationRequest request);
        Task<SimpleSkuMasterDetailDto?> GetDetailByKeyAsync(int key);
        Task<bool> UpdateBasicInfoAsync(int key, UpdateSkuMasterBasicDto dto);
    }
}
