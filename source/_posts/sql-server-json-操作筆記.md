---
title: sql server json 操作筆記
date: 2022-01-29 02:13:31
tags: sql
---

&nbsp;
![terminal](https://raw.githubusercontent.com/weber87na/flowers/master/terminal.png)
<!-- more -->

### 基本操作
礙於我用 2016 所以只有四個函數要記下
`ISJSON` => 拿來驗證是否為正確的格式用 , 如果 JSON 錯誤格式會噴這條 `Msg 13609, Level 16, State 2`
```
--列出壞掉與沒壞掉的 json
select
	--所有資料
	(select count(*)
	from History) as AllData ,

	--找 json 正常的
	(select count(*)
	from History
	WHERE ISJSON(specjson) > 0) as NormalJson ,

	--壞掉的 json
	(select count(*)
	from History
	WHERE ISJSON(specjson) = 0) as BadJson
```

`JSON_VALUE` 這個函數通常拿來展開單一 property 裡面的值而 `JSON_QUERY` 則是撈出整個 json , 總之大原則遇到巢狀就用 `JSON_QUERY`
看他這個[官網範例](https://docs.microsoft.com/zh-tw/sql/t-sql/functions/json-value-transact-sql?view=sql-server-2016#example-2)最後一句如果用 `JSON_VALUE` 來撈 , 會回傳 NULL 很容易搞混
```
DECLARE @jsonInfo NVARCHAR(MAX)
DECLARE @town NVARCHAR(32)

SET @jsonInfo=
N'{
"id": 123,
"info":{
		"address":[{"town":"Paris"},{"town":"London"}]
	}
}';


SET @town=JSON_VALUE(@jsonInfo,'$.info.address[0].town'); -- Paris
SET @town=JSON_VALUE(@jsonInfo,'$.info.address[1].town'); -- London
SELECT @jsonInfo

SELECT JSON_QUERY(@jsonInfo , '$.info') -- {"address":[{"town":"Paris"},{"town":"London"}]}
SELECT JSON_VALUE(@jsonInfo , '$.info') -- NULL

SELECT JSON_QUERY(@jsonInfo , '$.info.XX') -- NULL
```

最後看 `JSON_MODIFY`
假設要新增一個在 json 物件裡面不存在的 property 及數值可以用這樣
更新目前 id 內的數值為 1234
```
--{  "id": "1234",  "info":{    "address":[{"town":"Paris"},{"town":"London"}]   }  }
SELECT JSON_MODIFY(@jsonInfo , '$.id' , '1234')
```

在目前 json 物件新增一個 test 的 property 數值設定為 123
```
--{  "id": 123,  "info":{    "address":[{"town":"Paris"},{"town":"London"}]   ,"test":"123"}  }
SELECT JSON_MODIFY(@jsonInfo , '$.info.test' , '123')
```

搭配 `JSON_VALUE` 把 json 物件裡面原有的 id 新增到 test 這個 property 裡面
```
--{  "id": 123,  "info":{    "address":[{"town":"Paris"},{"town":"London"}]   ,"test":"123"}  }
SELECT JSON_MODIFY(@jsonInfo , '$.info.test' , JSON_VALUE(@jsonInfo , '$.id'))
```

搭配 `JSON_QUERY` 在目前的 json 新增一個 test 的 property , 並且插入一個物件 `{"id" : 123}`
```
--{  "id": 123,  "info":{    "address":[{"town":"Paris"},{"town":"London"}]   ,"test":{"id":123}}  }
SELECT JSON_MODIFY(@jsonInfo , '$.info.test' , JSON_QUERY('{"id":123}'))
```

搭配 `JSON_QUERY` 新增一個 test 的 property , 並且用 `JSON_VALUE` 去撈 id 並且新增
```
--{  "id": 123,  "info":{    "address":[{"town":"Paris"},{"town":"London"}]   ,"test":{"id":123}}  }
SELECT JSON_MODIFY(@jsonInfo , '$.info.test' , JSON_QUERY('{"id":' + JSON_VALUE(@jsonInfo , '$.id') + '}'))
```


### 其他案例
假定有張資料表以 XY 紀錄各種訊息存放物品 , 物品上面有眾多屬性如 IsOepn , IsFail 等等
而 XYBackup 以 `'X,Y'` 這樣的方式作為 key 並且去存 FullInfo 的 json 資料
``` sql
create table XY(
	X int ,
	Y int ,
	IsOpen bit ,
	IsFail bit
)

create table XYBackup(
	XY varchar(200) ,
	FullInfo varchar(max)
)
```

這時候新增一些資料進去 , 並且用 `FOR JSON PATH` 查看看 json 會長怎樣 , 注意預設的 json 會是 array , 所以要加上 `WITHOUT_ARRAY_WRAPPER` 參數

``` sql
insert into XY values( '0' , '5' , 1 , 0)
insert into XY values( '2' , '3' , 1 , 0)
insert into XY values( '7' , '9' , 1 , 0)

SELECT * , (
	SELECT *
	FROM XY I
	WHERE I.X = O.X AND I.Y = O.Y
	FOR JSON PATH , WITHOUT_ARRAY_WRAPPER
) AS FullInfo
FROM XY O
```

接著插入 json 到 `XYBackup`
``` sql
insert into XYBackup values ('0,5' , '{"X":"0","Y":"5","IsOpen":true,"IsFail":false}')
insert into XYBackup values ('0,5' , '{"X":"0","Y":"5","IsOpen":true,"IsFail":true}')
insert into XYBackup values ('2,3' , '{"X":"2","Y":"3","IsOpen":true,"IsFail":false}')
insert into XYBackup values ('7,9' , '{"X":"7","Y":"9","IsOpen":true,"IsFail":false}')
insert into XYBackup values ('9,9' , '{"X":"7","Y":"9","IsOpen":true,"IsFail":false}')
insert into XYBackup values ('19,29' , '{"X":"7","Y":"9","IsOpen":true,"IsFail":false}')
```

接著增加屬性更新看看 , 由於 `XYBackup` 也要一同更新 , 這時問題就浮現上來了 , 舊有資料欄位為 null , 新的則要給預設數值
礙於 sql server 的 bit 我永遠分不清楚正確規則 , 這邊就參考[官網說明](https://docs.microsoft.com/zh-tw/sql/t-sql/data-types/bit-transact-sql?view=sql-server-ver15)
先把簡單的欄位增加然後更新
``` sql
--增加欄位
alter table XY add IsLocked bit null

--更新數值
update XY
set IsLocked = 1
```

接著撈資料測試看看 , 首先需要用 `JSON_MODIFY` 進行更新 , 礙於是用 bit 直接塞進去會出[問題](https://stackoverflow.com/questions/45228973/sql-json-how-to-modify-boolean-value-present-in-the-json-data) , 所以需要用 `CAST(1 AS BIT)` 進行轉換
`JSON_MODIFY` 語法跟 linux 上面 cli tool [jq](https://stedolan.github.io/jq/tutorial/) 很類似只不過是改用 `$` 當作 `root` 反而比 jq 更 jq ~
ps: 如果你是巢狀物件也是一路接 `.` 下去就好了像這樣 `$.Members.IsGreen`

然後直接塞 null 也會有問題 , 所以要參考[這篇](https://stackoverflow.com/questions/59038499/add-new-key-with-value-null-to-existing-json-object)算是一個奇怪技法
``` sql
select top 1 XY , FullInfo 
,	JSON_MODIFY(FullInfo , '$.IsLocked' , CAST(1 AS BIT)) AS LastFullInfo
, 	JSON_MODIFY(
		JSON_MODIFY(FullInfo , '$.IsLocked' , ''),
		'strict $.IsLocked' , null
	) AS AddNullValue
from XYBackup
where XY in
(
	select cast(x as varchar) + ',' + cast(y as varchar)
	from XY
)
```

最後實際更新看看 , 這裡懶得分兩次更新所以直接用 case when 語法即可
``` sql
update XYBackup
set FullInfo = (
	case when xy in (
		select cast(x as varchar) + ',' + cast(y as varchar)
		from XY
	) then JSON_MODIFY(FullInfo , '$.IsLocked' , CAST(1 AS BIT))
	else JSON_MODIFY(
		JSON_MODIFY(FullInfo , '$.IsLocked' , ''),
		'strict $.IsLocked' , null
	) end
)
```

最後想要直接讓 json 變回 row 可以參考[這篇](https://docs.microsoft.com/zh-tw/sql/relational-databases/json/convert-json-data-to-rows-and-columns-with-openjson-sql-server?view=sql-server-ver15)
``` sql
select *
from OPENJSON(
	(
		select top 1 FullInfo
		from XYBackup
	)
) with (
	X int ,
	Y int ,
	IsOpen bit ,
	IsFail bit ,
	IsLocked bit
)
```

可是實務上都會希望讓所有結果集變回來不太可能只用 `top 1` , 所以特別研究下 , 需要搭配 `XML PATH` 及 `STUFF` 將 json rows append 為一個 array
``` sql
select *
from OPENJSON(
	(
		SELECT 
		'[' +
			STUFF((SELECT
				',' + FullInfo
			FROM XYBackup
			FOR XML PATH (''))
			, 1, 1, '') + 
		']'
	)
) with (
	X int ,
	Y int ,
	IsOpen bit ,
	IsFail bit ,
	IsLocked bit
)
```

萬一 json 裡面的屬性為 null 可能會噴這個錯誤 `Msg 13608, Level 16, State 2, Line 1`
可以參考[這篇](https://sqlhints.com/tag/msg-13608-level-16-state-2-line-4-property-cannot-be-found-in-specified-path/)
語法大概長下面這樣
```
SELECT *
FROM YOURTABLE
WHERE JSON_QUERY(jsoncolumn,'$.YOURPROPERTY') IS NOT NULL
```
