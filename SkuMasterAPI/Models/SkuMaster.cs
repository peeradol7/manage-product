using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SkuMasterAPI.Models
{
    [Table("SKUMASTER")]
    public class SkuMaster
    {
        [Key]
        [Column("SKU_KEY")]
        public int SkuKey { get; set; }

        [Required]
        [Column("SKU_CODE")]
        [StringLength(24)]
        public string SkuCode { get; set; } = string.Empty;

        [Required]
        [Column("SKU_NAME")]
        [StringLength(60)]
        public string SkuName { get; set; } = string.Empty;

        [Column("SKU_E_NAME")]
        [StringLength(60)]
        public string? SkuEName { get; set; }

        [Column("SKU_BARCODE")]
        [StringLength(24)]
        public string? SkuBarcode { get; set; }

        [Column("SKU_BRN")]
        public int SkuBrn { get; set; }

        [Column("SKU_ICCAT")]
        public int SkuIccat { get; set; }

        [Column("SKU_S_UTQ")]
        public int SkuSUtq { get; set; }

        [Column("SKU_T_UTQ")]
        public int SkuTUtq { get; set; }

        [Column("SKU_K_UTQ")]
        public int SkuKUtq { get; set; }

        [Column("SKU_VAT_TY")]
        public short SkuVatTy { get; set; }

        [Column("SKU_VAT", TypeName = "money")]
        public decimal SkuVat { get; set; }

        [Column("SKU_COST_TY")]
        public short SkuCostTy { get; set; }

        [Column("SKU_STD_COST")]
        public double SkuStdCost { get; set; }

        [Column("SKU_STOCK")]
        public short SkuStock { get; set; }

        [Column("SKU_SKUALT")]
        public int SkuSkualt { get; set; }

        [Column("SKU_WH_TY")]
        public short SkuWhTy { get; set; }

        [Column("SKU_WH_RATE", TypeName = "money")]
        public decimal SkuWhRate { get; set; }

        [Column("SKU_MSG_1")]
        [StringLength(60)]
        public string? SkuMsg1 { get; set; }

        [Column("SKU_MSG_2")]
        [StringLength(60)]
        public string? SkuMsg2 { get; set; }

        [Column("SKU_MSG_3")]
        [StringLength(60)]
        public string? SkuMsg3 { get; set; }

        [Column("SKU_MIXCOLOR")]
        public int SkuMixcolor { get; set; }

        [Column("SKU_ICCOLOR")]
        public int SkuIccolor { get; set; }

        [Column("SKU_ICSIZE")]
        public int SkuIcsize { get; set; }

        [Column("SKU_ICDEPT")]
        public int SkuIcdept { get; set; }

        [Column("SKU_ICGL")]
        public int SkuIcgl { get; set; }

        [Column("SKU_ICPRT")]
        public int SkuIcprt { get; set; }

        [Column("SKU_WL")]
        public int SkuWl { get; set; }

        [Column("SKU_ENABLE")]
        [StringLength(1)]
        public string SkuEnable { get; set; } = string.Empty;

        [Column("SKU_P_ENABLE")]
        [StringLength(1)]
        public string SkuPEnable { get; set; } = string.Empty;

        [Column("SKU_MIN_QTY")]
        public decimal SkuMinQty { get; set; }

        [Column("SKU_MAX_QTY")]
        public decimal SkuMaxQty { get; set; }

        [Column("SKU_MIN_ORDER")]
        public decimal SkuMinOrder { get; set; }

        [Column("SKU_MAX_ORDER")]
        public decimal SkuMaxOrder { get; set; }

        [Column("SKU_LEAD_TIME")]
        public decimal SkuLeadTime { get; set; }

        [Column("SKU_SATISFY")]
        public decimal SkuSatisfy { get; set; }

        [Column("SKU_SAFTY")]
        public decimal SkuSafty { get; set; }

        [Column("SKU_FREQUENCY")]
        public int? SkuFrequency { get; set; }

        [Column("SKU_ACCESS")]
        public short SkuAccess { get; set; }

        [Column("SKU_ABC")]
        public int? SkuAbc { get; set; }

        [Column("SKU_EOQ_A")]
        public decimal SkuEoqA { get; set; }

        [Column("SKU_EOQ_P")]
        public decimal SkuEoqP { get; set; }

        [Column("SKU_EOQ_C")]
        public decimal SkuEoqC { get; set; }

        [Column("SKU_EOQ_NO")]
        public decimal SkuEoqNo { get; set; }

        [Column("SKU_SPEC")]
        public string? SkuSpec { get; set; }

        [Column("SKU_USAGE")]
        public string? SkuUsage { get; set; }

        [Column("SKU_REMARK")]
        [StringLength(255)]
        public string? SkuRemark { get; set; }

        [Column("SKU_LAST_O")]
        public DateTime SkuLastO { get; set; }

        [Column("SKU_LAST_R")]
        public DateTime SkuLastR { get; set; }

        [Column("SKU_LAST_RCOST")]
        public double SkuLastRcost { get; set; }

        [Column("SKU_LAST_RQTY")]
        public decimal SkuLastRqty { get; set; }

        [Column("SKU_LAST_COMMIT")]
        public DateTime? SkuLastCommit { get; set; }

        [Column("SKU_SENSITIVITY")]
        public int? SkuSensitivity { get; set; }

        [Column("SKU_SENS_POS")]
        public int? SkuSensPos { get; set; }

        [Column("SKU_LAST_UBCOST")]
        public double SkuLastUbcost { get; set; }

        [Column("SKU_LAST_UCCOST")]
        public double SkuLastUccost { get; set; }

        [Column("SKU_ALERT")]
        public short SkuAlert { get; set; }

        [Column("SKU_ALERT_MSG")]
        [StringLength(255)]
        public string? SkuAlertMsg { get; set; }

        [Column("SKU_PRICE")]
        public int? SkuPrice { get; set; }

        [Column("SKU_EQ_FACTOR")]
        [StringLength(20)]
        public string? SkuEqFactor { get; set; }

        [Column("SKU_EQ_NAME")]
        [StringLength(60)]
        public string? SkuEqName { get; set; }

        [Column("SKU_UDF_1")]
        public decimal SkuUdf1 { get; set; }

        [Column("SKU_UDF_2")]
        public decimal SkuUdf2 { get; set; }

        [Column("SKU_UDF_3")]
        public decimal SkuUdf3 { get; set; }

        [Column("SKU_UDF_4")]
        public decimal SkuUdf4 { get; set; }

        [Column("SKU_UDF_5")]
        public decimal SkuUdf5 { get; set; }

        [Column("SKU_UDF_6")]
        public decimal SkuUdf6 { get; set; }

        [Column("SKU_LASTUPD")]
        [StringLength(17)]
        public string? SkuLastupd { get; set; }


        // Navigation properties
        public virtual ICollection<SkuMasterImage> SkuMasterImages { get; set; } = new List<SkuMasterImage>();
        public virtual ICollection<SkuSizeDetail> SkuSizeDetails { get; set; } = new List<SkuSizeDetail>();
    }
