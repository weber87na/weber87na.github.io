---
title: asp.net core odata 筆記
date: 2024-02-19 17:55:35
tags: c#
---
&nbsp;
<!-- more -->

被朋友凹的咚咚, 因為平常已經累得很狗沒兩樣, 也沒那美國時間寫一堆客製化的 api, 想說偷懶插個 OData 模組來減輕開發負擔
不過因為資料結構是存 json 所以沒辦法發揮 OData 更強的威力, 資料筆數少的話才可以這樣搞, 就是前端免額外處理一堆複雜的 filter 或排序, 直接用 OData 下即可
玩一玩覺得 OData 這東西不錯啊, 不曉得為何沒多少人在用, 甚至聽都沒聽過 @. @

### 安裝及設定
安裝的部分要注意的應該就是 json 要丟 .net 8 預設的還是要用 NewtonsoftJson
另外我是用 postgresql, 所以搞 ef core 資料表可能會需要用 EFCore.NamingConventions 才能符合 coding style

```
dotnet add package Microsoft.AspNetCore.OData
dotnet add package Microsoft.AspNetCore.OData.NewtonsoftJson
dotnet add package EFCore.NamingConventions
```

實作可以參考[官網](https://learn.microsoft.com/en-us/odata/webapi-8/getting-started?tabs=net60%2Cvisual-studio-2022%2Cvisual-studio), 如果沒有巢狀 json 的話應該就還好, 巢狀還要下 expand, 感覺滿複雜 QQ

因為我是偷懶在 postgresql 直接用 json 存爬回來的資料, 所以 model 相對單純

```c#
[Table("qq")]
public class QQ
{
    [Column("id")]
    public Guid Id { get; set; }

    [Column("datarow")]
    public string DataRow { get; set; }

}

public class DataRow
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("readingDate")]
    public string ReadingDate { get; set; }

    [JsonPropertyName("temperature")]
    public double? Temperature { get; set; }
}
```

Program 設定也滿簡單, 看要開哪些 OData 操作的功能就加上去, 在這前端哀東哀西的年代, 串起來就是省事, 快樂收工 XD

```c#
var modelBuilder = new ODataConventionModelBuilder();
modelBuilder.EntitySet<DataRow>("DataRows");
modelBuilder.EnableLowerCamelCase();

builder.Services.AddDbContext<CrawlerDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("QQ"));
    options.UseSnakeCaseNamingConvention();
    options.EnableDetailedErrors();
    options.EnableSensitiveDataLogging();
});

builder.Services.AddControllers()
    .AddOData(options =>
    {
        options.Select()
               .Filter()
               .OrderBy()
               .Expand()
               .Count()
               .SetMaxTop(null)
               .AddRouteComponents("odata", modelBuilder.GetEdmModel());
    });

```

### controller 名稱地雷
因為我本來有一個 `QQController` 另外一個想用 `QQODataController` 這裡會雷到
需要自己在 `QQODataController` 上面去加上 [Route("odata")] 手動指定
另外這裡我有嘗試用 `IQueryable` 串 `Select Deserialize` 的結果, 不過 ef core 會噴錯, 如果有效能考量就不建議這樣寫, 單純只是偷懶用 ~

```csharp
[Route("odata")]
public class QQODataController : ODataController
{
    private CrawlerDbContext db;
    public QQODataController(CrawlerDbContext db)
    {
        this.db = db;
    }

    [EnableQuery]
    [HttpGet("DataRows")]
    public ActionResult<List<DataRow>> Get()
    {
        var result = db.QQ.ToList();
        var list = new List<DataRow>();
        foreach (var item in result)
        {
            var json = JsonSerializer.Deserialize<DataRow>(item.DataRow);
            list.Add(json);
        }
        return Ok(list);
    }
}
```

### 吐出 Json 大寫的問題
這個還滿地雷的, 就算用 .net 8 預設是大寫開頭, 看老外丟出來都是小寫開頭的風格, 查了一陣子發現要這樣設定

```c#
var modelBuilder = new ODataConventionModelBuilder();
modelBuilder.EntitySet<DataRow>("DataRows");
modelBuilder.EnableLowerCamelCase();
```

看有個老外這樣寫, 不過我試起來沒辦法, 就忘了它吧 XD

```
.AddJsonOptions(options =>
{
	options.JsonSerializerOptions.DictionaryKeyPolicy = JsonNamingPolicy.CamelCase;
})
```

### Debug 問題

因為對 OData 相對陌生, 查了下發現有這個選項 `UseODataRouteDebug`, 他會把路徑給列出來

```
var app = builder.Build();

app.UseODataRouteDebug();
```

### OData 語法範例
詳情可以看[官網文件](https://www.odata.org/)

只撈 Id Temperature

```
http://localhost:5000/odata/DataRows?select=Id,Temperature
```

羅列出欄位為 Id BatteryReading Temperature
並且篩選 Temperature 溫度大於 53
最後以 Temperature 排序

```
http://localhost:5000/odata/DataRows?select=Id,BatteryReading,Temperature&filter=Temperature%20gt%2053&orderBy=Temperature
```
