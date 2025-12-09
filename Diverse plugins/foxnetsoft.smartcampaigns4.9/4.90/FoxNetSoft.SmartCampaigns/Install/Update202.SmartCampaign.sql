--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='SendViaInterval')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [SendViaInterval] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_SendViaInterval DEFAULT 0
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='SendViaIntervalTypeId')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [SendViaIntervalTypeId] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_SendViaIntervalTypeId DEFAULT 0
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign_MessageQueue]'))
BEGIN
	CREATE TABLE [dbo].[FNS_SmartCampaign_MessageQueue](
		[Id] [int] IDENTITY(1,1) NOT NULL,
		[SmartCampaignId] [int] NOT NULL,
		[OrderId] [int] NOT NULL,
		[Email] [nvarchar](255) NOT NULL,
		[MessageId] [int] NOT NULL,
		[CreatedOnUtc] [datetime] NOT NULL
	PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
	) ON [PRIMARY]
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaignProduct]') and NAME='AttributesXml')
BEGIN
	ALTER TABLE [FNS_SmartCampaignProduct] ADD [AttributesXml] nvarchar(max) NULL
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='FiltersConditionBetweenProducts')
BEGIN
	ALTER TABLE [FNS_SmartCampaign] ADD [FiltersConditionBetweenProducts] nvarchar(3) NULL
END
GO
IF EXISTS (SELECT 1 FROM [ScheduleTask] where [Type]='Admin.FoxNetSoft.Plugin.Misc.SmartCampaigns.SmartCampaignTask, FoxNetSoft.Plugin.Misc.SmartCampaigns')
BEGIN
	update [ScheduleTask]
	set [Type]='FoxNetSoft.Plugin.Misc.SmartCampaigns.SmartCampaignTask, FoxNetSoft.Plugin.Misc.SmartCampaigns'
	where [Type]='Admin.FoxNetSoft.Plugin.Misc.SmartCampaigns.SmartCampaignTask, FoxNetSoft.Plugin.Misc.SmartCampaigns'
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='SubjectToAcl')
BEGIN
	ALTER TABLE [FNS_SmartCampaign] ADD [SubjectToAcl] bit  NOT NULL CONSTRAINT DF_FNS_SmartCampaign_SubjectToAcl DEFAULT 0
END
GO
--remove column
IF OBJECT_ID('dbo.[DF_FNS_SmartCampaign_ReadEmailFromOrder]', 'D') IS NOT NULL 
begin
    ALTER TABLE [FNS_SmartCampaign] DROP CONSTRAINT DF_FNS_SmartCampaign_ReadEmailFromOrder
end
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='ReadEmailFromOrder')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]	DROP COLUMN [ReadEmailFromOrder]
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='NumberOfOrders')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [NumberOfOrders] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_NumberOfOrders DEFAULT 0
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='DontSendBeforeDateUtc')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [DontSendBeforeDateUtc] [datetime] NULL
END
GO
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='IsActive')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [IsActive] bit NOT NULL CONSTRAINT DF_FNS_SmartCampaign_IsActive DEFAULT 1
END
GO
--add a new column
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id=object_id('[FNS_SmartCampaign]') and NAME='DaysBeforeBirthday')
BEGIN
	ALTER TABLE [FNS_SmartCampaign]
	ADD [DaysBeforeBirthday] int NOT NULL CONSTRAINT DF_FNS_SmartCampaign_DaysBeforeBirthday DEFAULT 0
END
GO