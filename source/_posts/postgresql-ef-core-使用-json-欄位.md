---
title: postgresql ef core 使用 json 欄位
date: 2024-06-02 17:49:44
tags: c#
---

&nbsp;
<!-- more -->

佛心幫朋友爬資料遇到的問題, 朋友想爬老外的資料, 研究下是前後分離架構, 從 `OAuth` 打 `api`, 預設會用 `OData` 丟個肥大的巢狀 `json` 回來

```json
{
    "id": "1xz3x938-x386-41x2-x922-aaxxxb21caee",
    "date": "2021-01-12T01:16:37Z",
    "temperature": 53.5,
    "powerStatus": {
        "id": "Ok",
        "displayName": "Ok"
    },
	"power" : 1.23,
    "battery": 4.39,
    "company": {
        "id": "3212x5c0-6700-o779-o6a5-dx16626x7fzz",
        "name": "QQ"
    },
    "readingValues": {
        "AC": {
            "value": 0,
            "description": "ooxx",
            "realValue": "Volts",
            "valueClass": "Reading",
            "rmuSlot": 5,
            "display": 2
        },
		"DC" : {
		
		}
	}
}
```

可以到這些網站讓他轉為類別
https://transform.tools/json-to-typescript
https://quicktype.io/typescript
https://www.codeconvert.ai/typescript-to-csharp-converter

特別注意類別屬性要用 JsonPropertyName 去指定, 不然會得到 null, 如果用 Newtonsoft 則是 JsonProperty

```c#
public class AcLineStatus
{
    [JsonPropertyName("id")]
    public string Id { get; set; }

    [JsonPropertyName("displayName")]
    public string DisplayName { get; set; }
}
```

分析完後建立資料表, 這裡命名時要注意下, 因為 ef core 會用 .net 風格的命名
如果想用 `postgresql` 風格的話, 可以考慮安裝 [EFCore.NamingConventions](https://github.com/efcore/EFCore.NamingConventions)

```sql
create database crawler;
create table station (
	id uuid primary key,
	data_row json
);
```

可以在 `Program` 設定 `NamingConvention`, 另外想看到丟什麼參數進去要把 `EnableSensitiveDataLogging` 打開

```c#
builder.Services.AddDbContext<CrawlerDbContext>(options =>
{
    options.UseNpgsql(builder.Configuration.GetConnectionString("PG"));
    options.UseSnakeCaseNamingConvention();
    //options.UseLowerCaseNamingConvention();
    options.EnableDetailedErrors();
    options.EnableSensitiveDataLogging();
});
```

研究下發現 `ef core 7` 有 `ToJson` 這個[新功能](https://learn.microsoft.com/zh-tw/ef/core/what-is-new/ef-core-7.0/whatsnew)
可是這個情境因為 `json` 太過巢狀用起來卡手卡腳, 最後放棄還是改回 `string` 的用法, 如果 `json` 不複雜的話倒是可以玩看看
不過他有個問題就是沒法指定資料庫的 `ColumnName` 例如這裡寫 `JsonDataRow`, 資料庫欄位也要一致, 也可能我沒找到

```c#
protected override void OnModelCreating(ModelBuilder modelBuilder)
{

	modelBuilder.Entity<Station>(x =>
	{
		x.OwnsOne(x => x.JsonDataRow, builder =>
		{
			builder.ToJson();
		});
	});

	OnModelCreatingPartial(modelBuilder);
}

public class Station {
	public Guid Id {get;set;}
	pbulic JsonDataRow JsonDataRow {get;set;}
}
```

如果要用 `string` 則這樣寫
```c#
public class JsonDataRow {
	public Guid Id {get;set;}
	pbulic string JsonDataRow {get;set;}
}

[ApiController]
[Route("[controller]")]
public class StationController : ControllerBase
{
    private CrawlerDbContext db;
    public StationController(CrawlerDbContext db)
    {
        this.db = db;
    }

    [HttpGet]
    public IActionResult Get()
    {
        var result = db.Station.ToList();
        var list = new List<Station>();
        foreach (var item in result)
        {
            var json = JsonSerializer.Deserialize<JsonDataRow>(item.JsonDataRow);
            list.Add(json);
        }
        return Ok(list);
    }

}
```

