---
title: 常見的 asp.net core 低能問題
date: 2021-04-16 20:23:48
tags: asp.net core
---
&nbsp;
<!-- more -->

這篇是因為三不五時又被抓回來寫後端搞的 , 一下子 .net framework 一下子 .net core 我都搞不太清楚在寫啥
有遇到問題就順手紀錄看看


### ABP 手動建立 controller
以前沒用過 ABP framework , 有機會剛好用看看 , 它裡面有個 auto api controller 機制
只要繼承 `IApplicationService` 就可以自動讓 Service 去產生 api , 跟之前用 java 的 spring 有個懶人用法類似
但是沒講怎麼手動建立 , 實際上在專案底下有 `XXX.XXX.HttpApi` 這個方案
直接在裡面加上 controller 即可
```
public class XXXApiController : AbpController{
	//todo
}
```


### 一次 POST 多筆資料 count 永遠為零

久沒寫 web api 了 , 今天遇到一個靈異事件 , post 多筆資料 countr 永遠為零 , 可能之前多半丟單一個 DTO 上來而已
關鍵在於要加上 [FromBody] 這樣才收得到
順便一提如果是用 abp 插入的話不用特別加上 [FormBody] 就可以吃到參數 , 靈異 ~

錯誤
```
[HttpPost( "Hello" )]
public IActionResult Hello(List<DTO> test)
{
	return Json( test );
}
```

正確
```
[HttpPost( "Hello" )]
public IActionResult Hello([FromBody] List<DTO> test)
{
	return Json( test );
}
```



### Missing type map configuration or unsupported mapping.

今天炸了忘了加 auto mapper 的問題 , 筆記一下
```
Mapping types:
Object -> SfcStationDto
System.Object -> Sunon.Cim.Sfc.SfcStationDto
```

首先要知道 return 的型別為後面那個 , 像是下面這樣
```
StationDto result = ObjectMapper.Map<Station, StationDto>( station );
```

所以要在 MapperProfile 裡面定義這樣
```
public class StationAutoMapperProfile : Profile{
	public StationAutoMapperProfile(){
		CreateMap<Station, StationDto>();
	}
}
```


### 升級 .net 3.1 to .net 5
┏[User]
┖[~\source\repos\SportSln\SportsStore]> dotnet ef migrations add Orders
Could not execute because the application was not found or a compatible .NET SDK is not installed.
Possible reasons for this include:
  * You intended to execute a .NET program:
      The application 'ef' does not exist.
  * You intended to execute a .NET SDK command:
      A compatible installed .NET SDK for global.json version [3.1.101] from [C:\Users\User\source\repos\SportSln\SportsStore\global.json] was not found.
      Install the [3.1.101] .NET SDK or update [C:\Users\User\source\repos\SportSln\SportsStore\global.json] with an installed .NET SDK:
        5.0.201 [C:\Program Files\dotnet\sdk]
┏[User][xERROR]
┖[~\source\repos\SportSln\SportsStore]> dotnet ef migrations add Orders
Build started...
Build succeeded.
Done. To undo this action, use 'ef migrations remove'
┏[User]
┖[~\source\repos\SportSln\SportsStore]>



修改 `global.json`

修改前
```
{
  "sdk": {
    "version": "3.1.101"
  }
}
```

修改後
```
{
  "sdk": {
    "version": "5.0"
  }
}


```

`Project` => `Your Project Properties` => `Application` => `Target framework` => `5.0`

`Manage Nuget Packages` => `Update All`

### 怎麼取得 ControllerName or ActionName
```
var controllerName = ControllerContext.ActionDescriptor.ControllerName;
var action = ControllerContext.ActionDescriptor.ActionName;
```

### 怎麼取得 appsetting.json 內的值
首先在建構子先注入
```
public class LaSaiController{
	private readonly IConfiguration configuration;
	public LaSaiController(IConfiguration configuration){
		this.configuration = configuration;
	}

	public LaDiSai1(){
		return configuration["LaDiSai:Name"];
	}

	public LaDiSai2(){
		return configuration.GetValue<string>("LaDiSai:Name");
	}
}

```

appsetting.json
```
"LaDiSai" : {
	"Name" : "GG"
}
```


### 簡單粗暴動態切換 DB 連線字串

先隨便開個資料庫 , 然後安裝 EF Core Power Tools 可以省事很多
```
services.AddDbContext<TestDbContext>(
	options => options.UseSqlServer( getConnectionString(code) )
	);

```

```
private string getConnectionString(string code)
{
	switch (code)
	{
		case "test":
			return "name=ConnectionStrings:TestDbContext";
		case "test2":
			return "name=ConnectionStrings:Test2DbContext";
		default:
			return "name=ConnectionStrings:TestDbContext";
	}
}

```

appsetting.json
```
  "ConnectionStrings": {
    "TestDbContext": "ooxx",
    "Test2DbContext": "xxoo",
  },

```


### 正確取得 DB 連線字串
```
Configuration.GetConnectionString("OOXXConnection")
```


### 多個類別繼承同個 interface 怎麼注入 DI

[參考 RICO 大師](https://medium.com/ricos-note/how-to-register-and-inject-multiple-implementations-of-a-same-interface-c2ac518db459)
```
public void ConfigureServices( IServiceCollection services )
{
	//因為之前寫原生的 .net core 2.x 無法像 Unity DI framework 有具名的 DI 注入方法 , 這邊參考 rico 大師的文章 , 分別注入 目前表以及歷史表的 repository
	//參考如何使用具名的 DI 方法

	services.AddScoped< TestRepository>()
	.AddScoped<ITestRepository, TestRepository>( s => s.GetRequiredService<TestRepository>() );
}
```

Service
```
        private readonly ITestRepository testRepository;
        private readonly ITestRepository testHistoryRepository;
        private readonly IServiceScopeFactory serviceScopeFactory;
        public ManoBarcodeService(IServiceScopeFactory serviceScopeFactory
            )
        {
            this.serviceScopeFactory = serviceScopeFactory;
            var ser = serviceScopeFactory.CreateScope().ServiceProvider;

            this.testRepository = ser.GetRequiredService<TestRepository>();
            this.testHistoryRepository = ser.GetRequiredService<TestHistoryRepository>();
        }
```

後來在 .net 6 發現可以這樣寫
```
        public BeforeStationController(IEnumerable<IStationRepository> stationRepositories)
        {
            _stationRepository = stationRepositories.FirstOrDefault(x => x.GetType() == typeof(BeforeStationRepository));
        }
```


### 找不到 ToXXOOAsync 非同步方法

某天低能要改寫常見的 GetAll 方法 , 讓他變成 Async , 結果一時找不到 , 其實只要引用以下命名空間就好
```
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
```

### 怎麼讓在內網的同事也看得到你現在測試的結果
調整 `launchSettings.json` 內的 `applicationUrl` 加入 `https://0.0.0.0:3001;http://0.0.0.0:3000` 即可
```  
  "profiles": {
    "DemoApi": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "launchUrl": "swagger",
      "applicationUrl": "https://localhost:3001;http://localhost:3000;https://0.0.0.0:3001;http://0.0.0.0:3000",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
```

### 簡單指定 port 測試程式

cd 到 .net5 資料夾底下
```
dotnet OOXX.dll --urls "http://localhost:7887"
```

### 怎麼用 HttpClient 撈遠端資料
Startup.cs
```
public void ConfigureServices( IServiceCollection services )
{
	//...
	services.AddHttpClient();
}
```

```
private readonly IHttpClientFactory clientFactory;
public TestController(
	IHttpClientFactory clientFactory
	){

	[HttpGet]
	public async Task< ActionResult<List<Test>>> GetAll()
	{
		var client = clientFactory.CreateClient();
		var url = $"http://xxoo";
		var resp =  await client.GetAsync( url );
		if (resp.IsSuccessStatusCode)
		{
			var stream = await resp.Content.ReadAsStringAsync();
			var result = JsonSerializer.Deserialize<List<Test>>( stream );
			return result;
		}
		else
		{
			return NotFound();
		}
	}
}
```

### 執行 .net core 結束後關閉惱火的 console 視窗
`工具` => `選項` => `偵錯` => `偵錯停止時，自動關閉主控台`
`Tools` => `Options` => `Debugging` => `Automatcilly close the console when debugging stops`

### 關閉產生 xml 文件造成賭爛的 Missing XML comment for publicly visible type or member
在 csproj 萬一設定了產生 xml 文件的話 , 常常會跳這個賭爛錯誤 , 只要加上 `NoWarn` 區塊即可消除煩人的綠毛蟲
```
  <PropertyGroup Condition="'$(Configuration)|$(Platform)'=='Debug|AnyCPU'">
    <DocumentationFile>bin\GG.xml</DocumentationFile>
	  <NoWarn>$(NoWarn);1591</NoWarn>
  </PropertyGroup>
```


### 其他 developer 懶得看文件 , 不會用 api 的 swagger 解法
常常文件寫了一狗票 , 然後突然一個需求變更就直接 gg 了 , 所以每個人在測試時根本懶得看文件
[可以考慮加入](https://github.com/mattfrear/Swashbuckle.AspNetCore.Filters) 直接做個 example 讓 user 測試比較實際
```
Swashbuckle.AspNetCore.Filters
```

Startup.cs
```
services.AddSwaggerGen();
services.AddSwaggerExamplesFromAssemblies(Assembly.GetEntryAssembly());
//...
```

一般類別只要無腦寫 xml 註解時加入 example 區塊即可
```
public class GG
{
	/// <summary>
	/// 編號
	/// </summary>
	/// <example>oxoxgggg</example>
	[JsonPropertyName("GGID")]
	public string GGID { get; set; }
}
```

controller 類別
```
/// <summary>
/// 懶得寫
/// </summary>
/// <param name="id" example="oxoxgggg">GGID</param>
/// <returns></returns>
[HttpGet]
[Route("gg/{id}")]
public async Task< ActionResult<List<GG>>> GetAll()
{
	//...
}
```

### 如何在Repository內使用Configuration
設定注入
```
public void ConfigureServices( IServiceCollection services ){
	//注入 Configuration 讓 repository 使用 , 因為是 global 所以直接用單例就好
	services.AddSingleton( _ => Configuration );
}
```

注入到 Repository
```
private readonly IConfiguration configuration;
public GGRepository(IConfiguration configuration )
{
	this.configuration = configuration ?? throw new System.ArgumentNullException( nameof( configuration ) );

}
```
