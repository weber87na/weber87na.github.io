---
title: sql server 生資料
date: 2022-01-19 01:12:05
tags: sql
---
&nbsp;
![sql](https://raw.githubusercontent.com/weber87na/flowers/master/sql.png)
<!-- more -->

### 生 c# 類別
這個是幹[老外](https://www.thecodehubs.com/how-to-generate-c-class-from-sql-database-table/?utm_source=rss&utm_medium=rss&utm_campaign=how-to-generate-c-class-from-sql-database-table)的來用 , 以前寫過 N 次 , 不過不丟哪
```
CREATE PROC USP_CreateC#ClassFromSQL @TableName sysname
AS
  DECLARE @Result varchar(max) = 'public class ' + @TableName + '
{
'
  SELECT
    @Result = @Result + 'public ' + ColumnType + NullableSign + ' ' + ColumnName + ' { get; set; }' + CHAR(10)
  FROM (SELECT
    REPLACE(col.name, ' ', '_') ColumnName,
    column_id ColumnId,
    CASE typ.name
      WHEN 'bigint' THEN 'long'
      WHEN 'binary' THEN 'byte[]'
      WHEN 'bit' THEN 'bool'
      WHEN 'char' THEN 'string'
      WHEN 'date' THEN 'DateTime'
      WHEN 'datetime' THEN 'DateTime'
      WHEN 'datetime2' THEN 'DateTime'
      WHEN 'datetimeoffset' THEN 'DateTimeOffset'
      WHEN 'decimal' THEN 'decimal'
      WHEN 'float' THEN 'double'
      WHEN 'image' THEN 'byte[]'
      WHEN 'int' THEN 'int'
      WHEN 'money' THEN 'decimal'
      WHEN 'nchar' THEN 'string'
      WHEN 'ntext' THEN 'string'
      WHEN 'numeric' THEN 'decimal'
      WHEN 'nvarchar' THEN 'string'
      WHEN 'real' THEN 'float'
      WHEN 'smalldatetime' THEN 'DateTime'
      WHEN 'smallint' THEN 'short'
      WHEN 'smallmoney' THEN 'decimal'
      WHEN 'text' THEN 'string'
      WHEN 'time' THEN 'TimeSpan'
      WHEN 'timestamp' THEN 'long'
      WHEN 'tinyint' THEN 'byte'
      WHEN 'uniqueidentifier' THEN 'Guid'
      WHEN 'varbinary' THEN 'byte[]'
      WHEN 'varchar' THEN 'string'
      ELSE 'UNKNOWN_' + typ.name
    END ColumnType,
    CASE
      WHEN col.is_nullable = 1 AND
        typ.name IN ('bigint', 'bit', 'date', 'datetime', 'datetime2', 'datetimeoffset', 'decimal', 'float', 'int', 'money', 'numeric', 'real', 'smalldatetime', 'smallint', 'smallmoney', 'time', 'tinyint', 'uniqueidentifier') THEN '?'
      ELSE ''
    END NullableSign
  FROM sys.columns col
  JOIN sys.types typ
    ON col.system_type_id = typ.system_type_id
    AND col.user_type_id = typ.user_type_id
  WHERE object_id = OBJECT_ID(@TableName)) t
  ORDER BY ColumnId
  SET @Result = @Result + '
}
'
  PRINT @Result
```

用法
```
EXEC USP_CREATEC#CLASSFROMSQL 'Enter Your Table Name Here'
```

### 生經緯度點位
這以前在 postgresql 寫過 N 次 , 印象中比 sql server 好搞多了關鍵點如下:
1.經緯度資料型態最好設定 decimal(11,8) 及 decimal(10,8) 防止經度不足
2.用 RAND , CHECKSUM , NEWID 搭配生出亂數
3.用 CTE 搭配 CROSS JOIN , 並且開啟遞迴最高上限限制 OPTION (MAXRECURSION 0)

```
--https://stackoverflow.com/questions/7878287/generate-random-int-value-from-3-to-6
DECLARE @maxlat DECIMAL(10 , 8), @minlat DECIMAL(10 , 8)
SELECT @maxlat=22.68575,@minlat=22.593361

DECLARE @maxlon DECIMAL(11 , 8), @minlon DECIMAL(11 , 8)
SELECT @maxlon=120.520868,@minlon=120.461685

--SELECT CAST(((@maxlat ) - @minlat) *
--    RAND(CHECKSUM(NEWID())) + @minlat AS decimal(10 , 8))  as lat,
--	CAST(((@maxlon ) - @minlon) *
--		RAND(CHECKSUM(NEWID())) + @minlon AS decimal(11 , 8)) as lon

--產生限定時間
--https://stackoverflow.com/questions/33978254/random-datetime-in-given-datetime-range
DECLARE @FromDate DATETIME2(0)
DECLARE @ToDate   DATETIME2(0)

SET @FromDate = '2022-01-10 08:22:13'
SET @ToDate = '2022-01-10 17:56:31'

DECLARE @Seconds INT = DATEDIFF(SECOND, @FromDate, @ToDate)
DECLARE @Random INT = ROUND(((@Seconds-1) * RAND()), 0)

--使用遞迴(RECURSIVE)
;WITH TALLY(N) AS (
    SELECT  1 N
    UNION ALL
    SELECT 1 + N
    FROM Tally
    WHERE N < 10
)
SELECT '001' ID ,
	DATEADD(SECOND, ROUND(((@Seconds-1) * RAND(CHECKSUM(NEWID()))), 0), @FromDate) DateTime,
	CAST(((@maxlon ) - @minlon) *
		RAND(CHECKSUM(NEWID())) + @minlon AS decimal(11 , 8)) as X ,
	CAST(((@maxlat ) - @minlat) *
		RAND(CHECKSUM(NEWID())) + @minlat AS decimal(10 , 8))  as Y
FROM Tally A
CROSS JOIN Tally B
ORDER BY DateTime
OPTION (MAXRECURSION 0);
```

### 找出忘了加 identity 的資料表
```
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
AND TABLE_SCHEMA = 'dbo'
except

select TABLE_NAME
from information_schema.columns tt
where columnproperty(object_id(table_name), column_name,'IsIdentity ') = 1
and table_schema = 'dbo'
```

### 產生補 NULL
實務上遇到一堆 NULL 需要補值 , 利用 sql 產生全部欄位的 update 語法
```
with C as (
        select table_name , column_name , DATA_TYPE , IS_NULLABLE
        from information_schema.columns
        where TABLE_NAME like 'TEST'
)
select
        ' update ' + table_name +
        ' set '  + column_name +  ' = @' +
        ' where ' + column_name + ' is null ' as gen
from C
where C.TABLE_NAME = 'TEST'
```

### 快速修改 not null 的欄位為 null
```
select
     'alter table CoilInsertPinOutput ' +
     'alter column ' + COLUMN_NAME + ' ' +
     case
         when DATA_TYPE = 'int' then 'int'
         when DATA_TYPE = 'decimal' then 'decimal(10,2)'
     end +
     ' null;'
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='CoilInsertPinOutput'
```
