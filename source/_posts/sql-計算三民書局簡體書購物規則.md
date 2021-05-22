---
title: sql 計算三民書局簡體書購物規則
date: 2020-10-08 15:59:53
tags:
- sql
- postgresql
---
&nbsp;
<!-- more -->

無聊到三民書局買書剛好看到該站的限時購物車規則，就隨手寫看看，剛開始腦子還有點卡。
一般來講這種優惠通常會衍生出兩種計算邏輯

邏輯一簡單計算
超過3本(含)72折(只要超過三本不論幾本都打75折)
單本1本75折
``` sql
with shoppingcart(bookid , price) as(
	select 'A001' bookid , 320 price
	union all
	select 'A002' , 700
	union all
	select 'A003' , 990
	union all
	select 'A004' , 660
)
select sum( 
	case when (select count(*) from shoppingcart) >= 3 then price * 0.72
	     else price * 0.75
	end
) as total_price
from shoppingcart
```

邏輯二
3本72折(價錢由高到低進行排序，即被除外75折的書價格為整個清單中較低的，而打75折的書售價較高)
1本75折
關鍵是利用 row_number 產生由大到小書本價格的序列號，接著計算出價格序列 <= 書本總數 - (書本總數 % 3本) = 打 72 折的書，其餘的則為 75 折
``` sql
with shoppingcart(bookid , price) as(
	select 'A001' bookid , 320 price
	union all
	select 'A002' , 700
	union all
	select 'A003' , 990
	union all
	select 'A004' , 660
	union all
	select 'A005' , 870
	union all
	select 'A006' , 200
	union all
	select 'A007' , 320
) , saleshoppingcart(bookid , price , seq , discount , onsale) as (
	select * ,
		--折扣價格
		case when seq <= (select count(*) from shoppingcart) - (select count(*) from shoppingcart) % 3 then price * 0.72
		     else price * 0.75
		end discount ,
		--打幾折
		case when seq <= (select count(*) from shoppingcart) - (select count(*) from shoppingcart) % 3 then '72%'
		     else '75%'
		end onsale 
	from (
		select * ,
			--依照價格進行排名給客戶最好的折扣
			row_number() over(order by price desc) seq 
		from shoppingcart
	) result
)
select * , (select sum(discount) from saleshoppingcart) total
from saleshoppingcart
```
