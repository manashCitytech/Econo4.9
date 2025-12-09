IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaignBlackList') AND type in (N'U'))
BEGIN
	DROP TABLE FNS_SmartCampaignBlackList
END
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaignRequirement]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[FNS_SmartCampaignRequirement](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[SmartCampaignId] [int] NOT NULL,
		[ParentId] [int] NULL,
		[InteractionTypeId] [int] NULL,
		[IsGroup] [bit] NOT NULL,
		[RequirementCategory] [nvarchar](25) NULL,
		[RequirementProperty] [nvarchar](100) NULL,
		[RequirementOperator] [nvarchar](20) NULL,
		[RequirementValue] [nvarchar](400) NULL,
	PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[FNS_SmartCampaignRequirement]  WITH CHECK ADD  CONSTRAINT [SmartCampaignRequirement_ChildRequirements] FOREIGN KEY([ParentId])
	REFERENCES [dbo].[FNS_SmartCampaignRequirement] ([Id])


	ALTER TABLE [dbo].[FNS_SmartCampaignRequirement] CHECK CONSTRAINT [SmartCampaignRequirement_ChildRequirements]


	ALTER TABLE [dbo].[FNS_SmartCampaignRequirement]  WITH CHECK ADD  CONSTRAINT [SmartCampaignRequirement_SmartCampaign] FOREIGN KEY([SmartCampaignId])
	REFERENCES [dbo].[FNS_SmartCampaign] ([Id])
	ON DELETE CASCADE

	ALTER TABLE [dbo].[FNS_SmartCampaignRequirement] CHECK CONSTRAINT [SmartCampaignRequirement_SmartCampaign]
END
GO
--remove column
IF OBJECT_ID('dbo.[DF_FNS_SmartCampaign_NumberOfOrders]', 'D') IS NOT NULL 
begin
    ALTER TABLE [FNS_SmartCampaign] DROP CONSTRAINT DF_FNS_SmartCampaign_NumberOfOrders
end
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='NumberOfOrders')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]	DROP COLUMN [NumberOfOrders]
END
GO

--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='DaysBeforeBirthday')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [DaysBeforeBirthday] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_DaysBeforeBirthday DEFAULT 0
END
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaignReport]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[FNS_SmartCampaignReport](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[SmartCampaignId] [int] NOT NULL,
		[ReportLevelId] [int] NOT NULL,
		[CreatedOnUtc] [datetime2](7) NOT NULL,
		[FullMessage] [nvarchar](1000) NULL,
	 CONSTRAINT [PK_FNS_SmartCampaignReport] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]

	ALTER TABLE [dbo].[FNS_SmartCampaignReport]  WITH CHECK ADD  CONSTRAINT [FK_FNS_SmartCampaignReport_FNS_SmartCampaign_SmartCampaignId] FOREIGN KEY([SmartCampaignId])
	REFERENCES [dbo].[FNS_SmartCampaign] ([Id])
	ON DELETE CASCADE

	ALTER TABLE [dbo].[FNS_SmartCampaignReport] CHECK CONSTRAINT [FK_FNS_SmartCampaignReport_FNS_SmartCampaign_SmartCampaignId]
END
GO
--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='ForExistingOrders')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [ForExistingOrders] bit NOT NULL CONSTRAINT DF_FNS_SmartCampaign_ForExistingOrders DEFAULT 0
END
GO
--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='CustomerViewedTypeId')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [CustomerViewedTypeId] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_CustomerViewedTypeId DEFAULT 0
END
GO
--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaignRequirement]') and NAME='ForAllCart')
BEGIN
	ALTER TABLE [FNS_SmartCampaignRequirement]
	ADD [ForAllCart] bit NOT NULL CONSTRAINT DF_FNS_SmartCampaignRequirement_ForAllCart DEFAULT 0
END
GO
IF  NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaignUnsubscriber]') AND type in (N'U'))
BEGIN
	CREATE TABLE [dbo].[FNS_SmartCampaignUnsubscriber](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[StoreId] [int] NOT NULL,
		[Email] [nvarchar](255) NULL,
	 CONSTRAINT [PK_FNS_SmartCampaignUnsubscriber] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO
--add a new column
/*IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='SendOneEmail')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [SendOneEmail] bit NOT NULL CONSTRAINT DF_FNS_SmartCampaign_SendOneEmail DEFAULT 0
END
*/
GO
if not exists(select * from MigrationVersionInfo where [Description] = 'FoxNetSoft.SmartCampaigns base schema')
	and EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]'))
begin
	insert into MigrationVersionInfo (Version,AppliedOn,Description)
	values (637265647436451432, GETDATE(), 'FoxNetSoft.SmartCampaigns base schema')
end
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='AttachedDownloadId')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [AttachedDownloadId] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_AttachedDownloadId DEFAULT 0
END
GO
