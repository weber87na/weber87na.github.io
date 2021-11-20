---
title: GeoServer ImageMosaic 筆記
date: 2021-11-16 01:34:22
tags: GIS
---
&nbsp;
<!-- more -->

### ImageMosaic 設定
這篇也是考古文了 , 主要參考[官方](http://docs.geoserver.org/latest/en/user/tutorials/imagemosaic_timeseries/imagemosaic_timeseries.html) 及 [這篇](https://docs.geoserver.org/latest/en/user/tutorials/imagemosaic_timeseries/imagemosaic_time-elevationseries.html) 還有[這篇](https://geoserver.geo-solutions.it/edu/en/multidim/mosaic_config/temperature_mosaic.html)
印象中有實做出來 , 就不要讓他塵封了 , 最後不曉得為啥因素換成前端去擋這塊

編輯 `catalina.bat` 設定參數
D:\GIS\apache-tomcat-8.5.23\bin\catalina.bat
在第一行加上 `-Dorg.geotools.shapefile.datetime=true` 應該為必加 , 應該會長類似這樣
```
JAVA_OPTS=-Dorg.geotools.coverage.io.netcdf.enhance.ScaleMissing=true -Dorg.geotools.shapefile.datetime=true -Duser.timezone=GMT
```
下載 `snow` [檔案](http://docs.geoserver.org/latest/en/user/_downloads/snowLZWdataset.zip) 放置於 `GEOSERVER_DATA_DIR`

在 `GEOSERVER_DATA_DIR` 底下新建 hydroalp 資料夾
在 `hydroalp` 建立 `snow` 資料夾並將解壓縮的 `tiff` 檔案放到裡面 , 注意 `一定要放置到 GEOSERVER_DATA_DIR 底下才有用`
目錄大概會長這樣
```
D:\GIS\apache-tomcat-8.5.23\webapps\geoserver\data
D:\GIS\apache-tomcat-8.5.23\webapps\geoserver\data\hydroalp\
D:\GIS\apache-tomcat-8.5.23\webapps\geoserver\data\hydroalp\snow
```

在 `D:\GIS\apache-tomcat-8.5.23\webapps\geoserver\data\hydroalp` 底下建立 2 個檔案 `indexer.properties` `timeregex.properties`
這裡注意這兩個檔案也可以直接放到 `snow` 底下與 `tif` 檔是同一個層級
另外注意資料庫要安裝 `postgis extension`
編輯 `indexer.properties` 內容
```
TimeAttribute=ingestion
ElevationAttribute=elevation
Schema=*the_geom:Polygon,location:String,ingestion:java.util.Date,elevation:Integer
PropertyCollectors=TimestampFileNameExtractorSPI[timeregex](ingestion)
```

編輯 `timeregex.properties` 內容
```
regex=[0-9]{8}
```

接著 `Stores` => `Add New Store` => `ImageMosaic`

這裡注意如果是把 `indexer.properties` 與 `timeregex.properties` 這兩個檔案加到 `hydroalp` 路徑要寫這樣
`file:D:/GIS/apache-tomcat-8.5.23/webapps/geoserver/data/hydroalp`

不能寫 (多了個協槓) 這樣因為 `snow` 底下沒有這兩個檔案
`file:D:/GIS/apache-tomcat-8.5.23/webapps/geoserver/data/hydroalp/`


如果圖片有到時間則必須要設定資料庫 `datastore.properties` 設定檔案
```
SPI=org.geotools.data.postgis.PostgisNGDataStoreFactory
host=localhost
port=5432
database=test
schema=public
user=postgres
passwd=postgres
Loose\ bbox=true
Estimated\ extends=false
validate\ connections=true
Connection\ timeout=10
preparedStatements=true
```


### 使用 curl 更新影像
這個部分應該是[參考這篇](https://docs.geoserver.geo-solutions.it/edu/en/multidim/rest/index.html)

`File` 對應到目前 `geotiff` 檔案的位置
`Workspaces` 對應到發佈此 `Store` 的 `workspace`
這邊關鍵為 `netcdf` 及 `rain`

```
curl -v -u admin:geoserver -XPOST -H "Content-type: text/plain" -d "file:D:\GIS\apache-tomcat-8.5.23\webapps\geoserver\data\data\rain\rain_20130909T140000000Z.tif" "http://localhost:8080/geoserver/rest/workspaces/netcdf/coveragestores/rain/external.imagemosaic"
```
