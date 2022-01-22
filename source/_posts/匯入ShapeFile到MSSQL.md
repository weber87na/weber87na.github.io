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

首先建立台灣資料庫
```sql
create database Taiwan
```

接著隨便找 open data 下載資料 , 後來發現本來的資料連結掛了 , 換成國土測繪中心的資料 , 搜尋這個[鄉鎮市區界線](https://whgis.nlsc.gov.tw/English/5-1Files.aspx) 正常舊有資料了

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
.\ogr2ogr.exe -progress -f "MSSQLSpatial" "MSSQL:server=127.0.0.1,4333;database=Taiwan;uid=sa;pwd=pwd@" "D:\Taiwan\tw.shp" -a_srs "EPSG:4326" -lco PRECISION=NO

```

建立紅豆餅店的 geometry
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

