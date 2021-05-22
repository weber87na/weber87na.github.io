---
title: postgresql 補全遺漏的時間區段
date: 2020-07-15 09:21:47
tags:
- postgresql
- sql
---
&nbsp;
<!-- more -->
具有時間序列的資料很容易因為天候因素 , 或是儀器不穩定導致無法正確回傳到 server!
很容易出現資料不連續的狀況 , 例如早上 8 點有資料但是 10 點就突然沒資料了
所以製作報表時需要自己把空白時間區塊填滿 , 產生固定每小時都有資料的暫時表

取得過去72小時的時間 ex: "2020-01-15 08:40:00" - 71 hours = "2020-01-12 09:00:00"
```
SELECT date_trunc('hour'::text, ( SELECT now()::timestamp without time zone - '71:00:00'::interval hour)) AS date_trunc
```

利用 [generate_series 函數](https://www.postgresql.org/docs/current/functions-srf.html) 產生 72 小時區間資料
```
SELECT t.day
FROM generate_series(
	(SELECT date_trunc('hour'::text, ( SELECT now()::timestamp without time zone - '71:00:00'::interval hour)) AS date_trunc),
	now()::timestamp without time zone,
	'01:00:00'::interval
) t(day)
```

輸出會像是以下這樣的結果集
```
"2020-01-12 09:00:00"
"2020-01-12 10:00:00"
"2020-01-12 11:00:00"
"2020-01-12 12:00:00"
...
...
...
"2020-01-15 08:00:00"
```

運用 CROSS JOIN 將時間區段與觀測站編號進行組合 , 將缺少的時間補全
```
SELECT t.day , a.stationid
FROM generate_series(
	(SELECT date_trunc('hour'::text, ( SELECT now()::timestamp without time zone - '71:00:00'::interval hour)) AS date_trunc),
	now()::timestamp without time zone,
	'01:00:00'::interval
) t(day)
CROSS JOIN autostation a
```
輸出會像是以下這樣的結果集
```
"2020-02-12 10:00:00";"C0A560"
"2020-02-12 10:00:00";"C0X190"
"2020-02-12 10:00:00";"C0S950"
...
```
最後進行 left join 就可以取得想要的資料了 , 可以用 WITH 太過複雜的臨時查詢結果
```
WITH X as (
	SELECT t.day , a.stationid
	FROM generate_series(
		(SELECT date_trunc('hour'::text, ( SELECT now()::timestamp without time zone - '71:00:00'::interval hour)) AS date_trunc),
		now()::timestamp without time zone,
		'01:00:00'::interval
	) t(day)
	CROSS JOIN autostation a
)
SELECT X.* , log.*
FROM X
LEFT JOIN log
ON X.day::text = log.obstime::text 
AND X.stationid::text = log.stationid::text;
```
