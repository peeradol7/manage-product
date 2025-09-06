using Microsoft.AspNetCore.Mvc;
using SkuMasterAPI.Application.DTOs;
using SkuMasterAPI.Application.Services;
using SkuMasterAPI.Models;

namespace SkuMasterAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Produces("application/json")]
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
            try
            {
                var sku = await _skuMasterService.GetDetailByKeyAsync(key);

                if (sku == null)
                {
                    return NotFound(new { message = "SkuMaster not found", key = key });
                }

                // Disable caching to ensure fresh data
                Response.Headers["Cache-Control"] = "no-cache, no-store, must-revalidate";
                Response.Headers["Pragma"] = "no-cache";
                Response.Headers["Expires"] = "0";

                return Ok(sku);
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { message = "Internal server error", error = ex.Message });
            }
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

        /// <summary>
        /// Get database tables info
        /// </summary>
        [HttpGet("debug/tables")]
        public async Task<ActionResult> GetDatabaseTables()
        {
            try
            {
                var tables = await _skuMasterService.GetDatabaseTablesAsync();
                return Ok(new { tables = tables });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        /// <summary>
        /// Get sample data from SKUMASTER table
        /// </summary>
        [HttpGet("debug/sample")]
        public async Task<ActionResult> GetSampleData()
        {
            try
            {
                var sample = await _skuMasterService.GetSampleDataAsync();
                return Ok(sample);
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message });
            }
        }

        /// <summary>
        /// Test size details for a specific SKU
        /// </summary>
        [HttpGet("debug/size/{key}")]
        public async Task<ActionResult> TestSizeDetails(int key)
        {
            try
            {
                var detail = await _skuMasterService.GetDetailByKeyAsync(key);
                return Ok(new
                {
                    skuKey = key,
                    found = detail != null,
                    hasSize = detail?.Width != null || detail?.Length != null || detail?.Height != null || detail?.Weight != null,
                    width = detail?.Width,
                    length = detail?.Length,
                    height = detail?.Height,
                    weight = detail?.Weight
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, skuKey = key });
            }
        }

        /// <summary>
        /// Search for SKU by name to find "missing" items
        /// </summary>
        [HttpGet("debug/search")]
        public async Task<ActionResult> SearchSkuByName([FromQuery] string name)
        {
            try
            {
                var results = await _skuMasterService.SearchByNameAsync(name);
                return Ok(new
                {
                    searchTerm = name,
                    count = results.Count,
                    results = results.Select(s => new
                    {
                        skuKey = s.SkuKey,
                        skuName = s.SkuName,
                        skuCode = s.SkuCode
                    })
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new { error = ex.Message, searchTerm = name });
            }
        }
    }
}
