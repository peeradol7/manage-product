using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SkuMasterAPI.Models
{
    [Table("SKUSIZEDETAIL")]
    public class SkuSizeDetail
    {
        [Key]
        [Column("ID")]
        public int Id { get; set; }

        [Required]
        [Column("MASTER_ID")]
        public int MasterId { get; set; }

        [Column("WIDTH")]
        public decimal? Width { get; set; }

        [Column("LENGTH")]
        public decimal? Length { get; set; }

        [Column("HEIGHT")]
        public decimal? Height { get; set; }

        [Column("WEIGHT")]
        public decimal? Weight { get; set; }

        [Column("DATETIME_UPDATE")]
        public DateTime DateTimeUpdate { get; set; } = DateTime.Now;

        [ForeignKey("MasterId")]
        public virtual SkuMaster? SkuMaster { get; set; }
    }
}
