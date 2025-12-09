IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_ProductDefaultQuantity]') and NAME='MinQuantity')
BEGIN
	ALTER TABLE [FNS_ProductDefaultQuantity]
	ADD [MinQuantity] int NOT NULL CONSTRAINT DF_FNS_ProductDefaultQuantity_MinQuantity DEFAULT 0
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_ProductDefaultQuantity]') and NAME='MaxQuantity')
BEGIN
	ALTER TABLE [FNS_ProductDefaultQuantity]
	ADD [MaxQuantity] int NOT NULL CONSTRAINT DF_FNS_ProductDefaultQuantity_MaxQuantity DEFAULT 999999
END
GO
