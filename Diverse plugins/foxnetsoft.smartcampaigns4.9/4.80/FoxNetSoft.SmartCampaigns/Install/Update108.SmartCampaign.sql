--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='StoreId')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [StoreId] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_StoreId DEFAULT 0
END
GO
update FNS_SmartCampaign
set StoreId=S.Id
from FNS_SmartCampaign F,(select top 1 Id from Store S order by S.DisplayOrder) S
where F.StoreId=0
Go
IF  EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF_FNS_SmartCampaign_StoreId]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[FNS_SmartCampaign] DROP CONSTRAINT [DF_FNS_SmartCampaign_StoreId]
END
GO
alter table FNS_SmartCampaign alter column StoreId int not null
Go
update FNS_SmartCampaign
set StoreId=S.Id
from FNS_SmartCampaign F,(select top 1 Id from Store S order by S.DisplayOrder) S
where F.StoreId=0
Go
--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='EmailAccountId')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [EmailAccountId] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_EmailAccountId DEFAULT 0
END
GO
