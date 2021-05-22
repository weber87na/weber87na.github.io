---
title: asp.net core 發佈 cesium terrain
date: 2021-04-26 03:28:19
tags:
- asp.net core
- GIS
---
&nbsp;
<!-- more -->

### terrain 資料產生
[首先下載 2016 年全臺灣 20 公尺網格 DTM 資料](https://www.tgos.tw/TGOS/Web/Metadata/TGOS_MetaData_View.aspx?MID=81D5440F802B9CE8657EDF62A376FC2A)
接著到 [cesium-terrain-builder-docker](https://github.com/tum-gis/cesium-terrain-builder-docker) pull image
也可以直接拿他給的 docker file 來編譯

host
``` powershell
cd ~
docker pull tumgis/ctb-quantized-mesh:latest
mkdir cesium
cd cesium
docker run -it -v ${PWD}:/data 1d5e
```

container
``` bash
apt install wget
wget -O tw.zip https://www.tgos.tw/TGOS/Generic/Utility/Filedownload.ashx?url=https://www.tgos.tw:443/TGOS/VirtualDir/MAPData/10749/Download/%E4%B8%8D%E5%88%86%E5%B9%85_%E5%85%A8%E5%8F%B0%E5%8F%8A%E6%BE%8E%E6%B9%96.zip
apt install unzip
unzip tw.zip

#注意他這邊 -o 要先有資料夾不會幫你自動建立
mkdir terrain

#生成 layer.json
ctb-tile -f Mesh -C -N -l -o terrain dem_20m.tif

#生成 terrain 檔
ctb-tile -f Mesh -C -N -o terrain dem_20m.tif
```

### 舊版 .net
記得多年前曾經做過 terrain 費了很大的力氣 , 剛好在寫 .net core 就順手改寫看看 , 太久沒做應該還要多補寫怎麼製作 terrain , 先偷懶之後有時間再補
以前好像是在 IIS 上面直接掛載以下這段 code 的模組 , 就可以發出 terrain , 參考強國人的網站已找不到
```
    public class ZipHeaderModule : IHttpModule
    {
        public void Dispose()
        {
            //do nothing
            //throw new NotImplementedException();
        }

        public void Init(HttpApplication context)
        {
            context.EndRequest += Context_EndRequest;
        }

        private void Context_EndRequest(object sender, EventArgs e)
        {
            var context = sender as HttpApplication;
            string fileExtension = context.Request.CurrentExecutionFilePathExtension;
            if (fileExtension.Length >= 8)
            {
                if (fileExtension.Substring(0, 8) == ".terrain")
                {
                    context.Response.AddHeader("Content-Encoding", "gzip");
                }
            }
            
        }
    }
```
參考 cesium 網站的 example 還要加上一狗票 web.config 設定 , 最關鍵就是這句 `<mimeMap fileExtension=".terrain" mimeType="application/vnd.quantized-mesh" />`
```
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <system.webServer>
        <staticContent>
            <remove fileExtension=".czml" />
            <mimeMap fileExtension=".czml" mimeType="application/json" />
            <remove fileExtension=".glsl" />
            <mimeMap fileExtension=".glsl" mimeType="text/plain" />
            <remove fileExtension=".b3dm" />
            <mimeMap fileExtension=".b3dm" mimeType="application/octet-stream" />
            <remove fileExtension=".pnts" />
            <mimeMap fileExtension=".pnts" mimeType="application/octet-stream" />
            <remove fileExtension=".i3dm" />
            <mimeMap fileExtension=".i3dm" mimeType="application/octet-stream" />
            <remove fileExtension=".cmpt" />
            <mimeMap fileExtension=".cmpt" mimeType="application/octet-stream" />
            <remove fileExtension=".gltf" />
            <mimeMap fileExtension=".gltf" mimeType="model/gltf+json" />
            <remove fileExtension=".bgltf" />
            <mimeMap fileExtension=".bgltf" mimeType="model/gltf-binary" />
            <remove fileExtension=".glb" />
            <mimeMap fileExtension=".glb" mimeType="model/gltf-binary" />
            <remove fileExtension=".json" />
            <mimeMap fileExtension=".json" mimeType="application/json" />
            <remove fileExtension=".geojson" />
            <mimeMap fileExtension=".geojson" mimeType="application/json" />
            <remove fileExtension=".topojson" />
            <mimeMap fileExtension=".topojson" mimeType="application/json" />
            <remove fileExtension=".wasm" />
            <mimeMap fileExtension=".wasm" mimeType="application/wasm" />
            <remove fileExtension=".woff" />
            <mimeMap fileExtension=".woff" mimeType="application/font-woff" />
            <remove fileExtension=".woff2" />
            <mimeMap fileExtension=".woff2" mimeType="application/font-woff2" />
            <remove fileExtension=".kml" />
            <mimeMap fileExtension=".kml" mimeType="application/vnd.google-earth.kml+xml" />
            <remove fileExtension=".kmz" />
            <mimeMap fileExtension=".kmz" mimeType="application/vnd.google-earth.kmz" />
            <remove fileExtension=".svg" />
            <mimeMap fileExtension=".svg" mimeType="image/svg+xml" />
            <remove fileExtension=".terrain" />
            <mimeMap fileExtension=".terrain" mimeType="application/vnd.quantized-mesh" />
            <remove fileExtension=".ktx" />
            <mimeMap fileExtension=".ktx" mimeType="image/ktx" />
            <remove fileExtension=".crn" />
            <mimeMap fileExtension=".crn" mimeType="image/crn" />
        </staticContent>
    </system.webServer>
</configuration>
```

### 新版 .net core
起初的想法是掛個 Middleware 應該就可以快速搞定 , 研究了下其實 `UseStaticFiles` 本身就是個 Middleware , 有幫我們準備好現成的方法可以做微調
關鍵就是設定 `.terrain` 讓他 mapping 至 `application/vnd.quantized-mesh`
接著在 Response Header 加上 `Content-Encoding` 讓他是採用 `gzip` 就搞定了!
最後因為是要給前端使用 , 所以必須補上 CORS 這個討人厭的鬼東西

```
public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
	if (env.IsDevelopment( ))
	{
		app.UseDeveloperExceptionPage( );
	}

	app.UseCors( builder =>
	{
		builder.AllowAnyOrigin( );
		builder.AllowAnyMethod( );
		builder.AllowAnyHeader( );
	 } );

	app.UseRouting( );

	var provider = new FileExtensionContentTypeProvider( );
	provider.Mappings.Add( ".terrain", "application/vnd.quantized-mesh" );

	app.UseStaticFiles( new StaticFileOptions
	{
		ContentTypeProvider = provider,
		OnPrepareResponse = ctx =>
		{
			string extension = System.IO.Path.GetExtension(ctx.File.Name);
			if (extension == ".terrain")
			{
				ctx.Context.Response.Headers.Add( "Content-Encoding", "gzip" );
			}
		},
	} );

	app.UseAuthorization( );

	app.UseEndpoints( endpoints =>
	 {
		 endpoints.MapControllers( );
	 } );
}
```
最後前端會打出類似這樣的網址 `http://localhost:5000/terrain/10/1715/645.terrain?v=1.1.0`
Response 會給出以下這樣的訊息就算是搞定了
特別注意到 `Access-Control-Allow-Origin: *` `Content-Encoding: gzip` `Content-Type: application/vnd.quantized-mesh` 這三個部分缺一不可
```
Accept-Ranges: bytes
Access-Control-Allow-Origin: *
Content-Encoding: gzip
Content-Length: 2608
Content-Type: application/vnd.quantized-mesh
Date: Sun, 25 Apr 2021 19:16:35 GMT
ETag: "1d4f43d3df16cb0"
Last-Modified: Tue, 16 Apr 2019 10:14:57 GMT
Server: Kestrel
```

### 最後補上一個前端 index.html 就全部都搞定了
最後一步下載 [Cesium](https://cesium.com/platform/cesiumjs/)
將 Build 裡面的 `CesiumUnminified` 丟到你專案內的 `wwwroot` 資料夾內
並且把開頭算好的 `terrain` 資料夾也丟到 `wwwroot` 裡面
並且把 `CesiumUnminified` 跟 `terrain` 都設定 `Exclude from project` 防止太多檔案導致 visual studio 速度變慢
``` html
<!DOCTYPE html>
<html lang="zh-tw">

<head>
    <meta charset="UTF-8">
    <!-- <meta name="viewport" content="width=device-width, initial-scale=1.0"> -->
    <!--for iphone-->
    <meta name="viewport"
          content="width=device-width, height=device-height, initial-scale=1.0, user-scalable=0, minimum-scale=1.0, maximum-scale=1.0">

    <!--強制防止cache-->
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
    <meta http-equiv="Expires" content="0" />
    <meta http-equiv="Pragma" content="no-cache" />

    <meta http-equiv="X-UA-Compatible" content="ie=edge">

    <title>Cesium</title>

    <style>
        @import url(CesiumUnminified/Widgets/widgets.css);

        * {
            margin: 0;
            padding: 0;
            list-style: none;
            font-family: '微軟正黑體', 'Microsoft JhengHei', sans-serif;
            box-sizing: border-box;
        }

        html,
        body,
        #cesiumContainer {
            width: 100%;
            height: 100%;
            margin: 0;
            padding: 0;
            overflow: hidden;
        }

    </style>
</head>

<body>
    <!--地圖主體-->
    <div id="cesiumContainer"></div>

    <!--Cesium-->
    <script src="./CesiumUnminified/Cesium.js"></script>

    <script>
        var viewer = new Cesium.Viewer('cesiumContainer', {
            animation: false, //是否創建動畫小器件，左下角儀表
            baseLayerPicker: false, //是否顯示圖層選擇器
            fullscreenButton: false, //是否顯示全屏按鈕
            geocoder: false, //是否顯示geocoder小器件，右上角查詢按鈕
            homeButton: false, //是否顯示Home按鈕
            infoBox: false, //是否顯示信息框
            sceneModePicker: false, //是否顯示3D/2D選擇器
            selectionIndicator: false, //是否顯示選取指示器組件
            timeline: false, //是否顯示時間軸
            navigationHelpButton: false, //是否顯示右上角的幫助按鈕
            scene3DOnly: true, //如果設置為true，則所有幾何圖形以3D模式繪製以節約GPU資源
            clock: new Cesium.Clock(), //用於控制當前時間的時鐘對象
            selectedImageryProviderViewModel: undefined, //當前圖像圖層的顯示模型，僅baseLayerPicker設為true有意義
            imageryProviderViewModels: Cesium
                .createDefaultImageryProviderViewModels(), //可供BaseLayerPicker選擇的圖像圖層ProviderViewModel數組
            selectedTerrainProviderViewModel: undefined, //當前地形圖層的顯示模型，僅baseLayerPicker設為true有意義
            terrainProviderViewModels: Cesium
                .createDefaultTerrainProviderViewModels(), //可供BaseLayerPicker選擇的地形圖層ProviderViewModel數組
            imageryProvider: new Cesium.OpenStreetMapImageryProvider({
            }), //圖像圖層提供者，僅baseLayerPicker設為false有意義
            fullscreenElement: document.body, //全屏時渲染的HTML元素,
            useDefaultRenderLoop: true, //如果需要控制渲染循環，則設為true
            targetFrameRate: undefined, //使用默認render loop時的幀率
            showRenderLoopErrors: false, //如果設為true，將在一個HTML面板中顯示錯誤信息
            automaticallyTrackDataSourceClocks: true, //自動追踪最近添加的數據源的時鐘設置
            contextOptions: undefined, //傳遞給Scene對象的上下文參數（scene.options）
            sceneMode: Cesium.SceneMode.SCENE3D, //初始場景模式
            mapProjection: new Cesium.WebMercatorProjection(), //地圖投影體系
            dataSources: new Cesium.DataSourceCollection()
            //需要進行可視化的數據源的集合
        });

        //設定相機位置

        viewer.camera.setView({
            destination: Cesium.Cartesian3.fromDegrees(121, 22, 200000.0),
            orientation: {
                heading: Cesium.Math.toRadians(10.0),
                pitch: Cesium.Math.toRadians(-15.0),
                roll: 0
            }
        });

        viewer.camera.position = {
            "x": -4225970.254191063,
            "y": 6609503.858450623,
            "z": 1614300.9176620042
        }

        viewer.camera.direction = {
            "x": 0.649115806651835,
            "y": -0.6057112854818547,
            "z": 0.4601766054404077
        }

        viewer.camera.up = {
            "x": -0.06293426272291522,
            "y": 0.5601105054909595,
            "z": 0.8260239101952105
        }

        viewer.camera.right = {
            "x": -0.7580817555714294,
            "y": -0.5651460521657928,
            "z": 0.3254565894111815
        }


        var scene = viewer.scene;



        var terrainProvider = new Cesium.CesiumTerrainProvider({
            url: 'http://localhost:5000/terrain'
        });
        //default terrain
        scene.terrainProvider = terrainProvider;

    </script>
</body>
</html>
```
