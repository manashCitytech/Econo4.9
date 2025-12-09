update ProductTemplate
set ViewPath='ProductTemplate.ProductModular'
where Name='Modular Products'

if not exists(select * from ProductTemplate where Name='Modular Products (Line)')
begin
	insert into ProductTemplate (Name,ViewPath,DisplayOrder)
	values ('Modular Products (Line)','ProductTemplate.ProductModular2',21)
end
GO
