---
title: asp.net core 製作 geojson
date: 2020-07-14 02:05:52
tags:
- asp.net core
- gis
- geojson
---
&nbsp;
<!-- more -->
首先安裝 [GeoJSON.Net](https://github.com/GeoJSON-Net/GeoJSON.Net)
```
Install-Package GeoJSON.Net
```

在Startup.cs 底下的 ConfigureServices 設定 NewtonsoftJson 注意撰寫此文章時 GeoJson.Net 對 .net core 原生的 System.Text.Json 尚未支援會造成輸出上的錯誤
``` csharp
public void ConfigureServices(IServiceCollection services)
{
    //設定防止循環參考
    services.AddControllers()
        .AddNewtonsoftJson(opt =>
            opt.SerializerSettings.ReferenceLoopHandling =
            Newtonsoft.Json.ReferenceLoopHandling.Ignore);
}
```
#### 建立吐站點的 GeoJson API
``` csharp
public class Station
{
    public string Name { get; set;}
    public double Lon { get; set;}
    public double Lat { get; set;}
}
```
``` csharp
public ActionResult<FeatureCollection> GetStationGeoJson()
{
    List<Station> stations = new List<Station>(){
        new Station { Name = "Test1" , Lon = 121.2314 , Lat = 21.6841 },
        new Station { Name = "Test2" , Lon = 122.2s4 , Lat = 21.3321 },    
        new Station { Name = "Test3" , Lon = 120.1314 , Lat = 21.7341 },
        new Station { Name = "Test4" , Lon = 121.2324 , Lat = 22.9341 },
    };
    
    FeatureCollection fc = new FeatureCollection();
    foreach (var station in stations)
    {
        Position position = new Position(
       longitude: station.Lon,
       latitude: station.Lat);

        Point point = new Point(position);
        GeoJSON.Net.Geometry.Point p = new GeoJSON.Net.Geometry.Point(position);

        Feature feature = new Feature(p, station);
        fc.Features.Add(feature);
    }

    return Ok(fc);

}

```
#### 建立某點位的 buffer
注意這邊需要使用低階函示庫 [NetTopologySuite.IO.GeoJSON](https://www.nuget.org/packages/NetTopologySuite.IO.GeoJSON)
```
Install-Package NetTopologySuite.IO.GeoJSON -Version 2.0.3
```
需要特別注意 GeoJson.Net 的規範比較嚴格 , 故需要加入 FeatureCollection 讓 NetTopologySuite 的物件轉換為符合 GeoJson.Net 規範的格式
``` csharp
//建議寫成service抽離
private FeatureCollection getBufferGeoJson(double lon, double lat, int meter = 100)
{
	NetTopologySuite.Geometries.Point center =
		new NetTopologySuite.Geometries.Point(lon, lat);
	//設定正規化單位(meter)
	//注意這段我沒有詳細驗證單位最後是否正確不過結果看起來應該是對的
	double normalize = 0.00001;
	var buffer = center.Buffer(meter * normalize);

	//轉換低階的 geojson 讓其符合 geojson.net 的規格
	//主要就是要有 geojson 內的 properties
	NetTopologySuite.Features.Feature feature = new NetTopologySuite.Features.Feature();
	feature.Geometry = buffer;
	feature.Attributes = new NetTopologySuite.Features.AttributesTable();
	NetTopologySuite.Features.FeatureCollection fc = new NetTopologySuite.Features.FeatureCollection();
	fc.Add(feature);

	GeoJsonWriter writer = new GeoJsonWriter();
	var geojson = writer.Write(fc);

	//轉換為 geojson.net 的 geojson 格式
	var result = JsonConvert.DeserializeObject<FeatureCollection>(geojson);
	return result;
}

//包裝為 api 吐出 buffer geojson
[HttpGet("BufferGeoJson/{lon}/{lat}/{meter}")]
public ActionResult<FeatureCollection> GetBufferGeoJson(double lon, double lat, int meter = 100)
{
	try
	{
		var result = getBufferGeoJson(lon, lat, meter);
		return Ok(result);
	}
	catch (Exception ex)
	{
		logger.LogError(ex.Message);
		return Problem(ex.Message);
	}
}
```

#### .net 6
如果是 `.net 6` 則是安裝以下套件

* `GeoJSON.Net` 

* `Microsoft.AspNetCore.Mvc.NewtonsoftJson` 這個要注意下版本選 `6.x`

* `Swashbuckle.AspNetCore.Newtonsoft` 這個也要裝 , 不然 swagger 沒辦法正確吃到

因為 `GeoJSON.Net` 要吃 `NewtonsoftJson` 所以調整 `Program.cs`

然後把程式碼改成以下這樣 , 他才會正確吃到 `NewtonsoftJson`

`Program.cs`
``` csharp
using Newtonsoft.Json.Serialization;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers().AddNewtonsoftJson(opt =>
{
    opt.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    opt.SerializerSettings.ContractResolver = new CamelCasePropertyNamesContractResolver();
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddSwaggerGenNewtonsoftSupport();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseAuthorization();

app.MapControllers();

app.Run();

```

另外如果要讓你的 ip 在測試可以被打到的話可以加入下面設定 , 修改 `launchSetting.json` 加入後面 `0.0.0.0` 的部分
```
"applicationUrl": "https://localhost:3001;http://localhost:3000;https://0.0.0.0:3001;http://0.0.0.0:3000",
```
