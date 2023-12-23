---
title: sql 經典問題找出部門最高薪資的員工
date: 2020-10-07 01:27:18
tags:
- sql
---
&nbsp;
![sql](https://raw.githubusercontent.com/weber87na/flowers/master/sql.png)
<!-- more -->

看書時複習到這題，記得有至少兩本書有講過順便筆記一下，印象中應該是用視窗函數最快，記得自己也有用過類似方法提升查詢效能。

子查詢解法
``` sql
WITH CTE AS (
    SELECT Emp_Id , Emp_Name , Dept_Id , Salary
    FROM Employees
    WHERE Dept_id IN ('I100' , 'I200')
)
SELECT *
FROM CTE A
WHERE Salary =
(
    SELECT MAX(Salary)
    FROM CTE B
    WHERE A.Dept_id = B.Dept_id
)
```

視窗函數解法
``` sql
SELECT *
FROM(
    SELECT A.* , MAX(Salary) OVER(PARTITION BY Dept_Id) MAXSAL
    FROM Employees A
    WHERE Dept_id IN ('I100' , 'I200')
) X
WHERE Salary = MAXSAL
```

知道怎麼解以後就可以拿來分析 MLB 最高薪的球員，使用[資料集](http://www.seanlahman.com/baseball-archive/statistics)，查詢後得到驚為天人的結果，原來陳偉殷薪水這麼高阿
``` sql
--建立薪水資料表
create table salaries(
	yearID integer,
	teamID varchar(50),
	lgID varchar(50),
	playerID varchar(50),
	salary integer
)

--匯入資料
COPY salaries(yearID,teamID,lgID,playerID,salary)
FROM 'D:\Salaries.csv'
DELIMITER ','
CSV HEADER;

--分析 2016 各隊最高薪的球員
select *
from(
	select * , row_number() over (partition by teamid order by salary desc) seq
	from salaries
	where yearid = 2016
) x
where seq = 1
order by salary desc
```

後來發現這個淫蕩工具 [csvq](https://github.com/mithrandie/csvq)
可以直接用 sql 操作 csv , 語法也差不多 , 可惜沒 2021 年薪水資料 , 不然應該找看看大谷的 XD

```
csvq -s .\statements.sql | less
```

`statements.sql`
```
select *
from (
	select * , row_number() over (partition by teamid order by salary desc) as seq
	from `Salaries.csv`
	where yearid = 2016
)
where seq = 1
order by salary desc

```

今天遇到 SQL Server 也要解類似問題再多筆記一下
```
with cte as (
	select 'A001' as emp_id , 1 as dept_id , 5000 as salary
	union all
	select 'A002' , 1 , 3000
	union all
	select 'A003' , 1 , 2300
	union all
	select 'B002' , 2 , 2800
	union all
	select 'B001' , 2 , 15000
	union all
	select 'X002' , 3 , 2800
	union all
	select 'X001' , 3 , 15000
	union all
	select 'X003' , 3 , 1500
	union all
	select 'X004' , 3 , 5500
)
select *
from (
	select * , row_number() over (partition by dept_id order by salary desc) as seq
	from cte
) x
--where seq = 3
```

### 實際案例
今天幫忙在 Oracle 上面看看 , 同事不曉得為啥 ORDER BY 的時候出現一個版本號 `9 > 1x` 的狀況 , 原來是資料型別為字串造成
所以先加上 `TO_NUMBER` 轉換 , 接著即可找出最大版本號的文件名稱
```
SELECT DNAME, VER
FROM (
	SELECT DNAME, VER , ROW_NUMBER() OVER (PARTITION BY DNAME ORDER BY TO_NUMBER(VER) DESC) SEQ
	FROM DOCS
	WHERE 1 = 1
	AND STATUS = 'RELEASE'
	AND DTYPE = 'Sheet'
) X
WHERE SEQ = 1
```
