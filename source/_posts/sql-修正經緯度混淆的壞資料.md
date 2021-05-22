---
title: sql 修正經緯度混淆的壞資料
date: 2020-10-21 13:50:29
tags:
- sql
---
&nbsp;
<!-- more -->

看書看到 case 運用，記得以前曾經碰過落雷資料有類似的問題，不過當時是遇到的資料為經緯度寫反，
還有少部分混淆索性就手工修正資料了。其實現在想想可以善用 case 針對錯誤的經緯度範圍批次修正
``` sql
with coord(x,y) as(
	select 21.34567 x , 122.23452 y
	union all
	select 21.12567 x , 121.23451 y
	union all
	select 21.2127 x , 122.27453 y
	union all
	select 21.1327 x , 122.24786 y	
	union all
	select 122.2327 x , 22.34786 y
	union all
	select 122.2351 x , 21.13786 y
	union all
	select 121.1227 x , 21.12786 y	
)
select x , y
	--, case when x between 20 and 22 then y else x end lon ,
	--  case when y between 121 and 123 then x else y end lat 
into temp coord
from coord

--修正經緯度填寫錯誤的資料
update coord
set x = case when x between 20 and 22 then y else x end ,
    y = case when y between 121 and 123 then x else y end

--查看資料正確性
select *
from coord
```
後來想到以前做連續性資料常常遇到信號 loss 造成精度或緯度為 -999 的狀況，可能也可以用類似的方法搭配視窗函數去偷捕資料(尚須修正)
``` sql
with coord(x,y) as(
	select 21.337 x , 121.32451 y
	union all
	select -999 x , 122.23452 y
	union all
	select 21.34567 x , -999 y
	union all
	select 21.12567 x , 121.23451 y
	union all
	select 21.2127 x , 122.27453 y
)
select x , y 
, case when x = -999 then min(x) over(rows between 1 preceding and 1 preceding) else x end fix_x
, case when y = -999 then min(y) over(rows between 1 preceding and 1 preceding) else y end fix_y
from coord
```
