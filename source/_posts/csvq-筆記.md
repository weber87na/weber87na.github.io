---
title: csvq 筆記
date: 2022-10-26 00:51:39
tags: csv
---
&nbsp;
<!-- more -->

今天遇到一個自虐的需求 , user 給我一堆整理過的 excel 上面大概有 1x * 3 張表 , 想到要用手敲真的噁心
還好之前搞過 [csvq](https://github.com/mithrandie/csvq) 剛好拿來半自動化來降低錯誤率
遇到問題如下 , 有個 `nullable` 欄位決定 `null` or `not null` , 不過這個 `csvq` 會輸出 "not null" , 所以多寫個 case 騙他
另外兩個欄位相同時也會有問題 , 所以明確指定 alias 給他們 , 最後就是輸出希望類似 sql 的 format 方便做事 , 所以多補了個 tail
```
create table xxx (
	id not null ,
	col1 null
)
```

```
--手動在 csv 加上這段讓他有 header
--colName,dataType,nullable
--

select colName , dataType ,
	case 
		when nullable = 'Y' then 'null'
		when nullable = 'N' then 'not'
	end as nullable1 ,

	--預設 not null 會掛掉 , 用這樣騙
	case 
		when nullable = 'Y' then ''
		when nullable = 'N' then 'null'
	end as nullable2 ,

	',' as tail
from `XXOO歷史資料分表.csv`

```

最後 output 指令如下 , 利用他輸出空白分隔並且不要有 header 即可創出類似 sql 的 format
美中不足的就是好像沒有複寫的結果的指令 , 需要自己去 rm , 不過也還可以接受啦!
```
csvq -s .\statements.sql -f CSV -D " " --without-header -o result.txt
```

後來有個情境要找一份 csv 裡面的編號 , 然後串成 sql 裡面的 in ('xxx' , 'xxx') 查詢 debug

這裡可以用 -D ',' 然後 select 最後一個放 null 來欺騙他就搞定了
```
csvq -o result.csv -D ',' -N -d '\t' -s sql.txt
```

sql 沒想到竟然也可以用 cte , 還滿猛的阿
這裡要注意下 , 他是用雙管道 `pipe` 當成加號 , 如果要串單引號 `'` 的話需要使用 4 個單引號
號碼做出來後記得要把最後一個逗號自己去尾
```
with cte as (
select distinct ID 
from `data.txt`
)
select '''' || ID || ''''  , null
from cte
```
