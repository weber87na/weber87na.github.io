---
title: sql 產生 sql
date: 2021-02-02 19:37:19
tags: sql
---
&nbsp;
<!-- more -->

實務上遇到一堆 NULL 需要補值 , 利用 sql 產生全部欄位的 update 語法
```
with C as (
	select table_name , column_name , DATA_TYPE , IS_NULLABLE
	from information_schema.columns
	where TABLE_NAME like 'TEST'
)
select 
	' update ' + table_name +
	' set '  + column_name +  ' = @' +
	' where ' + column_name + ' is null ' as gen
from C
where C.TABLE_NAME = 'TEST' 
```
