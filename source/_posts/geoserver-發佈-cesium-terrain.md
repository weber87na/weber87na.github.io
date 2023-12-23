---
title: geoserver 發佈 cesium terrain
date: 2022-12-13 01:25:19
tags:
- geoserver
- GIS
- cesium
---
![terrain](https://raw.githubusercontent.com/weber87na/flowers/master/tw_terrain.png)
<!-- more -->

今天心血來潮玩看看 geoserver 發 cesium terrain , 主要 [參考這篇文章](https://github.com/kaktus40/Cesium-GeoserverTerrainProvider)
以前雖然也搞過發 cesium terrain , 可以[參考這篇](https://www.blog.lasai.com.tw/2021/04/26/asp-net-core-%E7%99%BC%E4%BD%88-cesium-terrain/) , 不過那個難度對一個新手來說真是噁爛 , 這個搞起來友善多啦

### Cesium HelloWorld
[HelloWorld 參考這裡](https://cesium.com/learn/cesiumjs-learn/cesiumjs-quickstart/)
如果要用舊版的話 [載點在此](https://github.com/CesiumGS/cesium/releases)
```
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <!-- Include the CesiumJS JavaScript and CSS files -->
  <script src="https://cesium.com/downloads/cesiumjs/releases/1.100/Build/Cesium/Cesium.js"></script>
  <link href="https://cesium.com/downloads/cesiumjs/releases/1.100/Build/Cesium/Widgets/widgets.css" rel="stylesheet">
</head>
<body>
  <div id="cesiumContainer"></div>
  <script>
    // Your access token can be found at: https://cesium.com/ion/tokens.
    // Replace `your_access_token` with your Cesium ion access token.

    Cesium.Ion.defaultAccessToken = 'your_access_token';

    // Initialize the Cesium Viewer in the HTML element with the `cesiumContainer` ID.
    const viewer = new Cesium.Viewer('cesiumContainer', {
      terrainProvider: Cesium.createWorldTerrain()
    });    
    // Add Cesium OSM Buildings, a global 3D buildings layer.
    const buildingTileset = viewer.scene.primitives.add(Cesium.createOsmBuildings());   
    // Fly the camera to San Francisco at the given longitude, latitude, and height.
    viewer.camera.flyTo({
      destination : Cesium.Cartesian3.fromDegrees(-122.4175, 37.655, 400),
      orientation : {
        heading : Cesium.Math.toRadians(0.0),
        pitch : Cesium.Math.toRadians(-15.0),
      }
    });
  </script>
 </div>
</body>
</html>
```


### 下載資料
想要底圖的話可以下載 [naturalearth](https://www.naturalearthdata.com/downloads/)
或是 [BlueMarble](https://neo.gsfc.nasa.gov/view.php?datasetId=BlueMarbleNG-TB)
等等給 `imageryProvider` 使用

[這裡](https://www.tgos.tw/TGOS/Web/Metadata/TGOS_MetaData_View.aspx?MID=81D5440F802B9CE8657EDF62A376FC2A) 可以下載台灣的 DTM
這裡有個關鍵要注意到 , 他的投影好像沒定義好 , 所以 geoserver 吃不到 , 所以設定下 twd97 給他

最後如果要全世界的話就要用 [srtmdata](https://srtm.csi.cgiar.org/srtmdata/) 不過選起來很自虐就對啦

### geoserver 安裝 DDS/BIL extension
注意一定要裝這個 extension , 沒裝的話也是可以看到 terrain 效果 , 不過會穿模
下載[這個](https://docs.geoserver.org/stable/en/user/community/dds/index.html) DDS/BIL extension 檔名大概是這樣 `geoserver-2.21-SNAPSHOT-dds-plugin.zip` 看你用啥版本
老樣子把解開的 `jar` 丟到 `geoserver-2.21.x-latest-bin\webapps\geoserver\WEB-INF\lib`
都裝好以後發圖層的時候會多一個 `BIL Format Settings` , 然後選 `16bit` 即可 , 這個步驟至關重要 , 設定成 8bit 的話就陣亡


### 設定 CORS
通常會噴類似以下的訊息
`Access to XMLHttpRequest at 'http://localhost:8080/geoserver/ows?SERVICE=WMS&REQUEST=GetCapabilities&tiled=true' from origin 'http://127.0.0.1:5500' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.`

首先找到這個檔案 `webapps\geoserver\WEB-INF\web.xml`
看是用 Jetty or Tomcat 把它標示的註解打開就好 `Uncomment following filter to enable CORS in Jetty. Do not forget the second config block further down`
接著要找到這串 `Uncomment following filter to enable CORS` 一樣把註解打開


### 解決 cesium 401 問題
這個不同版本好像不太一樣 , 有的會噴有的不會
```
{code: "InvalidCredentials", message: "Invalid access token"}
```

解法看是要乖乖放 token 上去
```
Cesium.Ion.defaultAccessToken='token';
```

或是設定這兩個參數 false 應該就可以過 , 反正 `imageryProvider` 要用自己的就對啦 , [參考自此](https://community.cesium.com/t/invalid-access-token-when-not-using-ion/7563/4)
```
var viewer = new Cesium.Viewer('cesiumContainer', {
	imageryProvider: false,
	geocoder: false
})
```


### 新增樣式
看他的文章寫說這樣效果比較好就乖乖跟著弄吧 , 設定好以後記得回到圖層設定 style 指向這個 style
```
<?xml version='1.0' encoding='ISO-8859-1'?>
<StyledLayerDescriptor version='1.0.0' xsi:schemaLocation='http://www.opengis.net/sld StyledLayerDescriptor.xsd' xmlns='http://www.opengis.net/sld' xmlns:ogc='http://www.opengis.net/ogc' xmlns:xlink='http://www.w3.org/1999/xlink' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'>
	<!-- a Named Layer is the basic building block of an SLD document -->
	<NamedLayer>
		<Name>SRTM2Color</Name>
		<UserStyle>
			<FeatureTypeStyle>
				<Rule>
					<RasterSymbolizer>
						<Opacity>1.0</Opacity>
						<ChannelSelection>
							<GrayChannel>
								<SourceChannelName>1</SourceChannelName>
							</GrayChannel>
						</ChannelSelection>
						<ColorMap extended='true' type='ramp'>
							<ColorMapEntry color='#000000' quantity='-32768'/>
							<ColorMapEntry color='#BA9800' quantity='15000'/>
						</ColorMap>
					</RasterSymbolizer>
				</Rule>
			</FeatureTypeStyle>
		</UserStyle>
	</NamedLayer>
</StyledLayerDescriptor>
```


### 最終結果
最後要說這個做法有啥優點的話 , 大概就是不用搞一堆 `.terrain` 檔案在機器上面吧
```
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Document</title>


    <!-- <script src="Cesium/Cesium.js"></script> -->
    <!-- <link href="Cesium/Widgets/widgets.css" rel="stylesheet"> -->

    <script src="https://cesium.com/downloads/cesiumjs/releases/1.100/Build/Cesium/Cesium.js"></script>
    <link href="https://cesium.com/downloads/cesiumjs/releases/1.100/Build/Cesium/Widgets/widgets.css"
        rel="stylesheet">
    <script src="./GeoserverTerrainProvider.js"
        type="text/javascript"></script>
</head>
<body>
    <div id="cesiumContainer"></div>
    <script>
        async function init() {
            const container = document.getElementById('cesiumContainer');
            const terrainProvider = await Cesium.GeoserverTerrainProvider({
                "url": "http://localhost:8080/geoserver",
                // "layerName": "elevation:SRTM90",
                // "layerName": "cite:srtm_61_08"
                "layerName": "cite:dem_20m"
            });

            const imageryProvider = new Cesium.WebMapServiceImageryProvider({
                "url": "http://localhost:8080/geoserver/ows",
                "parameters": {
                    "format": "image/png",
                    "transparent": true
                },
                "layers": "cite:NE2_LR_LC_SR_W_DR",
                "maximumLevel": 15
            });

            const options = {
                // imageryProvider: imageryProvider,
                baseLayerPicker: false,
                showRenderLoopErrors: true,
                animation: true,
                fullscreenButton: false,
                geocoder: false,
                homeButton: false,
                infoBox: false,
                sceneModePicker: true,
                selectionIndicator: false,
                timeline: false,
                navigationHelpButton: false,
                navigationInstructionsInitiallyVisible: false,
                targetFrameRate: 30,
                terrainExaggeration: 1.0,
            };
            // Cesium.Ion.defaultAccessToken='申请的token';
            viewer = new Cesium.Viewer(container, options);
            viewer.terrainProvider = terrainProvider;
        }
        init();

    </script>
</body>


</html>
```
