using Microsoft.AspNetCore.Mvc;
using SkuMasterAPI.Application.DTOs;
using SkuMasterAPI.Application.Services;
using SkuMasterAPI.Models;

namespace SkuMasterAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json; charset=utf-8")]
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
            [FromQuery] int pageSize = 20,
            [FromQuery] string? searchTerm = null,
            [FromQuery] bool filterNoImages = false)
        {
            try
            {
                var request = new PaginationRequest
                {
                    Page = page,
                    PageSize = pageSize,
                    SearchTerm = searchTerm,
                    FilterNoImages = filterNoImages
                };
                var result = await _skuMasterService.GetPagedListAsync(request);
                return Ok(result);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, searchTerm = searchTerm });
            }
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

        /// <summary>
        /// Update SkuMaster basic info (Name, Price, Discontinued status)
        /// </summary>
        [HttpPut("{key}/update-basic")]
        public async Task<ActionResult> UpdateSkuMasterBasic(int key, [FromBody] UpdateSkuMasterBasicDto dto)
        {
            var result = await _skuMasterService.UpdateBasicInfoAsync(key, dto);
            if (!result)
            {
                return NotFound();
            }
            return Ok(new { message = "Updated successfully" });
        }
    }
}
