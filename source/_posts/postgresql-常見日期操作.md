---
title: postgresql 常見日期操作
date: 2020-10-06 01:51:32
tags:
- postgresql
- sql
---
&nbsp;
<!-- more -->

看書上操作日期章節決定轉為 postgresql 版本方便自己日常作業，詳細日期函數可以參考[postgresql 官網](https://www.postgresql.org/docs/9.5/functions-datetime.html)

操作日期最常見的錯誤就是使用 BETWEEN 欲取得當日資料，而實際上 BETWEEN 實際運算為 >= 某日 AND <= 某日，故會造成取得兩天的資料。
取得當日資料正確方法為以下片段，該片段取得 2020-10-06 內區間資料，若使用 BETWEEN 則會造成 2020-10-07 資料也被一併取出。
``` sql
OrderDate >= '2020-10-06' AND OrderDate < '2020-10-07'
```

使用 postgresql 操作日期需要注意有時區概念，以下片段為常見的時區片段
``` sql
--列出目前時區
SELECT current_setting('TIMEZONE');

--查詢系統時區
SELECT name FROM pg_timezone_names;

--設定時區為台北時間
SET TIMEZONE='Asia/Taipei';
```

相較 MSSQL 的 GETDATE() 函數 postgresql 則是提供 NOW() 函數達成相同效果，
此外兩者皆有提供標準的 CURRENT_TIMESTAMP 標準函數。
postgresql 可以使用戒疤符號 :: 進行資料型態轉換，亦提供與 CAST 函數，相較及他牌資料庫轉換相對輕鬆。
需要注意使用 TO_CHAR 函數回傳的資料型態為 text，而使用 DATE_TRUNC 函數則返回 timestamp 皆可使用戒疤符號進行資料型態轉換。
以下為常見操作

整數日
``` sql
SELECT TO_CHAR(NOW(), 'YYYY-MM-DD') 整數日
```

操作 DATE_TRUNC 函數利用該截斷特點，可達成類似 Oracle TRUNC 函數之效果，快速取得起始值
月初
``` sql
SELECT DATE_TRUNC('month' , NOW()) 月初
```

下月初
``` sql
SELECT DATE_TRUNC('month' , NOW()) + interval '1 month' 下月初
```

月底
``` sql
SELECT DATE_TRUNC('month' , NOW()) + interval '1 month' - interval '1 day' 月底
```

年初
``` sql
SELECT TO_CHAR(NOW(), 'YYYY-01-01') 年初
```

年底
``` sql
SELECT TO_CHAR(NOW(), 'YYYY-12-31') 年底
```

本週三(注意起始日為週一故加兩天為週三)
``` sql
SELECT DATE_TRUNC('week' , NOW()) + interval '2 day' 本週三
```

季初
``` sql
SELECT DATE_TRUNC('quarter' , NOW()) 季初
```

整點
``` sql
SELECT TO_CHAR('2020-10-06 15:47:48.649209'::timestamp, 'HH24') 整點
```

重新定義基準時間(Normalize)
參考書上定義為 07:30 轉換為 postgresql 的版本
``` sql
select '2009-04-22'::date as original_time
, '2009-04-22'::date - interval '4 day' + interval '7.5 hour' as start_time
, '2009-04-22'::date + interval '1 day' + interval '7.5 hour' as end_time
```
