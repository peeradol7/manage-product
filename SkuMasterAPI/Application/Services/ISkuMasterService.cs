using SkuMasterAPI.Application.DTOs;
using SkuMasterAPI.Models;

namespace SkuMasterAPI.Application.Services
{
    public interface ISkuMasterService
    {
        Task<PaginationResponse<SimpleSkuMasterListDto>> GetPagedListAsync(PaginationRequest request);
        Task<SimpleSkuMasterDetailDto?> GetDetailByKeyAsync(int key);
        Task<bool> UpdateBasicInfoAsync(int key, UpdateSkuMasterBasicDto dto);
        Task<List<string>> GetDatabaseTablesAsync();
        Task<object> GetSampleDataAsync();
        Task<List<SkuMaster>> SearchByNameAsync(string name);
    }
}
