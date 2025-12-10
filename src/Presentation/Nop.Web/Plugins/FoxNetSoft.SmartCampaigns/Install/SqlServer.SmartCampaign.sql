IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaign_GetSubscriptions]') AND type in (N'P', N'PC'))
DROP PROCEDURE [FNS_SmartCampaign_GetSubscriptions]
GO
/****** Object:  StoredProcedure [FNS_SmartCampaign_GetSubscriptions]    Script Date: 09/07/2013 10:03:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [FNS_SmartCampaign_GetSubscriptions]
(
	@smartCampaignId int,	--SmartCampaign identifier
	@storeId int --Store identifier
)
AS
BEGIN
SET NOCOUNT ON
declare @SmartCampaignTypeId int, @StartDateTimeUtc datetime, @EndDateTimeUtc datetime, 
	@ForAllProduct bit, @OnlySubscriber bit, @SendOneEmail bit, @SubjectToAcl bit, 
	@SendViaIntervalTypeId int, @SendViaInterval int, @DaysBeforeBirthday int,
	@CustomerViewedTypeId int
declare @FiltersConditionBetweenProducts nvarchar(3)
set @SmartCampaignTypeId=0
set @OnlySubscriber=0
set @SendOneEmail = 0
set @ForAllProduct=1
set @SubjectToAcl=0
/*      Minutes = 0,
        Hours = 1,
        Days = 2,
*/
set @SendViaIntervalTypeId=0
set @SendViaInterval=0
set @DaysBeforeBirthday=0
select @SmartCampaignTypeId=SmartCampaignTypeId,
	@StartDateTimeUtc=StartDateTimeUtc,
	@EndDateTimeUtc=EndDateTimeUtc,
	@ForAllProduct=ForAllProduct,
	@FiltersConditionBetweenProducts=FiltersConditionBetweenProducts,
	@SubjectToAcl=SubjectToAcl,
	@SendViaIntervalTypeId=F.SendViaIntervalTypeId,
	@SendViaInterval=F.SendViaInterval,
	@DaysBeforeBirthday = F.DaysBeforeBirthday,
	@CustomerViewedTypeId = F.CustomerViewedTypeId
from FNS_SmartCampaign F WITH (NOLOCK)
where Id=@smartCampaignId

declare @taskseconds int
set @taskseconds=0
select @taskseconds=S.Seconds from ScheduleTask S WITH (NOLOCK) where S.Type like '%SmartCampaignTask%'

declare @dateutc datetime
set @dateutc=GETUTCDATE()
if @SendViaIntervalTypeId=2 --Days
begin
	set @dateutc=DATEADD(dd,-@SendViaInterval,GETUTCDATE())
end
if @SendViaIntervalTypeId=1 --Hours
begin
	set @dateutc=DATEADD(hh,-@SendViaInterval,GETUTCDATE())
end
if @SendViaIntervalTypeId=0 --Minutes
begin
	set @dateutc=DATEADD(mi,-@SendViaInterval,GETUTCDATE())
end

Create table #tmpProductVariant (Id int, AttributesXml nvarchar(max))
if (@ForAllProduct=0)
begin
	insert into #tmpProductVariant (Id, AttributesXml)
	select PG.Id,CP.AttributesXml
	from Product PG WITH (NOLOCK),FNS_SmartCampaignProduct CP WITH (NOLOCK) 
	where PG.ParentGroupedProductId=CP.ProductId
		and CP.SmartCampaignId=@smartCampaignId
	union 
	select CP.ProductId,CP.AttributesXml
	from FNS_SmartCampaignProduct CP WITH (NOLOCK) 
	where CP.SmartCampaignId=@smartCampaignId	
end

create table #tmpCustomer (CustomerId int)
create table #tmpBuyersEmail (CustomerId int, Email nvarchar(1000))

--Customer Recently ViewedProducts
if @SmartCampaignTypeId=30
begin
	--you can buy another plugin
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'FNS_CustomerViewedProducts') AND type in (N'U')) 
	begin
		DECLARE @sql nvarchar(max)
		set @sql = 'insert into #tmpCustomer (CustomerId)
		select distinct O.CustomerId 
		from [FNS_CustomerViewedProducts] O WITH (NOLOCK)
		where (O.CreatedOnUtc>=@StartDateTimeUtc or @StartDateTimeUtc is null)
			and (O.CreatedOnUtc<=@EndDateTimeUtc or @EndDateTimeUtc is null)
			and O.StoreId=@storeId
			and (@CustomerViewedTypeId=0 or O.CustomerViewedTypeId=@CustomerViewedTypeId)
			and (@ForAllProduct=1 or 
				O.ProductId in 
				(select ProductId 
				from FNS_SmartCampaignProduct CP WITH (NOLOCK) 
				where CP.SmartCampaignId=@smartCampaignId))'
		--PRINT (@sql)
		EXEC sp_executesql @sql

		--remove all buyers	
		delete from #tmpCustomer
		where CustomerId in 
			(select distinct O.CustomerId 
			from [Order] O WITH (NOLOCK)
			where O.Id in 
					(select Ov.OrderId 
						from OrderItem Ov WITH (NOLOCK)
						where Ov.ProductId 
						in (select Id from #tmpProductVariant)))
	end		
end

--AbandonedCarts
if @SmartCampaignTypeId=60
begin
	insert into #tmpCustomer (CustomerId)
	select distinct sci.CustomerId
	from ShoppingCartItem sci WITH (NOLOCK)
	where sci.ShoppingCartTypeId=1
		and sci.StoreId=@storeId
		and datediff(ss,sci.UpdatedOnUtc,@dateutc)<@taskseconds
		and datediff(ss,sci.UpdatedOnUtc,@dateutc)>=0
		and (@ForAllProduct=1 or 
					exists(select 1 from #tmpProductVariant V
						where sci.ProductId=V.Id 
						and (V.AttributesXml is null 
							or ltrim(rtrim(V.AttributesXml))=''
							or sci.AttributesXml collate SQL_Latin1_General_CP1_CI_AS=V.AttributesXml collate SQL_Latin1_General_CP1_CI_AS)
							)
			)
end

--WishlistReminder
if @SmartCampaignTypeId=70
begin
	insert into #tmpCustomer (CustomerId)
	select distinct sci.CustomerId
	from ShoppingCartItem sci WITH (NOLOCK)
	where sci.ShoppingCartTypeId=2
		and sci.StoreId=@storeId
		and datediff(ss,sci.UpdatedOnUtc,@dateutc)<@taskseconds
		and datediff(ss,sci.UpdatedOnUtc,@dateutc)>=0
		and (@ForAllProduct=1 or 
					exists(select 1 from #tmpProductVariant V
						where sci.ProductId=V.Id 
						and (V.AttributesXml is null 
							or ltrim(rtrim(V.AttributesXml))=''
							or sci.AttributesXml collate SQL_Latin1_General_CP1_CI_AS=V.AttributesXml collate SQL_Latin1_General_CP1_CI_AS)
							)
			)
end

drop table #tmpProductVariant

--ACL
if (@SubjectToAcl!=0)
begin
	delete from  #tmpCustomer 
	where CustomerId not in (SELECT [fcr].Customer_Id FROM Customer_CustomerRole_Mapping [fcr] WITH (NOLOCK)
								WHERE
									[fcr].CustomerRole_Id IN (
										SELECT [acl].CustomerRoleId
										FROM [AclRecord] acl  WITH (NOLOCK)
										WHERE [acl].EntityId = @smartCampaignId AND [acl].EntityName = 'SmartCampaign'))
end

Create table #tmpEmails (Email nvarchar(1000))

insert into #tmpEmails (Email)
select isnull(C.Email,A.Email) as Email
from Customer C WITH (NOLOCK)
	left join [Address] A WITH (NOLOCK) on C.BillingAddress_Id=A.Id 
where C.Id in (select CustomerId from #tmpCustomer)
	and (C.Email is not null or A.Email is not null)

if @OnlySubscriber=1
begin
	delete from #tmpEmails
	where Email collate SQL_Latin1_General_CP1_CI_AS not in 
			(select N.Email  collate SQL_Latin1_General_CP1_CI_AS
			from NewsLetterSubscription N WITH (NOLOCK)
			where N.Active=1 
				and N.StoreId=@storeId
				)
end

if @SendOneEmail=1
begin
	delete from #tmpEmails
	where Email collate SQL_Latin1_General_CP1_CI_AS not in 
			(select N.Email  collate SQL_Latin1_General_CP1_CI_AS
			from FNS_SmartCampaign_MessageQueue N WITH (NOLOCK)
			where N.SmartCampaignId=@smartCampaignId)
end

--delete unsubscribers
delete from #tmpEmails
where Email collate SQL_Latin1_General_CP1_CI_AS in 
			(select N.Email  collate SQL_Latin1_General_CP1_CI_AS
			from FNS_SmartCampaignUnsubscriber N WITH (NOLOCK)
			where N.StoreId=@storeId)

drop table #tmpCustomer
drop table #tmpBuyersEmail

delete from #tmpEmails where Email is null

select distinct ltrim(rtrim(Email)) as [Value] from #tmpEmails
drop table #tmpEmails

END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaign_GetRecentlyViewedProduct]') AND type in (N'P', N'PC'))
DROP PROCEDURE [FNS_SmartCampaign_GetRecentlyViewedProduct]
GO
/****** Object:  StoredProcedure [FNS_SmartCampaign_GetSubscriptions]    Script Date: 09/07/2013 10:03:33 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [FNS_SmartCampaign_GetRecentlyViewedProduct]
(
	@smartCampaignId int,	--SmartCampaign identifier
	@customerId int,	--Customer identifier
	@storeId int --Store identifier
)
AS
BEGIN
SET NOCOUNT ON
declare @SmartCampaignTypeId int,@StartDateTimeUtc datetime,@EndDateTimeUtc datetime,@ForAllProduct bit
set @SmartCampaignTypeId=0
set @ForAllProduct=1

select @SmartCampaignTypeId=SmartCampaignTypeId,
	@StartDateTimeUtc=StartDateTimeUtc,
	@EndDateTimeUtc=EndDateTimeUtc,
	@ForAllProduct=ForAllProduct
from FNS_SmartCampaign F WITH (NOLOCK)
where Id=@smartCampaignId

Create table #tmpProductVariant (Id int)
if (@ForAllProduct=0)
begin
		insert into #tmpProductVariant (Id)
		select pg.Id 
		from Product pg WITH (NOLOCK)
		where pg.ParentGroupedProductId in 
			(select ProductId 
			from FNS_SmartCampaignProduct CP WITH (NOLOCK) 
			where CP.SmartCampaignId=@smartCampaignId)
		union 
		select ProductId 
			from FNS_SmartCampaignProduct CP WITH (NOLOCK) 
			where CP.SmartCampaignId=@smartCampaignId	
end

Create table #tmpProduct (Id int)

--Customer Recently ViewedProducts
if @SmartCampaignTypeId=30
begin
	IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'FNS_CustomerViewedProducts') AND type in (N'U')) 
	begin
		insert into #tmpProduct (Id)
		select distinct O.ProductId
		from [FNS_CustomerViewedProducts] O WITH (NOLOCK)
		where O.CustomerId = @customerId
			and O.StoreId=@storeId
			and (O.CreatedOnUtc>=@StartDateTimeUtc or @StartDateTimeUtc is null)
			and (O.CreatedOnUtc<=@EndDateTimeUtc or @EndDateTimeUtc is null)
			and (@ForAllProduct=1 or 
				O.ProductId in (select Id from #tmpProductVariant))
				
		--remove all buyers	
		delete from #tmpProduct
		where Id in (select distinct Ov.ProductId
				from [Order] O WITH (NOLOCK),OrderItem Ov WITH (NOLOCK)
				where O.Id=Ov.OrderId and O.CustomerId=@customerId)
	end	
end

select * 
from Product P WITH(NOLOCK)
where P.Id in (select Id from #tmpProduct)
Drop table #tmpProductVariant
Drop table #tmpProduct
END
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaignUnsubscriber') AND type in (N'U'))
begin
	IF not EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[FNS_SmartCampaignUnsubscriber]') AND name = N'IX_FNS_SmartCampaignUnsubscriber_Email')
	begin
	CREATE NONCLUSTERED INDEX IX_FNS_SmartCampaignUnsubscriber_Email ON dbo.FNS_SmartCampaignUnsubscriber
		(
		Email
		) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	END
END
GO
