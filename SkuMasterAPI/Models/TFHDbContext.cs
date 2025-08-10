using Microsoft.EntityFrameworkCore;

namespace SkuMasterAPI.Models
{
    public class TFHDbContext : DbContext
    {
        public TFHDbContext(DbContextOptions<TFHDbContext> options) : base(options)
        {
        }

        public DbSet<SkuMaster> SkuMasters { get; set; }
        public DbSet<SkuMasterImage> SkuMasterImages { get; set; }
        public DbSet<SkuSizeDetail> SkuSizeDetails { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure SkuMaster entity
            modelBuilder.Entity<SkuMaster>(entity =>
            {
                entity.HasKey(e => e.SkuKey);
                entity.HasIndex(e => e.SkuCode).IsUnique();
                entity.HasIndex(e => e.SkuBarcode);

                entity.Property(e => e.SkuCode)
                    .IsRequired()
                    .HasMaxLength(24);

                entity.Property(e => e.SkuName)
                    .IsRequired()
                    .HasMaxLength(60);

                entity.Property(e => e.SkuEName)
                    .HasMaxLength(60);

                entity.Property(e => e.SkuBarcode)
                    .HasMaxLength(24);

                entity.Property(e => e.SkuEnable)
                    .IsRequired()
                    .HasMaxLength(1);

                entity.Property(e => e.SkuPEnable)
                    .IsRequired()
                    .HasMaxLength(1);

                entity.Property(e => e.SkuMsg1)
                    .HasMaxLength(60);

                entity.Property(e => e.SkuMsg2)
                    .HasMaxLength(60);

                entity.Property(e => e.SkuMsg3)
                    .HasMaxLength(60);

                entity.Property(e => e.SkuSpec)
                    .HasMaxLength(7000);

                entity.Property(e => e.SkuUsage)
                    .HasMaxLength(7000);

                entity.Property(e => e.SkuRemark)
                    .HasMaxLength(255);

                entity.Property(e => e.SkuAlertMsg)
                    .HasMaxLength(255);

                entity.Property(e => e.SkuEqFactor)
                    .HasMaxLength(20);

                entity.Property(e => e.SkuEqName)
                    .HasMaxLength(60);

                entity.Property(e => e.SkuLastupd)
                    .HasMaxLength(17);

                // Configure money type columns
                entity.Property(e => e.SkuVat).HasColumnType("money");
                entity.Property(e => e.SkuWhRate).HasColumnType("money");
                entity.Property(e => e.SkuMinQty).HasColumnType("money");
                entity.Property(e => e.SkuMaxQty).HasColumnType("money");
                entity.Property(e => e.SkuMinOrder).HasColumnType("money");
                entity.Property(e => e.SkuMaxOrder).HasColumnType("money");
                entity.Property(e => e.SkuLeadTime).HasColumnType("money");
                entity.Property(e => e.SkuSatisfy).HasColumnType("money");
                entity.Property(e => e.SkuSafty).HasColumnType("money");
                entity.Property(e => e.SkuEoqA).HasColumnType("money");
                entity.Property(e => e.SkuEoqP).HasColumnType("money");
                entity.Property(e => e.SkuEoqC).HasColumnType("money");
                entity.Property(e => e.SkuEoqNo).HasColumnType("money");
                entity.Property(e => e.SkuLastRqty).HasColumnType("money");
                entity.Property(e => e.SkuUdf1).HasColumnType("money");
                entity.Property(e => e.SkuUdf2).HasColumnType("money");
                entity.Property(e => e.SkuUdf3).HasColumnType("money");
                entity.Property(e => e.SkuUdf4).HasColumnType("money");
                entity.Property(e => e.SkuUdf5).HasColumnType("money");
                entity.Property(e => e.SkuUdf6).HasColumnType("money");
            });

            // Configure SkuMasterImage entity
            modelBuilder.Entity<SkuMasterImage>(entity =>
            {
                entity.HasKey(e => e.Id);

                entity.Property(e => e.ImageName)
                    .IsRequired()
                    .HasMaxLength(255);

                // Configure 1:n relationship between SkuMaster and SkuMasterImage
                entity.HasOne(e => e.SkuMaster)
                    .WithMany(s => s.SkuMasterImages)
                    .HasForeignKey(e => e.MasterId)
                    .HasPrincipalKey(s => s.SkuKey)
                    .OnDelete(DeleteBehavior.Cascade);

                // Add index on MasterId for better performance
                entity.HasIndex(e => e.MasterId);
            });
        }
    }
}
