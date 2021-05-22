---
title: CROSS JOIN 妙用產生各年度1到12月的起始與終止日
date: 2020-07-05 11:34:20
tags:
- sql
- tsql
---
&nbsp;
<!-- more -->
工作上遇到的一個需求 CROSS JOIN (Tally) 剛好派上用場的技巧 , 由於每個月的最後一天有可能是 30 , 31 , 加上特殊的 2 月份有 28 , 29

首先用 CTE 建立建立 1 - 12 月的集合 , 接著建立 2019 - 2020 年的集合 , 利用 CROSS JOIN 進行迴圈建立 Y , M 的資料

接著使用以下語法產生出每月的1號值 ex: 20190101,20190102
```
CAST(Y as NVARCHAR) + RIGHT(REPLICATE('0', 2) + CAST(M as NVARCHAR), 2) + '01'
```
最後使用 [EOMONTH函數](https://docs.microsoft.com/zh-tw/sql/t-sql/functions/eomonth-transact-sql?view=sql-server-ver15) 取得該月的最後一日 ex: 2019-02-28 , 2020-02-29 並且依自己需求 format 想要的日期格式

完整程式碼如下:
```TSQL
WITH MonthTally (M) AS
(
    select M = 1
    union all  
    select M + 1
    from MonthTally  
    where M < 12
) , YearTally(Y) as
(
    --建立年份範圍
    select Y = 2019
    union all  
    select Y + 1
    from YearTally  
    where Y < 2020
)
SELECT
CAST(Y as NVARCHAR) + RIGHT(REPLICATE('0', 2) + CAST(M as NVARCHAR), 2) + '01' startdate
--轉換日期格式
, CONVERT(VARCHAR,
--取得該年該月最後一日
EOMONTH ( CAST(Y as NVARCHAR) + RIGHT(REPLICATE('0', 2) + CAST(M as NVARCHAR), 2) + '01' )
,112)  enddate
FROM MonthTally
CROSS JOIN YearTally
```

在 postgresql 上則可以使用 generate_series 遞增產生年度日期，
搭配 + interval '2 month' - interval '1 day' 取得月底日期
使用 to_char(n , 'YYYY-MM-01')::date 取得月初
``` sql
select n
from generate_series(
'2020-01-01'::timestamp ,
'2020-12-31'::timestamp ,
interval '1 day'
) n
where n in (
	date_trunc('month', n) + interval '1 month' - interval '1 day' , 
	to_char(n , 'YYYY-MM-01')::date
)
```
