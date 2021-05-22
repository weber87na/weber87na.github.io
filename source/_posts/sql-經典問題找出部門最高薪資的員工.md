---
title: sql 經典問題找出部門最高薪資的員工
date: 2020-10-07 01:27:18
tags:
- sql
---
&nbsp;
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
