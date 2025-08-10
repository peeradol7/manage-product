USE [TFH]
GO
CREATE TABLE [dbo].[SKUMASTER](
    [SKU_CODE] [nvarchar](30) NOT NULL PRIMARY KEY,
    [SKU_THAIDESC] [nvarchar](255) NULL,
    [SKU_ENGDESC] [nvarchar](255) NULL,
    [SKU_ENABLE] [char](1) NULL,
    [SKU_CREATED] [datetime] NULL,
    [SKU_UPDATED] [datetime] NULL
)
GO
