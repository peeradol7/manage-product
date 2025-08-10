using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace SkuMasterAPI.Models
{
    [Table("SKUMASTERIMAGE")]
    public class SkuMasterImage
    {
        [Key]
        [Column("ID")]
        public int Id { get; set; }

        [Required]
        [Column("MASTER_ID")]
        public int MasterId { get; set; }

        [Required]
        [Column("IMAGE_NAME")]
        [StringLength(255)]
        public string ImageName { get; set; } = string.Empty;

        // Navigation property
        [ForeignKey("MasterId")]
        public virtual SkuMaster SkuMaster { get; set; } = null!;
    }
}
