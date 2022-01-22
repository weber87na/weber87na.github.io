---
title: webform 加入 webapi
date: 2021-12-18 16:51:40
tags: c#
---
&nbsp;
<!-- more -->

### 起手式
因為要幫人救火 webform 的案子 , 真低可憐 , 筆記一下 , 久沒弄這些都忘光光
主要參考[這篇官方](https://docs.microsoft.com/zh-tw/aspnet/web-api/overview/getting-started-with-aspnet-web-api/using-web-api-with-aspnet-web-forms)
我多新增兩個資料夾分別為 `Controllers` `Models` 讓習慣跟 mvc 上一致
加入測試類別
`LaSai`
```
public class LaSai
{
	public int Id { get; set; }
	public string Name { get; set; }
}
```

接著加入 web api controller `LaSaiController`
```
public class LaSaiController : ApiController
{
	List<LaSai> LaSais = new List<LaSai>
	{
		new LaSai { Id = 1, Name = "La Di Sai" },
		new LaSai { Id = 2, Name = "La Sai" },
		new LaSai { Id = 3, Name = "GG" }
	};

	[HttpGet]
	public IEnumerable<LaSai> GetAll()
	{
		return LaSais;
	}

	[HttpGet]
	public LaSai Get(int id)
	{
		var product = LaSais.FirstOrDefault((p) => p.Id == id);
		if (product == null)
		{
			throw new HttpResponseException(HttpStatusCode.NotFound);
		}
		return product;
	}
}
```

### 設定
接著加入類別 `WebApiConfig` 如果沒有 CORS 問題的話可以無視 `EnableCrossSiteRequests` 這串
如果有的話參考[官網](https://docs.microsoft.com/zh-tw/aspnet/web-api/overview/security/enabling-cross-origin-requests-in-web-api) 跟[這篇](https://stackoverflow.com/questions/29024313/asp-net-webapi2-enable-cors-not-working-with-aspnet-webapi-cors-5-2-3)
另外有個雷 visual studio 會給你跳出要你安裝 .net core 的套件要特別注意
在 nuget 選擇舊版套件 `Microsoft.AspNet.WebApi.Cors` 才對
另外需要用 Route Attribute 的話記得要設定 `config.MapHttpAttributeRoutes( );` 把他放在前面不然也不起作用
```
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {
            EnableCrossSiteRequests( config );
            AddRoutes( config );
        }

        private static void AddRoutes(HttpConfiguration config)
        {
            //這串要在 MapHttpRoute 前面
            config.MapHttpAttributeRoutes( );

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }

        private static void EnableCrossSiteRequests(HttpConfiguration config)
        {
            var cors = new EnableCorsAttribute(
                origins: "*",
                headers: "*",
                methods: "*" );
            config.EnableCors( cors );
        }
    }

```

最後設定 `Global.asax`
有個地雷 `WebApiConfig.Register(GlobalConfiguration.Configuration);`
要改寫成這樣 `GlobalConfiguration.Configure( WebApiConfig.Register );` 參考[這篇](https://stackoverflow.com/questions/19969228/ensure-that-httpconfiguration-ensureinitialized)
最後看看要不要直接移除 xml 輸出 , 不然預設好像是給 xml 可以[參考這篇](https://stackoverflow.com/questions/9847564/how-do-i-get-asp-net-web-api-to-return-json-instead-of-xml-using-chrome)
```
public class Global : HttpApplication
{
	void Application_Start(object sender, EventArgs e)
	{
		//web api 設定
		GlobalConfiguration.Configure( WebApiConfig.Register );

		//這樣寫繪陣亡
		//WebApiConfig.Register(GlobalConfiguration.Configuration);


		// Code that runs on application startup
		RouteConfig.RegisterRoutes( RouteTable.Routes );
		BundleConfig.RegisterBundles( BundleTable.Bundles );

		//remove xml
		//https://stackoverflow.com/questions/9847564/how-do-i-get-asp-net-web-api-to-return-json-instead-of-xml-using-chrome
		GlobalConfiguration.Configuration.Formatters.XmlFormatter.SupportedMediaTypes.Clear( );
	}
}
```

### 測試
最後用 js 簡單測試看看
```
<!doctype html>
<html lang="zh-Hant">

<head>
    <meta charset="utf-8">
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.js"></script>
    <title>test</title>
</head>

<body>
    <script>
    $.ajax({
        url: 'http://localhost:12345/api/lasai/1',
        // data: data,
        success: function(resp){
            console.log(resp);
        },
    });

    $.ajax({
        url: 'http://localhost:12345/api/lasai',
        // data: data,
        success: function(resp){
            console.log(resp);
        },
    });
    </script>
</body>

</html>
```

