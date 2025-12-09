IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNS_ModularProducts_ProductLoadAllPaged]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FNS_ModularProducts_ProductLoadAllPaged]
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNS_ModularProducts_GetTotalPriceByProductId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FNS_ModularProducts_GetTotalPriceByProductId]
GO