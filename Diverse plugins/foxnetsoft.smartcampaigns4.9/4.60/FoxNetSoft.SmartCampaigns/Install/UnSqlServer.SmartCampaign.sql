IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNS_SmartCampaign_GetSubscriptions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FNS_SmartCampaign_GetSubscriptions]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNS_SmartCampaign_GetRecentlyViewedProduct]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FNS_SmartCampaign_GetRecentlyViewedProduct]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaign_GetSubscriptions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [FNS_SmartCampaign_GetSubscriptions]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaign_GetRecentlyViewedProduct]') AND type in (N'P', N'PC'))
DROP PROCEDURE [FNS_SmartCampaign_GetRecentlyViewedProduct]
GO
