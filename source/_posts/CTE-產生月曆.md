---
title: CTE 產生月曆
date: 2020-08-24 01:43:06
tags:
- sql
---
&nbsp;
<!-- more -->
無聊看到有人出 sql 怎麼產生月曆，這問題還真是自虐又變態想了滿久，印象中好像有看過類似的
首先利用 CTE 產生出今年的總日期天數(使用 DATEADD 連續加 1 創造類似迴圈的效果)
接著使用 DATENAME 找出該日期為星期幾，最關鍵是搭配 DATEPART( week , 日期) 這個函數，可以找出該日期為某一週，最後使用 PIVOT 就搞定了

```
SET LANGUAGE 繁體中文;

WITH DateRange (D) AS
(
select D = CAST ('20200101' as DATE)
union all
select CAST (DATEADD(DAY, 1, D) as DATE)
from DateRange
where D < CAST ('20201231' as DATE)
) , DR as (
SELECT DATEPART( week , D ) WeekNum , D , DATENAME(dw , D) W
FROM DateRange
)
SELECT WeekNum 週 , 星期日 , 星期一, 星期二, 星期三, 星期四, 星期五, 星期六
FROM DR
PIVOT (
MAX(D)
FOR W IN (星期日 , 星期一, 星期二, 星期三, 星期四, 星期五, 星期六)
) p
--注意這行是讓遞迴無限
OPTION (MAXRECURSION 0)
```

後來做成 postgresql 的版本發現使用 date_part week 會以 iso 8601 進行計算造成錯誤需要自行手動計算目前為第幾週
其中 sum case 這段為計算第幾週的關鍵
```
WITH recursive DateRange (D) AS
(
select '20200101'::DATE
union all
select D::DATE + integer '1'
from DateRange
where D < '20201231'::DATE
) , DR as (
select extract(dow from d) dow , extract(week from d) WeekNum , To_Char(d, 'd') w , To_Char(d, 'dd') dd , To_Char(d, 'mm')::integer mm , d ,
 sum(case when extract(dow from d)  = 0 or To_Char(d, 'dd')::integer = 1 then 1
           else 0
           end) over(order by d) week_no
from DateRange
)
--select *
--from DR
select  min(mm) themon
, max(case when w::integer = 1 then To_Char(d, 'dd') else null end) sun
, max(case when w::integer = 2 then To_Char(d, 'dd') else null  end) mon
, max(case when w::integer = 3 then To_Char(d, 'dd') else null  end) tue
, max(case when w::integer = 4 then To_Char(d, 'dd') else null  end) wed
, max(case when w::integer = 5 then To_Char(d, 'dd') else null  end) thu
, max(case when w::integer = 6 then To_Char(d, 'dd') else null  end) fri
, max(case when w::integer = 7 then To_Char(d, 'dd') else null  end) sat
from DR
group by week_no
order by week_no
```
