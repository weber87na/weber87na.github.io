---
title: sql 標記出 GY 同事可能會開 Combo 請假的日子
date: 2020-10-08 03:51:57
tags:
- sql
- postgresql
---
&nbsp;
![sql](https://raw.githubusercontent.com/weber87na/flowers/master/sql.png)
<!-- more -->

印象這是很多年前一個計算周期的問題，主要是利用 generate_series 產生出當月日期，搭配 case 標記邏輯規則產製出該月可能被開 Combo 的狀態。
需要注意運用 case 時具有順序性，以本案例而言 danger 必須排在 warning 之上，否則會造成月底時應當標記 danger 卻錯標 warning 的狀況。
GY 同事可能開 Combo 的請假週期規則：每逢週一、五為警告 (warning) ，逢月底為危險 (danger) 其他則為正常上班 (job) 及假日 (vacation)
其他關鍵 isodow 將一週定義為 1-7 從週一開始計算
取得當月最後五天則為：先取得下月月初接著減去五日
``` sql
--取得日期數字
select date_part( 'isodow' , current_date);
--計算月底五天
select ('2020-10-01'::date + interval '1 month' - interval '5 day')::timestamp then 'danger';
```

完整範例
``` sql
select n::date days , 
	date_part( 'isodow' , n) isodow , 
	to_char(n , 'DY') weekname ,
	case 
		when date_part( 'isodow' , n) in (6,7)  then 'vacation' 
		when n >= ('2020-10-01'::date + interval '1 month' - interval '5 day')::timestamp then 'danger'
		when date_part( 'isodow' , n) in (1,5)  then 'warning'
		else 'job'
	end status
from generate_series(
'2020-10-01'::timestamp ,
('2020-10-01'::date + interval '1 month' - interval '1 day')::timestamp ,
interval '1 day'
) n
```

若不使用 generate_series 產生日期方法如下，比較特別是可以使用 limit 進行區間限制亦可產生以天數為單位的日期序列
``` sql
with recursive tally(d) as(
	select '2020-10-01'::timestamp d
	union all
	select d + interval '1 day'
	from tally
	--where d < ('2020-10-01'::date + interval '1 month' - interval '1 day')
)
select *
from tally
limit to_char(('2020-10-01'::date + interval '1 month' - interval '1 day') , 'DD')::int
```
