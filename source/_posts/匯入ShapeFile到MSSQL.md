---
title: 匯入ShapeFile到MSSQL
date: 2020-07-08 19:01:27
tags:
- GIS
- sql
- mssql
- shapefile
- ogr2ogr
---
&nbsp;
<!-- more -->
這篇是很久以前一個朋友有全台灣紅豆餅店的經緯度資料 , 但是沒有詳細縣市鄉鎮 , 佛心幫忙看看

### 匯入 shapefile 到 sql server
首先建立台灣資料庫
```sql
create database Taiwan
```

接著隨便找 open data 下載資料 , 後來發現本來的資料連結掛了 , 換成國土測繪中心的資料 , 搜尋這個[鄉鎮市區界線](https://whgis.nlsc.gov.tw/English/5-1Files.aspx) 正常就有資料了

先用 qgis 開啟來看看下載的檔案是否正確 , 如果遇到 big5 亂碼的話可以參考[這篇](https://wenlab501.github.io/tutorial/qgis_tutor/basic_workflow/encoding/)


開啟 PowerShell cd 到以下目錄
```
cd C:\Program Files\QGIS 3.10\bin
```

匯入鄉鎮地理資料(這邊用localdb)
```sql
.\ogr2ogr.exe -progress -f "MSSQLSpatial" "MSSQL:server=(localdb)\MSSQLLocalDB;database=Taiwan;trusted_connection=yes;" "D:\tw.shp" -a_srs "EPSG:4326" -lco PRECISION=NO
```

用帳號密碼可以參考這種
```sql
.\ogr2ogr.exe -progress -f "MSSQLSpatial" "MSSQL:server=127.0.0.1,1433;database=Taiwan;uid=sa;pwd=pwd@" "D:\Taiwan\tw.shp" -a_srs "EPSG:4326" -lco PRECISION=NO

```

建立紅豆餅店的 geometry , 操作 geometry 可以看[微軟官方](https://docs.microsoft.com/zh-tw/sql/t-sql/spatial-geometry/spatial-types-geometry-transact-sql?view=sql-server-2016)
```
--更新Geom
update Station
set Geom = (geometry::Point([Longitude] ,[Latitude] , 4326))
```

查詢空間查詢將紅豆餅店與地理資料進行 JOIN 看看結果
```sql
--sql server spatial join
select S.* , T.countyname , T.townname
from [Taiwan].[Station] S
join [Taiwan].[dbo].[TW] T
on S.Geom.STIntersects(T.[ogr_geometry]) = 1
```


確認結果無誤以後更新紅豆餅店的縣市鄉鎮
```
--更新縣市鄉鎮
update S
set S.County = T.countyname , S.Town = T.townname
from [Taiwan].[dbo].[Station] S
join [Taiwan].[dbo].[TW] T
on S.Geom.STIntersects(T.[ogr_geometry]) = 1
```

### 用 sql 語法擷取 shapefile 資料
後來遇到人吵著要直接過濾 Shapefile 把台東給撈出來 , 以前用過這招到現在還是覺得很淫蕩 XD , 老樣子看看[官方手冊](https://gdal.org/programs/ogr2ogr.html)
首先先用 `ogrinfo` 撈看看欄位資訊 , 第一個竟然是 `成功` 好彩頭 ~
接著用 `ogr2ogr` 撈出台東 , 這邊注意要設定 `-lco ENCODING=UTF-8` 不然會噴錯
此外 sql 直接寫的話中文會有亂碼錯誤 , 所以用 `@filename` 這個選項把 sql 寫在其他檔案 , 還有不曉得為啥我的 sqlite 不支援 like .. 可能版本太舊?
```
ogrinfo.exe -sql "select * from TOWN_MOI_1100415 limit 1" TOWN_MOI_1100415.shp
ogr2ogr.exe -f "ESRI Shapefile" -dialect sqlite -sql "@test.sql" Taitung.shp TOWN_MOI_1100415.shp -lco ENCODING=UTF-8
```

`test.sql`
```
select *  from TOWN_MOI_1100415
where COUNTYNAME = '臺東縣'
```

### sql server 匯出到 shapefile
後來又遇到要把資料從 sql server 撈出來變成 shapefile , 這個雷在於 localdb 不曉得為啥我試不出來
```
ogr2ogr.exe -f "ESRI Shapefile" GPS.shp "MSSQL:server=127.0.0.1;driver=SQL Server;database=GPS;uid=sa;pwd=yourpassword;" -sql "select GPSID , geometry::Point(x, y , 0) from GPS" -lco ENCODING=UTF-8
```

### 轉換 geojson
這個也滿靈異 , 我用 sql server 直接轉就是失敗 , 可能我 GDAL 版本比較舊? 只好從 shapefile 再轉為 geosjon
```
ogr2ogr -f GeoJSON GPS.json GPS.shp
```

### geojson 匯入到 sql server
先建立 database
```
crate database GPS
```

接著匯入看看 , 意外成功 , 靈異 ~
```
ogr2ogr.exe -f "MSSQLSpatial" "MSSQL:server=127.0.0.1,1433;driver=SQL Server;database=GPS;uid=sa;pwd=yourpassword" GPS.json -a_srs "EPSG:4326" -lco PRECISION=NO
```

最後用 sql server 2016 才有的 json 功能玩看看 , 參考[這篇](https://techcommunity.microsoft.com/t5/sql-server-blog/loading-geojson-data-into-sql-server/ba-p/384601)
```
DECLARE @JSON varchar(max)
SELECT @JSON =BulkColumn
FROM OPENROWSET (BULK 'D:\taiwan\GPS.json', SINGLE_CLOB) as x;

SELECT *
FROM OPENJSON(@JSON , '$.features')
WITH(
	FID varchar(100) '$.properties.FID',
	lon varchar(100) '$.geometry.coordinates[0]',
	lat varchar(100) '$.geometry.coordinates[1]'
)
```

### 將現有經緯度資料轉為 geosjon
工作上時不時有個需求 , 需要將 sql server 的資料轉成 geojson , 以前要做這件事可不容易 , 多半都寫個免洗程式去處理 , 久沒用就忘了
現在 sql server 2016 支援 json 的功能 , 雖然跟 postgresql 比起來還是斷手斷腳 , 勉強可以拼出來
首先在 CTE 的 `coordinates` 屬性用無腦的方式把經緯度轉換為字串然後拼接起來
接著如果需要 `properties` 則利用 `FOR JSON PATH` 的 功能轉為 json , 注意要加上 `WITHOUT_ARRAY_WRAPPER` , 不然 json 會被包成 array
最後在外層用 `FOR XML PATH` 的技巧把 string 連成一排 , 注意到要替換掉 `&#x0D;` 這個 xml 符號
由於 features 裡面需要用逗點分隔 , 所以利用 case 判斷是否要補上逗點
最後可以用[這個網站來 debug](https://geojson.io/#map=2/20.1/0.0) 看看產出的 geojson 正確性
另外 SSMS 資料量太大會不給複製 , 最好升級到 18 的版本 (17 的版本好像沒辦法調很高) , 並需要調高這個設定 `Query` => `Query Options` => `Results` => `Grid` => `Maximun Characters Retrived` => `Non XML data`

```
WITH CTE(Num , GPSID , FreightID , [DateTime] , X , Y , Point) AS (
SELECT ROW_NUMBER() OVER(ORDER BY GPSID) AS Num , * ,
'
    {
      "type": "Feature",
      "properties": ' +
   (
   SELECT *
   FROM GPS B
   WHERE 1 = 1
   AND A.GPSID = B.GPSID
   FOR JSON PATH , WITHOUT_ARRAY_WRAPPER
   )
   + ',
      "geometry": {
        "type": "Point",
        "coordinates": [
          '
    + CAST(X AS VARCHAR) +
    ','
    + CAST(Y AS VARCHAR) +
'
        ]
      }
 }
' Point
FROM GPS A
WHERE 1 = 1
AND FreightID = '9999'
AND [DateTime] >= '2022-03-15'
AND [DateTime] < '2022-03-16'

)

SELECT
'{
  "type": "FeatureCollection",
  "features": [' +
 REPLACE (
  (SELECT Point + CASE WHEN Num > 1 THEN ',' ELSE '' END
  FROM CTE
  ORDER BY Num DESC
  FOR XML PATH('')),
  '&#x0D;',
  ''
 )
+
'  ]
}'
```

### 解析 geojson 內的屬性
當開使在 sql server 操作 json 這也是個常見問題 , 假定有這樣的 geojson
```
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "GPSID": 1029030,
        "FreightID": "K999",
        "DateTime": "2022-03-15T23:59:53",
        "X": 120.4012284,
        "Y": 22.5988653
      },
      "geometry": {
        "type": "Point",
        "coordinates": [
          120.4012284,
          22.5988653
        ]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "GPSID": 1029029,
        "FreightID": "K999",
        "DateTime": "2022-03-15T23:59:44",
        "X": 120.4012654,
        "Y": 22.5988138
      },
      "geometry": {
        "type": "Point",
        "coordinates": [
          120.4012654,
          22.5988138
        ]
      }
    }
  ]
}
```

通常會想要快速拿出 properties 內的資料 , 或是 geometry 內的資料 , 所以可以這樣解

`解法1`
```
select *
from OPENJSON(@geojson, '$.features')
with (
	GPSID int '$.properties.GPSID',
	FreightID nvarchar(max) '$.properties.FreightID',
	[DateTime] DateTime '$.properties.DateTime',
	X decimal(11,8) '$.properties.X',
	Y decimal(10,8) '$.properties.Y'
)
```

`解法2`
特別注意到這裡要用 `JSON_VALUE` , 如果是 array 的話才用 `JSON_QUERY`
```
select
	JSON_VALUE(x.value , '$.properties.GPSID') GPSID,
	JSON_VALUE(x.value , '$.properties.FreightID') FreightID,
	JSON_VALUE(x.value , '$.properties.DateTime') [DateTime],
	JSON_VALUE(x.value , '$.properties.X') X,
	JSON_VALUE(x.value , '$.properties.Y') Y
from openjson (@geojson, '$.features') x
```

巢狀搭配 `JSON_VALUE` & `JSON_QUERY` 拿第一筆的 GPSID
```
select JSON_VALUE(JSON_QUERY(@geojson, '$.features[0]') , '$.properties.GPSID') GPSID
```
