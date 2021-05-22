---
title: .net core exif 筆記
date: 2020-08-21 16:42:08
tags:
- .net core
- exif
- geojson
- imagemagick
---
&nbsp;
<!-- more -->
整理自己的喇賽地圖發現每次都要敲經緯度很煩，下定決心用 exif 來將自己的奇怪食物照片轉換為 geojson
首先到 google 相簿裡面勾選要下載的相片，切記不要使用滑鼠右鍵去下載這樣會吃不到 exif
上 nuget 找找看看有沒有佛心老外做好的 exiflib 沒想到[還真的有](https://github.com/oozcitak/exiflibrary)，感恩老外
結果他給的格式為度分秒 (DMS)，但是一般操作上還是用度度 (DD) 還好我看他的類別裡面有 ToFloat 這個方法可以用，不過這樣精度會減少，但我也懶得算測起來差不多就好了

算式
```
手算
22.00°27.00'54.49"
D + M/ 60 + S / 3600
22 + (27 / 60) + (54.49 / 3600)
22.46513611111111

exif 算的
22.465137
```

``` csharp
namespace ExifLibrary
{
    public class GPSLatitudeLongitude : ExifURationalArray
    {
        public GPSLatitudeLongitude(ExifTag tag, MathEx.UFraction32[] value);
        public GPSLatitudeLongitude(ExifTag tag, float d, float m, float s);

        public MathEx.UFraction32 Degrees { get; set; }
        public MathEx.UFraction32 Minutes { get; set; }
        public MathEx.UFraction32 Seconds { get; set; }
        protected MathEx.UFraction32[] Value { get; set; }

        public float ToFloat();
        public override string ToString();

        public static explicit operator float(GPSLatitudeLongitude obj);
    }
}
```

有了上面的經緯度接著就可以來建立 geojson，這邊要補一下套件，依照之前的經驗法則直接用 .net core 的 System.Text.Json 會有問題，先乖乖安裝 Newtonsoft.Json
```
  <ItemGroup>
    <PackageReference Include="ExifLibNet" Version="2.1.2" />
    <PackageReference Include="GeoJSON.Net" Version="1.2.19" />
    <PackageReference Include="Newtonsoft.Json" Version="12.0.3" />
  </ItemGroup>
```

最後程式碼如下，搞定候看看有無增加新的[奇怪食物](https://weber87na.github.io/map)，成功!
```
using System;
using System.IO;
using ExifLibrary;
using Newtonsoft;
using Newtonsoft.Json;
using GeoJSON;
using GeoJSON.Net;
using System.Collections.Generic;
using GeoJSON.Net.Feature;
using GeoJSON.Net.Geometry;
using System.Collections.Specialized;

namespace ConsoleAppExif
{
    class Program
    {
        static void Main(string[] args)
        {
            var files = Directory.GetFiles("Photos");
            FeatureCollection featureCollection = new FeatureCollection();
            foreach (var file in files)
            {
                //讀取Exif
                var img = ImageFile.FromFile(file);
                var lon = img.Properties.Get<GPSLatitudeLongitude>(ExifTag.GPSLatitude);
                var lat = img.Properties.Get<GPSLatitudeLongitude>(ExifTag.GPSLongitude);

                //設定經緯度的 geometry
                Position position = new Position(lon.ToFloat(), lat.ToFloat());
                Point point = new Point(position);

                //轉換短名稱
                string shortFileName = Path.GetFileName(file);

                //加入顯示屬性 feature
                var featureProperties = new Dictionary<string, object> { {"Name", $"{shortFileName}"} };
                Feature feature = new Feature(point,featureProperties);
                featureCollection.Features.Add(feature);
            }

            //設定序列化並且縮排
            var json = JsonConvert.SerializeObject(featureCollection,Formatting.Indented);
            Console.WriteLine(json);

            File.WriteAllText("奇怪食物.geojson", json);
        }
    }
}

```

最後幫圖片調整一下大小不然相機拍的圖片大小太大，5%可以自由調整
```
for /R %x in (*.jpg) do magick convert "%x" -resize 5% "%x"
```







