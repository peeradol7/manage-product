using Microsoft.AspNetCore.Mvc;
using SkuMasterAPI.Application.DTOs;
using SkuMasterAPI.Application.Services;
using SkuMasterAPI.Models;

namespace SkuMasterAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class SkuMasterController : ControllerBase
    {
        private readonly ISkuMasterService _skuMasterService;

        public SkuMasterController(ISkuMasterService skuMasterService)
        {
            _skuMasterService = skuMasterService;
        }
        /// <summary>
        /// Get paged SkuMasters list with images
        /// </summary>
        [HttpGet("list")]
        public async Task<ActionResult<PaginationResponse<SimpleSkuMasterListDto>>> GetPagedSkuMasters(
            [FromQuery] int page = 1,
            [FromQuery] int pageSize = 20)
        {
            var request = new PaginationRequest { Page = page, PageSize = pageSize };
            var result = await _skuMasterService.GetPagedListAsync(request);
            return Ok(result);
        }

        /// <summary>
        /// Get SkuMaster detail with name, images and size details
        /// </summary>
        [HttpGet("{key}/detail")]
        public async Task<ActionResult<SimpleSkuMasterDetailDto>> GetSkuMasterDetail(int key)
        {
            var sku = await _skuMasterService.GetDetailByKeyAsync(key);

            if (sku == null)
            {
                return NotFound();
            }

            return Ok(sku);
        }
    }
}
