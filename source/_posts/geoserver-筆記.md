---
title: geoserver 筆記
date: 2022-11-08 01:47:24
tags:
- GIS
- geoserver
- netcdf
---

&nbsp;
<!-- more -->

因為搞 openlayers 沒有資料玩起來還是挺麻煩的 , 順手筆記下一些測試 geoserver 的 lab 過程

### 安裝
手冊[在此](https://docs.geoserver.org/stable/en/user/installation/win_binary.html) , 首先需要 JAVA 8 or JAVA 11 , 可以參考我[這篇](https://www.blog.lasai.com.tw/2022/08/13/python-%E6%93%8D%E4%BD%9C-netcdf-%E7%AD%86%E8%A8%98/#%E5%AE%89%E8%A3%9D%E5%8F%8A%E8%A8%AD%E5%AE%9A-OpenJDK11)
接著萬事起頭難 , 到官方這個 [載點](https://geoserver.org/download/) 或 [這裡](https://build.geoserver.org/geoserver/2.21.x/) 找找 , 他有分 `war` & `bin` 兩種版本給你
`war` => 有 tomcat 的話要用這個 , `bin` => 沒 tomcat 可以直接用
另外外掛的部分有分 [官方](https://build.geoserver.org/geoserver/2.21.x/ext-latest/) 或 [community](https://build.geoserver.org/geoserver/2.21.x/community-latest/) 感覺現在功能用來越多啦 , 真的猛~
這裡先拿 `bin` 玩看看 , 我下載到 `%userprofile%` 目錄底下
```
cd ~
cd ~/geoserver-2.21.x-latest-bin/bin
```

啟動的話 , 可以在他的 `bin` 目錄找到以下 4 個 script 來啟動或關閉 `http://localhost:8080/geoserver` , 帳號 `admin` , 密碼 `geoserver`
```
.\startup.bat

#shutdown.bat
#shutdown.sh
#startup.bat
#startup.sh
```

### Workspace
預設有以下這些 Workspace 不過我就暫時不動他們
* cite
* it.geosolutions		
* nurc		
* sde		
* sf		
* tiger		
* topp

自己建立 New Workspace , `Name test` , `Namespace URI test`
接著設定以下 4 種都打勾 , 以前在玩的時候多半都只用到 WMS , 其他的部分就沒深入玩到啦
Services
WMTS
WCS
WFS
WMS

### Store
Store 掛在 Workspace 底下 , 就看自己要怎麼分類去建立
都沒安裝 extension 的話預設就只有以下這些

New data source
Choose the type of data source you wish to configure

Vector Data Sources
	Directory of spatial files (shapefiles) - Takes a directory of shapefiles and exposes it as a data store
	GeoPackage - GeoPackage
	PostGIS - PostGIS Database
	PostGIS (JNDI) - PostGIS Database (JNDI)
	Properties - Allows access to Java Property files containing Feature information
	Shapefile - ESRI(tm) Shapefiles (*.shp)
	Web Feature Server (NG) - Provides access to the Features published a Web Feature Service, and the ability to perform transactions on the server (when supported / allowed).
 
Raster Data Sources
	ArcGrid - ARC/INFO ASCII GRID Coverage Format
	GeoPackage (mosaic) - GeoPackage mosaic plugin
	GeoTIFF - Tagged Image File Format with Geographic information
	ImageMosaic - Image mosaicking plugin
	WorldImage - A raster file accompanied by a spatial data file
 
Other Data Sources
	WMS - Cascades a remote Web Map Service
	WMTS - Cascades a remote Web Map Tile Service

### Layers
`Layers` => `Add a new layer` => `Dimensions` => `Time` => `Enabled` => `Presentation` => `List` => `Default value
` => `Use the smallest domain value` => `Save`

也可以參考 [這裡](https://docs.geoserver.geo-solutions.it/edu/en/multidim/netcdf/index.html)
 
### 安裝 netcdf extension
[載點](https://build.geoserver.org/geoserver/2.21.x/ext-latest/geoserver-2.21-SNAPSHOT-netcdf-plugin.zip)
下載後解壓縮會看到一坨檔案 , 要把這些通通都丟到 `webapps\geoserver\WEB-INF\lib` 裡面 , 然後 restart geoserver 才 ok
安裝好後點選 `Stores` => `Add new Store` => `Raster Data Sources` 就可以看到 `NetCDF` 了
```
cdm-4.6.15.jar
commons-cli-1.4.jar
ehcache-core-2.4.3.jar
geodb-0.9.jar
GEOTOOLS_NOTICE.html
GPL.html
gs-netcdf-2.21-SNAPSHOT.jar
gt-coverage-api-27-SNAPSHOT.jar
gt-jdbc-h2-27-SNAPSHOT.jar
gt-netcdf-27-SNAPSHOT.jar
hatbox-1.0.b10.jar
httpclient-4.5.13.jar
httpclient-cache-4.5.13.jar
httpcore-4.4.10.jar
httpmime-4.5.1.jar
httpservices-4.6.15.jar
jaxen-1.1.6.jar
jcip-annotations-1.0.jar
jcommander-1.35.jar
jdom2-2.0.6.1.jar
jna-5.12.1.jar
jna-platform-5.12.1.jar
joda-time-2.8.1.jar
LGPL.html
netCDF.html
netcdf4-4.6.15.jar
NOTICE.html
opendap-2.1.jar
udunits-4.6.15.jar
```

### 發佈 netcdf
發佈的話檔名要稍微規劃下 , 免得找不到自己需要的 wms 服務
接著在自己的 `geoserver-2.21.x-latest-bin\data_dir\data` 底下新增 `netcdf` 資料夾然後把 netcdf 檔案丟進去
`Stores` => `Add new Store` => `Raster Data Sources` => `NetCDF` => `Workspace` => `test`
`Data Source Name *` => `ssh`

發 netcdf 很容易遇到檔案格式有問題 , 就會噴以下 error , 這時候就用 [panoply](https://www.giss.nasa.gov/tools/panoply/) or 其他 viewer 看看
```
Could not list layers for this store, an error occurred retrieving them: Failed to create reader from file:data/xxx/xxx.nc and hints 
Hints: EXECUTOR_SERVICE = java.util.concurrent.ThreadPoolExecutor@78afb95d[Running, pool size = 0, active threads = 0, queued tasks = 0, completed tasks = 0] 
REPOSITORY = org.geoserver.catalog.CatalogRepository@3d25c3e7 
System defaults: 
FORCE_LONGITUDE_FIRST_AXIS_ORDER = true 
LENIENT_DATUM_SHIFT = true 
STYLE_FACTORY = StyleFactoryImpl 
GRID_COVERAGE_FACTORY = GridCoverageFactory 
TILE_ENCODING = null 
COMPARISON_TOLERANCE = 1.0E-8 
FEATURE_FACTORY = org.geotools.feature.LenientFeatureFactoryImpl@1f43cab7 
FORCE_AXIS_ORDER_HONORING = http 
FILTER_FACTORY = FilterFactoryImpl
```

例如下面這個例子 , 他的日期 format `yymmddHH` 就不是標準的日期格式 , 所以需要針對資料源進行日期修正
```
import xarray as xr
import numpy as np

nc = xr.open_dataset('XXX.nc')
nc['Time']

#array([22010100., 22010106., 22010112., 22010118.])
#Coordinates: (0)
#Attributes:
#Format :
#yymmddHH
```

### 設定 netcdf 樣式
通常 netcdf 發佈以後預設的樣式可以說是無 , 醜到爆! 以前研究很久最後發現效果最好就是用 [這篇](https://docs.geoserver.org/latest/en/user/community/ncwms/index.html) 介紹的 extension , 這個 extension 會動態去生出 SLD 免於編輯之苦
不過以前用起來也是有點 bug , 印象中設定到 32 or 64 色就差不多了 , 好像因為 `NUMCOLORBANDS` 這個參數設定到 255 可能會噴 bug
colorbar 的部分可以參考我以前 [這篇設定](https://www.blog.lasai.com.tw/2020/07/15/NCL-Color-Bar-%E8%BD%89%E6%8F%9B/) , 沒想到又晃過兩年了 , 記憶越來越薄弱

下載解壓後會看到以下檔案 , 一樣丟進去 `webapps\geoserver\WEB-INF\lib` 目錄裡
```
gs-colormap-2.21-SNAPSHOT.jar
gs-ncwms-2.21-SNAPSHOT.jar
gt-brewer-27-SNAPSHOT.jar
jcommon-1.0.13.jar
jfreechart-1.0.10.jar
```

接著點選 `Styles` => `Add a new style` => `Name` => `x-Rainbow` => `Workspace` => `test` => `format` => `Dynamic palette` 然後編輯內容
這裡先拿 ncwms 的 x-Rainbow 顏色來用 , 可以在這裡抓到所有 [顏色](https://github.com/Reading-eScience-Centre/edal-java/tree/master/graphics/src/main/resources/palettes)
```
% rainbow
#FF00008F
#FF00009F
#FF0000AF
#FF0000BF
#FF0000CF
#FF0000DF
#FF0000EF
#FF0000FF
#FF000BFF
#FF001BFF
#FF002BFF
#FF003BFF
#FF004BFF
#FF005BFF
#FF006BFF
#FF007BFF
#FF008BFF
#FF009BFF
#FF00ABFF
#FF00BBFF
#FF00CBFF
#FF00DBFF
#FF00EBFF
#FF00FBFF
#FF07FFF7
#FF17FFE7
#FF27FFD7
#FF37FFC7
#FF47FFB7
#FF57FFA7
#FF67FF97
#FF77FF87
#FF87FF77
#FF97FF67
#FFA7FF57
#FFB7FF47
#FFC7FF37
#FFD7FF27
#FFE7FF17
#FFF7FF07
#FFFFF700
#FFFFE700
#FFFFD700
#FFFFC700
#FFFFB700
#FFFFA700
#FFFF9700
#FFFF8700
#FFFF7700
#FFFF6700
#FFFF5700
#FFFF4700
#FFFF3700
#FFFF2700
#FFFF1700
#FFFF0700
#FFF60000
#FFE40000
#FFD30000
#FFC10000
#FFAF0000
#FF9E0000
#FF8C0000
```

接著就是痛苦的地方啦 , 可以到這個 [網站](https://www.url-encode-decode.com/) 去解你的 url 看看參數長怎樣
接著開 jupyter 用這樣去查自己資料源的 max & min value 不過這都是理想狀況資料分佈平均 , 如果往極端值偏的話畫出來很醜
所以搞這些的人多半都有自己的 domain 跟自己的 colorbar
```
import xarray as xr
import numpy as np
nc = xr.open_dataset('chlorophyll.nc')
nc
chlorophyll = nc['chlorophyll']
chlorophyll.max()
chlorophyll.min()

#COLORSCALERANGE_MIN=0.026708
#COLORSCALERANGE_MAX=98.69599152
```

所以可以這樣拿某個時間段裡面最大最小值讓整體畫出來比較好看 , 雖然遇到極端值還是會很醜就是 , 參考 [這裡](https://xarray-test.readthedocs.io/en/latest/generated/xarray.DataArray.html)
```
import xarray as xr
import numpy as np
nc = xr.open_dataset('chlorophyll.nc')
nc
time = nc['time']
# print(time)

chlorophyll = nc['chlorophyll']

# 2003-01-01T12:00:00.000000000
first = chlorophyll.sel(time='2003-01-01T12:00:00')
print("max" + f"{first.max()}")
print("min" + f"{first.min()}")


second = chlorophyll.loc['2003-01-02T12:00:00']
print("max" + f"{second.max()}")
print("min" + f"{second.min()}")

third = chlorophyll[:3]
print("max" + f"{third.max()}")
print("min" + f"{third.min()}")
```

這裡有幾個細節如果要調整顏色 `最小` => `最大` 可以加 `COLORSCALERANGE` 參數
會長這樣 `COLORSCALERANGE=0.026708,0.28909132&` 注意用逗號分割 , 最大最小順序不能錯 , 並且記得給樣式 `styles=x-Rainbow&`
最後是時間 `time=2003-01-01T12:00:00.000Z` 從 jupyter 看到的 format 跟 geoserver 上面的不太一樣

```
array(['2003-01-01T12:00:00.000000000', '2003-01-02T12:00:00.000000000',
       ...
       '2003-01-31T12:00:00.000000000'], dtype='datetime64[ns]')
```

最後串一起 
`http://localhost:8080/geoserver/test/wms?service=WMS&version=1.1.0&request=GetMap&layers=test%3Achlorophyll&bbox=112.95833840736977%2C9.999997773591211%2C126.00001272788415%2C27.04166539626963&width=587&height=768&srs=EPSG%3A4326&format=application/openlayers&COLORSCALERANGE=0.026708,0.28909132&styles=x-Rainbow&time=2003-01-01T12:00:00.000Z`

`http://localhost:8080/geoserver/test/wms?service=WMS&version=1.1.0&request=GetMap&layers=test%3Achlorophyll&bbox=112.95833840736977%2C9.999997773591211%2C126.00001272788415%2C27.04166539626963&width=587&height=768&srs=EPSG%3A4326&format=application/openlayers&COLORSCALERANGE=0.026795,0.25226599&styles=x-Rainbow&time=2003-01-01T12:00:00.000Z`


如果有 openlayers 可以這樣加圖層 , extent 的部分可以直接複製 geoserver 來用 , 順序都一樣

```
Bounding Boxes
Min X
112.95833840736977
Min Y
9.999997773591211
Max X
126.00001272788415
Max Y
27.04166539626963
```

openlayers example
```
new ImageLayer({
	extent: [
		112.95833840736977,
		9.999997773591211,
		126.00001272788415,
		27.04166539626963
	],
	source: new ImageWMS({
		url: 'http://localhost:8080/geoserver/wms',
		params: {
			'LAYERS': 'test:chlorophyll',
			'COLORSCALERANGE' : '0.026708,0.28909132' ,
			'NUMCOLORBANDS' : '254',
			'STYLES' : 'x-Rainbow' ,
			'time' : '2003-01-01T12:00:00.000Z',
			//'time' : '2003-01-31T12:00:00.000Z'
		},
		ratio: 1,
		serverType: 'geoserver',
	}),
}),
```

最後如果發起來的圖資料品質沒那麼優很有馬賽克感的話 , 可以看下[這裡的說明](https://docs.geoserver.org/maintain/en/user/services/wms/webadmin.html)
設定 `Raster Rendering Options` 內插演算法 `Nearest neighbor` `Bilinear` `Bicubic` , 一般用到 `Bilinear` 即可


後來發現 Null Values 設定 NaN NaN (非數值 非數值) 好像會噴下面這樣 , 如果手動設定 -9999 好像就正常 , 以前沒遇過就是了 , 可能資料上需要去修正調整這個部分吧
```
Error rendering coverage on the fast path
java.lang.RuntimeException: Failed to evaluate the process function, error is: org.geotools.coverage.processing.CoverageProcessingException: org.geotools.coverage.processing.CoverageProcessingException: org.geotools.coverage.processing.CoverageProcessingException: java.lang.IllegalArgumentException: Provided ranges are overlapping:NaN(7ff8000000000000) : NaN(7ff8000000000000) / NaN(7ff8000000000000) : NaN(7ff8000000000000)
Failed to evaluate the process function, error is: org.geotools.coverage.processing.CoverageProcessingException: org.geotools.coverage.processing.CoverageProcessingException: org.geotools.coverage.processing.CoverageProcessingException: java.lang.IllegalArgumentException: Provided ranges are overlapping:NaN(7ff8000000000000) : NaN(7ff8000000000000) / NaN(7ff8000000000000) : NaN(7ff8000000000000)
org.geotools.coverage.processing.CoverageProcessingException: org.geotools.coverage.processing.CoverageProcessingException: org.geotools.coverage.processing.CoverageProcessingException: java.lang.IllegalArgumentException: Provided ranges are overlapping:NaN(7ff8000000000000) : NaN(7ff8000000000000) / NaN(7ff8000000000000) : NaN(7ff8000000000000)
org.geotools.coverage.processing.CoverageProcessingException: org.geotools.coverage.processing.CoverageProcessingException: java.lang.IllegalArgumentException: Provided ranges are overlapping:NaN(7ff8000000000000) : NaN(7ff8000000000000) / NaN(7ff8000000000000) : NaN(7ff8000000000000)
org.geotools.coverage.processing.CoverageProcessingException: java.lang.IllegalArgumentException: Provided ranges are overlapping:NaN(7ff8000000000000) : NaN(7ff8000000000000) / NaN(7ff8000000000000) : NaN(7ff8000000000000)
java.lang.IllegalArgumentException: Provided ranges are overlapping:NaN(7ff8000000000000) : NaN(7ff8000000000000) / NaN(7ff8000000000000) : NaN(7ff8000000000000)
Provided ranges are overlapping:NaN(7ff8000000000000) : NaN(7ff8000000000000) / NaN(7ff8000000000000) : NaN(7ff8000000000000)
```

時間如果寫錯會噴這樣
```
<?xml version="1.0" encoding="UTF-8" standalone="no"?><!DOCTYPE ServiceExceptionReport SYSTEM "http://localhost:8080/geoserver/schemas/wms/1.1.1/WMS_exception_1_1_1.dtd"> <ServiceExceptionReport version="1.1.1" >   <ServiceException>
	java.text.ParseException: Invalid date: 2003-01-01T12:00:00
	Invalid date: 2003-01-01T12:00:00
</ServiceException></ServiceExceptionReport>
```

如果不想設定 `global` 的話也可以直接在 `GetMap` 帶進去用 , [參考這裡](https://docs.geoserver.org/maintain/en/user/services/wms/vendor.html#interpolations)
```
source: new ImageWMS({
	url: 'http://localhost:8080/geoserver/wms',
	params: {
		'LAYERS': 'test:chlorophyll',
		'COLORSCALERANGE': '0.026708,0.28909132',
		'NUMCOLORBANDS': '254',
		'STYLES': 'x-Rainbow',

		// 'interpolations': 'bilinear',
		// 'interpolations': 'bicubic',
		// 'interpolations' : Interpolations.Bicubic,
		'interpolations': 'nearest neighbor',

		// 'time' : '2003-01-01T12:00:00.000Z'
		'time': '2003-01-31T12:00:00.000Z'
	},
	ratio: 1,
	serverType: 'geoserver',
}),
```

另外 `interpolations` 也可以用 Enum 封裝 , 寫起來會輕鬆點
```
export enum Interpolations {
    'NearestNeighbor' = 'nearest neighbor',
    'Bilinear' = 'bilinear',
    'Bicubic' = 'bicubic',
}
```



### 自訂 contour line 等深線/等高線
參考自[這篇](https://docs.geoserver.org/stable/en/user/styling/sld/extensions/rendering-transform.html)
基本上寫下面這樣就會成功啦
```
source: new ImageWMS({
	url: 'http://localhost:8080/geoserver/wms',
	params: {
		'LAYERS': 'test:chlorophyll',

		// 'COLORSCALERANGE': '0.026708,0.28909132',
		// 'NUMCOLORBANDS': '254',
		// 'STYLES': 'x-Rainbow',

		// 'interpolations': 'bilinear',
		// 'interpolations': 'bicubic',
		// 'interpolations': 'nearest neighbor',

		'SLD_BODY': sld,
		'STYLES' : '',

		// 'time' : '2003-01-01T12:00:00.000Z'
		'time': '2003-01-31T12:00:00.000Z',
		'tiled': true
	},
	ratio: 1,
	serverType: 'geoserver',
}),
```

這裡用個常數 export 出來 , 特別注意到 `<Name>test:chlorophyll</Name>` 要設定你自己的圖層名稱

`sld.ts`
```
export let sld = `
<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
    xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <NamedLayer>
        <Name>test:chlorophyll</Name>
        <UserStyle>
            <Title>Contour DEM</Title>
            <Abstract>Extracts contours from DEM</Abstract>
            <FeatureTypeStyle>
                <Transformation>
                    <ogc:Function name="ras:Contour">
                        <ogc:Function name="parameter">
                            <ogc:Literal>data</ogc:Literal>
                        </ogc:Function>
                        <ogc:Function name="parameter">
                            <ogc:Literal>levels</ogc:Literal>
                            <ogc:Literal>0.001</ogc:Literal>
                            <ogc:Literal>0.005</ogc:Literal>
                            <ogc:Literal>0.01</ogc:Literal>
                            <ogc:Literal>0.05</ogc:Literal>
                            <ogc:Literal>0.1</ogc:Literal>
                            <ogc:Literal>0.5</ogc:Literal>
                            <ogc:Literal>1</ogc:Literal>
                        </ogc:Function>
                    </ogc:Function>
                </Transformation>
                <Rule>
                    <Name>rule1</Name>
                    <Title>Contour Line</Title>
                    <LineSymbolizer>
                        <Stroke>
                            <CssParameter name="stroke">#000000</CssParameter>
                            <CssParameter name="stroke-width">1</CssParameter>
                        </Stroke>
                    </LineSymbolizer>
                    <TextSymbolizer>
                        <Label>
                            <ogc:PropertyName>value</ogc:PropertyName>
                        </Label>
                        <Font>
                            <CssParameter name="font-family">Arial</CssParameter>
                            <CssParameter name="font-style">Normal</CssParameter>
                            <CssParameter name="font-size">10</CssParameter>
                        </Font>
                        <LabelPlacement>
                            <LinePlacement />
                        </LabelPlacement>
                        <Halo>
                            <Radius>
                                <ogc:Literal>2</ogc:Literal>
                            </Radius>
                            <Fill>
                                <CssParameter name="fill">#FFFFFF</CssParameter>
                                <CssParameter name="fill-opacity">0.6</CssParameter>
                            </Fill>
                        </Halo>
                        <Fill>
                            <CssParameter name="fill">#000000</CssParameter>
                        </Fill>
                        <Priority>2000</Priority>
                        <VendorOption name="followLine">true</VendorOption>
                        <VendorOption name="repeat">100</VendorOption>
                        <VendorOption name="maxDisplacement">50</VendorOption>
                        <VendorOption name="maxAngleDelta">30</VendorOption>
                    </TextSymbolizer>
                </Rule>
            </FeatureTypeStyle>
        </UserStyle>
    </NamedLayer>
</StyledLayerDescriptor>
`
```

接著自訂 function 玩看看 , 線太密的話看起來很噁心 , tickSize 用個 5 , 10 , 20 就差不多了
在 typescript 裡面可以這樣寫來限定 `tickSize:  5 | 10 | 20 = 10` 整個噁心
```
export function contourLine(
    layerName: string,
    tickMin: number,
    tickMax: number,
    //tickSize: number = 10,
	tickSize:  5 | 10 | 20 = 10
    lineColor: string = '#000000',
    lineWidth: number = 1,
) {

    let tick = Math.abs(tickMax - tickMin) / tickSize;
    console.log(tick)
    let literal = '';
    let levels: number[] = []
    for (let current = tickMin; current <= tickMax; current += tick) {
        levels.push(current)
    }

    let strLevels = ''
    for (let level of levels) {

        let template = `<ogc:Literal>${level}</ogc:Literal>`
        strLevels += template
    }

    console.log('levels', levels)
    let sld = `
<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
    xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <NamedLayer>
        <Name>${layerName}</Name>
        <UserStyle>
            <Title>Contour DEM</Title>
            <Abstract>Extracts contours from DEM</Abstract>
            <FeatureTypeStyle>
                <Transformation>
                    <ogc:Function name="ras:Contour">
                        <ogc:Function name="parameter">
                            <ogc:Literal>data</ogc:Literal>
                        </ogc:Function>
                        <ogc:Function name="parameter">
                            <ogc:Literal>levels</ogc:Literal>
                            ${strLevels}
                        </ogc:Function>
                    </ogc:Function>
                </Transformation>
                <Rule>
                    <Name>rule1</Name>
                    <Title>Contour Line</Title>
                    <LineSymbolizer>
                        <Stroke>
                            <CssParameter name="stroke">${lineColor}</CssParameter>
                            <CssParameter name="stroke-width">${lineWidth}</CssParameter>
                        </Stroke>
                    </LineSymbolizer>
                    <TextSymbolizer>
                        <Label>
                            <ogc:PropertyName>value</ogc:PropertyName>
                        </Label>
                        <Font>
                            <CssParameter name="font-family">Arial</CssParameter>
                            <CssParameter name="font-style">Normal</CssParameter>
                            <CssParameter name="font-size">10</CssParameter>
                        </Font>
                        <LabelPlacement>
                            <LinePlacement />
                        </LabelPlacement>
                        <Halo>
                            <Radius>
                                <ogc:Literal>2</ogc:Literal>
                            </Radius>
                            <Fill>
                                <CssParameter name="fill">#FFFFFF</CssParameter>
                                <CssParameter name="fill-opacity">0.6</CssParameter>
                            </Fill>
                        </Halo>
                        <Fill>
                            <CssParameter name="fill">#000000</CssParameter>
                        </Fill>
                        <Priority>2000</Priority>
                        <VendorOption name="followLine">true</VendorOption>
                        <VendorOption name="repeat">100</VendorOption>
                        <VendorOption name="maxDisplacement">50</VendorOption>
                        <VendorOption name="maxAngleDelta">30</VendorOption>
                    </TextSymbolizer>
                </Rule>
            </FeatureTypeStyle>
        </UserStyle>
    </NamedLayer>
</StyledLayerDescriptor>
`

    return sld;
}
```


`ol`
```
new ImageLayer({
	extent: [
		112.95833840736977,
		9.999997773591211,
		126.00001272788415,
		27.04166539626963
	],
	source: new ImageWMS({
		url: 'http://localhost:8080/geoserver/wms',
		params: {
			'LAYERS': 'test:chlorophyll',

			// 'COLORSCALERANGE': '0.026708,0.28909132',
			// 'NUMCOLORBANDS': '254',
			// 'STYLES': 'x-Rainbow',

			// 'interpolations': 'nearest neighbor',
			// 'interpolations': 'bilinear',
			// 'interpolations': 'bicubic',

			'SLD_BODY': contourLine(
				'test:chlorophyll', 
				0,
				1 , 
				10  ,
				'#ff00aa', 
				1,
				),

			// 'time' : '2003-01-01T12:00:00.000Z'
			'time': '2003-01-31T12:00:00.000Z',
			'tiled': true
		},
		ratio: 1,
		serverType: 'geoserver',
	}),
}),
```

萬一 sld 太大的話會超過預設的 `requestHeaderSize` 噴 `414 URI Too Long` , 要調下 jetty or tomcat
```
WARN:oejh.HttpParser:qtp1822971466-634: URI is too large >8192
```

[參考這篇修改](https://blog.csdn.net/ShyLoneGirl/article/details/125865827)
```
cd ~\geoserver-2.21.2-bin\
nvim start.ini
jetty.httpConfig.requestHeaderSize=8192000
```


最後有人發 request 的話可以在 jetty 上面看到 log , 也可以藉由這樣來把覺得順眼的樣式保存起來
```
STYLES=, TIME=2003-01-31T12:00:00.000Z, WIDTH=1366, HEIGHT=625, LAYERS=test:chlorophyll, TILED=true, REQUEST=GetMap, BBOX=22.05223368739925,119.50890651219332,22.95031552299737,121.47175417207659, VERSION=1.3.0, SERVICE=WMS, TRANSPARENT=true}
        RemoteOwsType = null
        RemoteOwsURL = null
        Request = GetMap
        RequestCharset = UTF-8
        ScaleMethod = null
        Sld = null
        SldBody = 
<?xml version="1.0" encoding="ISO-8859-1"?>
<StyledLayerDescriptor version="1.0.0"
    xsi:schemaLocation="http://www.opengis.net/sld StyledLayerDescriptor.xsd"
    xmlns="http://www.opengis.net/sld"
    xmlns:ogc="http://www.opengis.net/ogc"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <NamedLayer>
        <Name>test:chlorophyll</Name>
        <UserStyle>
            <Title>Contour DEM</Title>
            <Abstract>Extracts contours from DEM</Abstract>
            <FeatureTypeStyle>
                <Transformation>
                    <ogc:Function name="ras:Contour">
                        <ogc:Function name="parameter">
                            <ogc:Literal>data</ogc:Literal>
                        </ogc:Function>
                        <ogc:Function name="parameter">
                            <ogc:Literal>levels</ogc:Literal>
                            <ogc:Literal>0.025</ogc:Literal><ogc:Literal>0.0525</ogc:Literal><ogc:Literal>0.07999999999999999</ogc:Literal><ogc:Literal>0.10749999999999998</ogc:Literal><ogc:Literal>0.13499999999999998</ogc:Literal><ogc:Literal>0.16249999999999998</ogc:Literal><ogc:Literal>0.18999999999999997</ogc:Literal><ogc:Literal>0.21749999999999997</ogc:Literal><ogc:Literal>0.24499999999999997</ogc:Literal><ogc:Literal>0.27249999999999996</ogc:Literal><ogc:Literal>0.29999999999999993</ogc:Literal>
                        </ogc:Function>
                    </ogc:Function>
                </Transformation>
                <Rule>
                    <Name>rule1</Name>
                    <Title>Contour Line</Title>
                    <LineSymbolizer>
                        <Stroke>
                            <CssParameter name="stroke">#ff00aa</CssParameter>
                            <CssParameter name="stroke-width">1</CssParameter>
                        </Stroke>
                    </LineSymbolizer>
                    <TextSymbolizer>
                        <Label>
                            <ogc:PropertyName>value</ogc:PropertyName>
                        </Label>
                        <Font>
                            <CssParameter name="font-family">Arial</CssParameter>
                            <CssParameter name="font-style">Normal</CssParameter>
                            <CssParameter name="font-size">10</CssParameter>
                        </Font>
                        <LabelPlacement>
                            <LinePlacement />
                        </LabelPlacement>
                        <Halo>
                            <Radius>
                                <ogc:Literal>2</ogc:Literal>
                            </Radius>
                            <Fill>
                                <CssParameter name="fill">#FFFFFF</CssParameter>
                                <CssParameter name="fill-opacity">0.6</CssParameter>
                            </Fill>
                        </Halo>
                        <Fill>
                            <CssParameter name="fill">#000000</CssParameter>
                        </Fill>
                        <Priority>2000</PrPriority>
                        <VendorOption name="followLine">true</VendorOption>
                        <VendorOption name="repeat">100</VendorOption>
                        <VendorOption name="maxDisplacement">50</VendorOption>
                        <VendorOption name="maxAngleDelta">30</VendorOption>
                    </TextSymbolizer>
                </Rule>
            </FeatureTypeStyle>
        </UserStyle>
    </NamedLayer>
</StyledLayerDescriptor>
```
