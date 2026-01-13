If Not Exists (select 1 from LocaleStringResource where ResourceName='common.decline')
Begin

Insert into LocaleStringResource values(3, 'common.decline','afwijzen')
End