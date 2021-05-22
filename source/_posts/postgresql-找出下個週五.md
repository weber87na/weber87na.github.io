---
title: postgresql 找出下個週五
date: 2020-10-04 23:24:04
tags:
- postgresql
---
&nbsp;
<!-- more -->
看書時看到找出下個週五的案例，想說轉為 postgresql 版本沒想到也是費了點勁，藉此筆記一下。
關鍵公式 (7 - (DATE_PART('DOW' , Base::DATE)::INT + 1) + 5) % 7 + 1 
postgresql 使用 DATE_PART 函數進行運算週日由 0 開始，故一週為 0 - 6 計算，所以需要修正加一。
此外 DATE_PART 函數計算完成資料型態為 double 並非 integer，故需要先行轉換資料型態為 integer 並且用括號包住以免計算錯誤。
最後使用 CTE 時需要加上 RECURSIVE 才可以觸發地迴功能
```
WITH RECURSIVE TALLY(N , Base)
AS(
	SELECT 1 N , NOW()::date Base
	UNION ALL
	SELECT N + 1 , Base + 1 Base
	FROM TALLY
	WHERE 1 = 1
	AND N < 10
)
SELECT Base 
, TO_CHAR(Base, 'Day') 星期幾
, Base + (7 - (DATE_PART('DOW' , Base::DATE)::INT + 1) + 5) % 7 + 1 下個週五
FROM TALLY
```
