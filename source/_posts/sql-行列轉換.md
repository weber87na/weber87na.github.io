---
title: sql 行列轉換
date: 2022-07-09 06:29:44
tags: sql
---

&nbsp;
![sql](https://raw.githubusercontent.com/weber87na/flowers/master/sql.png)
<!-- more -->

工作上遇到的古怪問題 , 有張上古報表會依照順序去擺放位置 , 位置為 0 - 5 , 類似這樣

| 0  | 1 | 2  | 3  | 4  |
|----|---|----|----|----|
| 11 |   | 4  | 5  | 7  |
| 18 |   | 33 | 0  | 18 |
|    | 2 | 1  | 7  | 9  |
| 6  | 8 | 0  | 22 |    |


看了看資料表的結構是用名稱加上位置去存放類似這樣 `A1357-0` , `A1357-1` , `A1357-2`
試著自己用 sql 還原下行列轉換看看
想法是先用 `SUBSTR` 去取得其位置 , 接著利用 `SUM` 搭配 `CASE` 即可搞定

```
WITH CTE AS (
    SELECT Name,
        SUBSTR(NameWithPos,-1) AS "POS" ,
        Val
    FROM Item
) , RowToCol AS (
    SELECT Name ,
        SUM(CASE WHEN POS = '0' THEN Val ELSE NULL END) "0-Val",
        SUM(CASE WHEN POS = '1' THEN Val ELSE NULL END) "1-Val",
        SUM(CASE WHEN POS = '2' THEN Val ELSE NULL END) "2-Val",
        SUM(CASE WHEN POS = '3' THEN Val ELSE NULL END) "3-Val",
        SUM(CASE WHEN POS = '4' THEN Val ELSE NULL END) "4-Val"
    FROM CTE
    GROUP BY Name
)
SELECT *
FROM RowToCol
order by Name
```

最後無聊用 sql server 寫個正 , 輸出這樣
```
*********
    *
 *  ***
 *  *
*********
```

```
WITH CTE AS (
	SELECT 'A' Name , 'A-1' NameWithPos , 1 Val
	UNION ALL
	SELECT 'A' , 'A-2' , 1
	UNION ALL
	SELECT 'A' , 'A-3' , 1
	UNION ALL
	SELECT 'A' , 'A-4' , 1
	UNION ALL
	SELECT 'A' , 'A-5' , 1
	UNION ALL
	SELECT 'A' , 'A-6' , 1
	UNION ALL
	SELECT 'A' , 'A-7' , 1
	UNION ALL
	SELECT 'A' , 'A-8' , 1
	UNION ALL
	SELECT 'A' , 'A-9' , 1
	UNION ALL
	SELECT 'B' , 'B-5' , 1
	UNION ALL
	SELECT 'C' , 'C-2' , 1
	UNION ALL
	SELECT 'C' , 'C-5' , 1
	UNION ALL
	SELECT 'C' , 'C-6' , 1
	UNION ALL
	SELECT 'C' , 'C-7' , 1
	UNION ALL
	SELECT 'D' , 'D-2' , 1
	UNION ALL
	SELECT 'D' , 'D-5' , 1
	UNION ALL
	SELECT 'E' , 'E-1' , 1
	UNION ALL
	SELECT 'E' , 'E-2' , 1
	UNION ALL
	SELECT 'E' , 'E-3' , 1
	UNION ALL
	SELECT 'E' , 'E-4' , 1
	UNION ALL
	SELECT 'E' , 'E-5' , 1
	UNION ALL
	SELECT 'E' , 'E-6' , 1
	UNION ALL
	SELECT 'E' , 'E-7' , 1
	UNION ALL
	SELECT 'E' , 'E-8' , 1
	UNION ALL
	SELECT 'E' , 'E-9' , 1
) , CTEPOS AS (
SELECT Name , SUBSTRING( NameWithPos , LEN(NameWithPos)  , 1)  POS, Val
FROM CTE
) , RowToCol AS (
    SELECT Name ,
        SUM(CASE WHEN POS = '1' THEN Val ELSE NULL END) "1-Val",
        SUM(CASE WHEN POS = '2' THEN Val ELSE NULL END) "2-Val",
        SUM(CASE WHEN POS = '3' THEN Val ELSE NULL END) "3-Val",
        SUM(CASE WHEN POS = '4' THEN Val ELSE NULL END) "4-Val",
		SUM(CASE WHEN POS = '5' THEN Val ELSE NULL END) "5-Val",
		SUM(CASE WHEN POS = '6' THEN Val ELSE NULL END) "6-Val",
		SUM(CASE WHEN POS = '7' THEN Val ELSE NULL END) "7-Val",
		SUM(CASE WHEN POS = '8' THEN Val ELSE NULL END) "8-Val",
		SUM(CASE WHEN POS = '9' THEN Val ELSE NULL END) "9-Val"
    FROM CTEPOS
    GROUP BY Name
)
SELECT
	REPLICATE('*', [1-Val]) as "1",
	REPLICATE('*', [2-Val]) as "2",
	REPLICATE('*', [3-Val]) as "3",
	REPLICATE('*', [4-Val]) as "4",
	REPLICATE('*', [5-Val]) as "5",
	REPLICATE('*', [6-Val]) as "6",
	REPLICATE('*', [7-Val]) as "7",
	REPLICATE('*', [8-Val]) as "8",
	REPLICATE('*', [9-Val]) as "9"
FROM RowToCol
```
