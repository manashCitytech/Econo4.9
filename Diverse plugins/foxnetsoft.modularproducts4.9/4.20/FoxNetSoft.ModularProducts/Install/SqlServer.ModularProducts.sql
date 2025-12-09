IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[FNS_ProductDefaultQuantity]') AND name = N'IX_FNS_ProductDefaultQuantity')
begin
	DROP INDEX FNS_ProductDefaultQuantity.IX_FNS_ProductDefaultQuantity
end
GO
IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[FNS_ProductDefaultQuantity]') AND name = N'IX_FNS_ProductDefaultQuantity_ProductId')
begin
	CREATE NONCLUSTERED INDEX IX_FNS_ProductDefaultQuantity_ProductId ON FNS_ProductDefaultQuantity
		(
		ProductId
		) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

end
GO
IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[FNS_ProductDefaultQuantity]') AND name = N'IX_FNS_ProductDefaultQuantity_ProductVariantId')
begin
	CREATE NONCLUSTERED INDEX IX_FNS_ProductDefaultQuantity_ProductVariantId ON FNS_ProductDefaultQuantity
		(
		ProductVariantId
		) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

end
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNS_ModularProducts_ProductLoadAllPaged]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FNS_ModularProducts_ProductLoadAllPaged]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FNS_ModularProducts_ProductLoadAllPaged]
(
	@CategoryIds		nvarchar(MAX) = null,	--a list of category IDs (comma-separated list). e.g. 1,2,3
	@ManufacturerId		int = 0,
	@StoreId			int = 0,
	@VendorId			int = 0,
	@WarehouseId			int = 0,
	@ProductTypeId		int = null, --product type identifier, null - load all products
	@Keywords			nvarchar(4000) = null,
	@AllowedCustomerRoleIds	nvarchar(MAX) = null,	--a list of customer role IDs (comma-separated list) for which a product should be shown (if a subjet to ACL)
	@PageIndex			int = 0, 
	@PageSize			int = 2147483644,
	@TotalRecords		int = null OUTPUT
)
AS
BEGIN
	
	/* Products that filtered by keywords */
	CREATE TABLE #KeywordProducts
	(
		[ProductId] int NOT NULL
	)

	DECLARE
		@SearchKeywords bit,
		@sql nvarchar(max),
		@sql_orderby nvarchar(max)

	SET NOCOUNT ON
	
	--filter by keywords
	SET @Keywords = isnull(@Keywords, '')
	SET @Keywords = rtrim(ltrim(@Keywords))
	IF ISNULL(@Keywords, '') != ''
	BEGIN
		SET @SearchKeywords = 1
		
		--product name
		SET @sql = '
		INSERT INTO #KeywordProducts ([ProductId])
		SELECT p.Id
		FROM Product p with (NOLOCK)
		WHERE '
		SET @sql = @sql + 'PATINDEX(@Keywords, p.[Name]) > 0 '


		--SKU
			SET @sql = @sql + '
			UNION
			SELECT p.Id
			FROM Product p with (NOLOCK)
			WHERE '
			SET @sql = @sql + 'PATINDEX(@Keywords, p.[Sku]) > 0 '

		--PRINT (@sql)
		EXEC sp_executesql @sql, N'@Keywords nvarchar(4000)', @Keywords

	END
	ELSE
	BEGIN
		SET @SearchKeywords = 0
	END

	--filter by category IDs
	SET @CategoryIds = isnull(@CategoryIds, '')	
	CREATE TABLE #FilteredCategoryIds
	(
		CategoryId int not null
	)
	INSERT INTO #FilteredCategoryIds (CategoryId)
	SELECT CAST(data as int) FROM [nop_splitstring_to_table](@CategoryIds, ',')	
	DECLARE @CategoryIdsCount int	
	SET @CategoryIdsCount = (SELECT COUNT(1) FROM #FilteredCategoryIds)

	--filter by customer role IDs (access control list)
	SET @AllowedCustomerRoleIds = isnull(@AllowedCustomerRoleIds, '')	
	CREATE TABLE #FilteredCustomerRoleIds
	(
		CustomerRoleId int not null
	)
	INSERT INTO #FilteredCustomerRoleIds (CustomerRoleId)
	SELECT CAST(data as int) FROM [nop_splitstring_to_table](@AllowedCustomerRoleIds, ',')
	
	--paging
	DECLARE @PageLowerBound int
	DECLARE @PageUpperBound int
	DECLARE @RowsToReturn int
	SET @RowsToReturn = @PageSize * (@PageIndex + 1)	
	SET @PageLowerBound = @PageSize * @PageIndex
	SET @PageUpperBound = @PageLowerBound + @PageSize + 1
	
	CREATE TABLE #DisplayOrderTmp 
	(
		[Id] int IDENTITY (1, 1) NOT NULL,
		[ProductId] int NOT NULL
	)

	SET @sql = '
	INSERT INTO #DisplayOrderTmp ([ProductId])
	SELECT p.Id
	FROM
		Product p with (NOLOCK)'
	
	IF @CategoryIdsCount > 0
	BEGIN
		SET @sql = @sql + '
		LEFT JOIN Product_Category_Mapping pcm with (NOLOCK)
			ON p.Id = pcm.ProductId'
	END
	
	IF @ManufacturerId > 0
	BEGIN
		SET @sql = @sql + '
		LEFT JOIN Product_Manufacturer_Mapping pmm with (NOLOCK)
			ON p.Id = pmm.ProductId'
	END
	
	--searching by keywords
	IF @SearchKeywords = 1
	BEGIN
		SET @sql = @sql + '
		JOIN #KeywordProducts kp
			ON  p.Id = kp.ProductId'
	END
	
	SET @sql = @sql + '
	WHERE
		p.Deleted = 0 and P.ProductTemplateId in (select PT.Id from ProductTemplate PT where PT.Name like ''Modular Products%'')'
	
	--filter by category
	IF @CategoryIdsCount > 0
	BEGIN
		SET @sql = @sql + '
		AND pcm.CategoryId IN (SELECT CategoryId FROM #FilteredCategoryIds)'
	END
	
	--filter by manufacturer
	IF @ManufacturerId > 0
	BEGIN
		SET @sql = @sql + '
		AND pmm.ManufacturerId = ' + CAST(@ManufacturerId AS nvarchar(max))
	END
	
	--filter by vendor
	IF @VendorId > 0
	BEGIN
		SET @sql = @sql + '
		AND p.VendorId = ' + CAST(@VendorId AS nvarchar(max))
	END

	--filter by Warehouse
	IF @WarehouseId > 0
	BEGIN
		SET @sql = @sql + '
		AND p.WarehouseId = ' + CAST(@WarehouseId AS nvarchar(max))
	END
	
	--filter by product type
	IF @ProductTypeId is not null
	BEGIN
		SET @sql = @sql + '
		AND p.ProductTypeId = ' + CAST(@ProductTypeId AS nvarchar(max))
	END
	
	--show hidden and filter by store
	IF @StoreId > 0
	BEGIN
		SET @sql = @sql + '
		AND (p.LimitedToStores = 0 OR EXISTS (
			SELECT 1 FROM [StoreMapping] sm with (NOLOCK)
			WHERE [sm].EntityId = p.Id AND [sm].EntityName = ''Product'' and [sm].StoreId=' + CAST(@StoreId AS nvarchar(max)) + '
			))'
	END
	
	--sorting
	SET @sql_orderby = ''	

		--category position (display order)
		IF @CategoryIdsCount > 0 SET @sql_orderby = ' pcm.DisplayOrder ASC'
		
		--manufacturer position (display order)
		IF @ManufacturerId > 0
		BEGIN
			IF LEN(@sql_orderby) > 0 SET @sql_orderby = @sql_orderby + ', '
			SET @sql_orderby = @sql_orderby + ' pmm.DisplayOrder ASC'
		END
		
		--name
		IF LEN(@sql_orderby) > 0 SET @sql_orderby = @sql_orderby + ', '
		SET @sql_orderby = @sql_orderby + ' p.[Name] ASC'

	
	SET @sql = @sql + '
	ORDER BY' + @sql_orderby
	
	--PRINT (@sql)
	EXEC sp_executesql @sql

	DROP TABLE #FilteredCategoryIds
	DROP TABLE #FilteredCustomerRoleIds
	DROP TABLE #KeywordProducts

	CREATE TABLE #PageIndex 
	(
		[IndexId] int IDENTITY (1, 1) NOT NULL,
		[ProductId] int NOT NULL
	)
	INSERT INTO #PageIndex ([ProductId])
	SELECT ProductId
	FROM #DisplayOrderTmp
	GROUP BY ProductId
	ORDER BY min([Id])

	--total records
	SET @TotalRecords = @@rowcount
	
	DROP TABLE #DisplayOrderTmp

	--return products
	SELECT TOP (@RowsToReturn)
		p.*
	FROM
		#PageIndex [pi]
		INNER JOIN Product p with (NOLOCK) on p.Id = [pi].[ProductId]
	WHERE
		[pi].IndexId > @PageLowerBound AND 
		[pi].IndexId < @PageUpperBound
	ORDER BY
		[pi].IndexId
	
	DROP TABLE #PageIndex
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[FNS_ModularProducts_GetTotalPriceByProductId]') AND type in (N'P', N'PC'))
DROP PROCEDURE [dbo].[FNS_ModularProducts_GetTotalPriceByProductId]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[FNS_ModularProducts_GetTotalPriceByProductId]
(
	@productId		int = 0, --product Id
	@storeId int = 0 --store Id
)
AS
BEGIN
declare @price decimal(18,2)
set @price=null
if @productId=0
begin
	select @price as price
	return
end
if not exists(select P.Id 
	from Product P WITH (NOLOCK),ProductTemplate PT WITH (NOLOCK)
	where P.Id=@productId and P.ProductTemplateId=PT.Id and PT.Name like 'Modular Products%')
begin
	select @price as price
	return
end

select SUM(round(MP.Price*MP.OrderDefaultQuantity,2)) as price
from (select P.Id, P.Price + ISNULL(pa.PriceAdjustment,0) as Price, ISNULL(D.OrderDefaultQuantity, P.OrderMinimumQuantity) as OrderDefaultQuantity
	from Product P WITH (NOLOCK)
		left join FNS_ProductDefaultQuantity D WITH (NOLOCK) on P.Id=D.ProductVariantId
		left join (
			select pm.ProductId, isnull(sum(pav.PriceAdjustment),0) as PriceAdjustment
			from Product_ProductAttribute_Mapping pm with(nolock), 
				ProductAttributeValue pav with(nolock)
			where pm.Id=pav.ProductAttributeMappingId and pav.IsPreSelected=1
			group by pm.ProductId  
		) as pa on pa.ProductId = P.Id
	where P.ParentGroupedProductId=@productId
				AND (P.LimitedToStores = 0 OR @storeId=0 OR EXISTS (
				SELECT 1 FROM [StoreMapping] sm with (NOLOCK)
				WHERE [sm].EntityId = p.Id AND [sm].EntityName = 'Product' and [sm].StoreId=@storeId))
	) as MP

END
GO

