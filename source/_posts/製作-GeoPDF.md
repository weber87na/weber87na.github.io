---
title: 製作 GeoPDF
date: 2021-11-14 20:37:48
tags: GIS
---
&nbsp;
<!-- more -->

### 環境準備
這篇算是考古文了 , 有空把以前做過的東東整理整理 , 主要[參考這個老外](https://github.com/roblabs/gdal-geopdf)
先安裝 [OSGeo4W](https://trac.osgeo.org/osgeo4w/)
裝好以後裡面會有一堆鬼東西 , 真不曉得以前怎麼跟這些打交道的 , 主要是依靠 `gdal_translate` 這支程式進行轉換
接著準備一個資料夾 , 為了模擬真實狀況我資料夾名稱就用 guid 產出 , 及幾張座標系邊界相同的 tif 檔 , 缺圖的話可以到 [naturalearthdata](https://www.naturalearthdata.com/downloads/50m-raster-data/)
```
D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1
layer0.tif
layer1.tif
layer2.tif
```

### gdal_translate 製圖
先從簡單的一張開始做看看 , 注意 `^` 是 cmd 換行因為參數太多怕看不清楚 , 也可以不加
另外注意 , 以前我在用的時候是沒法使用中文當作檔名跟圖層名稱 , 現在有無支援我不曉得
```
gdal_translate -of PDF D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\layer0.tif  D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\test.pdf ^
-co LAYER_NAME=basemap
```

接著疊上圖層 , 然後可以用 Adobe Acrobat Reader 打開 geopdf 即可看到有圖層效果
```
gdal_translate -of PDF D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\layer0.tif ^
D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\test.pdf  ^
-co LAYER_NAME=basemap ^
-co EXTRA_RASTERS=D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\layer1.tif  ^
-co EXTRA_RASTERS_LAYER_NAME=layer1
```

最後一步要多疊一個圖層 , 最大關鍵就是要用逗號 `,` 分隔 `EXTRA_RASTERS` 及 `EXTRA_RASTERS_LAYER_NAME`
```
gdal_translate -of PDF D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\layer0.tif ^
D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\test.pdf  ^
-co LAYER_NAME=basemap ^
-co EXTRA_RASTERS=D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\layer1.tif,D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\layer2.tif  ^
-co EXTRA_RASTERS_LAYER_NAME=layer1,layer2
```

另外如果要把 png 轉成 geotiff 可以用下面這個指令 , 他的四個邊界點左上右下 ulx, uly, lrx, lry
這票 GIS 工具有的參數吃右上左下 , 不然就是經緯度相反 , 需要特別注意免得寫錯
基本上前端只要能把圖 post 進入後端 , 可以用 base64 加上四個點去塞更容易解 , 可惜沒繼續做 GIS 只能感慨 ~
```
gdal_translate -of Gtiff -a_ullr -122.17833 42.92361 -122.13799 42.95766 -a_srs EPSG:4326 haha.png haha.tiff
```

### 結合 csharp
老實說 csharp 對這方面的整合斷手斷腳的 , 所以用看起來很 `low` 的方法去實現
我後來有幸玩過一次 ArcGIS 的 api , 猜他內部做法應該都差不多 , 印象圖層也是不能中文 , 搞不好就是幹 gdal 的東東去做的
因為時代的眼淚 , 這邊就簡單重寫一下 , 要整合網站做成內部模組也是一樣道理
```
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace ConsoleAppGeoPDF
{
    class Program
    {
        static void Main(string[] args)
        {
            //檔案
            List<string> fileNames = new List<string> {
                "layer0",
                "layer1",
                "layer2",
            };

            //目錄位置
            string dir = @"D:\LASAI\58e21528-e530-481c-b88f-d9a980ec46e1\";

            //gdal_translate 位置
            string gdal = @"C:\OSGeo4W64\bin\gdal_translate";

            Process cmd = new Process( );
            cmd.StartInfo.FileName = "cmd.exe";
            cmd.StartInfo.RedirectStandardInput = true;
            cmd.StartInfo.RedirectStandardOutput = true;
            cmd.StartInfo.CreateNoWindow = true;
            cmd.StartInfo.UseShellExecute = false;
            cmd.Start( );

            //切換目錄
            cmd.StandardInput.WriteLine( "cd " + dir );

            //設定擷取的部分
            string EXTRA_RASTERS = "";
            foreach (var item in fileNames.Skip(1))
                EXTRA_RASTERS += dir +  item + ".tif" + ",";
            EXTRA_RASTERS = EXTRA_RASTERS.TrimEnd( ',' );

            //設定圖層名稱
            string EXTRA_RASTERS_LAYER_NAME = "";
            foreach (var item in fileNames.Skip(1))
                EXTRA_RASTERS_LAYER_NAME += item + ",";
            EXTRA_RASTERS_LAYER_NAME = EXTRA_RASTERS_LAYER_NAME.TrimEnd( ',' );

            //跑命令
            string command =
$@"{gdal} -of PDF {dir + @"layer0.tif"} {dir + @"test.pdf"} -co LAYER_NAME=basemap -co EXTRA_RASTERS={EXTRA_RASTERS} -co EXTRA_RASTERS_LAYER_NAME={EXTRA_RASTERS_LAYER_NAME} ";
            cmd.StandardInput.WriteLine( command );

            cmd.StandardInput.Flush( );
            cmd.StandardInput.Close( );

            cmd.WaitForExit( );
            Console.WriteLine( cmd.StandardOutput.ReadToEnd( ) );
            cmd.Close( );

        }
    }
}

```


