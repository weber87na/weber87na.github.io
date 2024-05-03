---
title: 升級 asp.net mvc to asp.net core
date: 2024-03-31 00:04:05
tags: csharp
---
&nbsp;
<!-- more -->

### YARP & SystemWebAdapter
我之前都是升級 `web api` `定時排程` `entity framework` 還有些 `底層類別` 不過也都一一克服逐步上線 , 可以看這篇[筆記](https://www.blog.lasai.com.tw/2023/12/28/net-framework-4-8-to-net-core-%E7%AD%86%E8%A8%98/)
現在也研究看看要如何將整個 asp.net mvc 網站升級上去到 .net core

找了些資源後發現有 [.NET Upgrade Assistant](https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.upgradeassistant) 這個 extension
開來玩看看 , 礙於專案實在太大又亂馬上陣亡

不過倒是發現兩個關鍵 [YARP](https://microsoft.github.io/reverse-proxy/) 跟 [systemweb-adapters](https://github.com/dotnet/systemweb-adapters)
`YARP` 是用 c# 寫的 Reverse Proxy 類似 `nginx` `envoy` 的作用 , 不過他可以很好的在 .net core 專案裡面直接用程式碼的方式來設定代理
`systemweb-adapters` 這個東西也滿猛的 , 他可以讓 asp.net mvc 的 HttpContext Session Identity 等讓 .net core 吃到
這兩者搭起來如果有實作了 asp.net mvc 的路由的話 , 會被轉到 .net core 的 controller , 反之會沿用 asp.net mvc 原本的 controller
不過他的文件還是滿難啃的一個閃神就設定失敗 XD
可以看看以下這幾個關鍵連結

https://learn.microsoft.com/zh-tw/aspnet/core/migration/inc/overview?view=aspnetcore-8.0
https://www.youtube.com/watch?v=zHgYDZK3MrA&list=PLdo4fOcmZ0oWiK8r9OkJM3MUUL7_bOT9z
https://github.com/mjrousos/UpgradeSample
https://github.com/dotnet/systemweb-adapters/tree/main/samples

記錄下我測試 Identity 的過程
先開個 asp.net mvc 的站台 , 然後啟用身分認證 , 接著安裝 `Microsoft.AspNetCore.SystemWebAdapters` `Microsoft.AspNetCore.SystemWebAdapters.FrameworkServices`

關鍵要在 `web.config` 上面設定這段 , 如果要開 Session 好像還要設定別的模組 , 正常這段他會幫你自動加
可是我公司專案好像是使用新版的設定 , 所以不會自動加上去 , 整個暴雷
```
<system.webServer>
    <modules>
		<remove name="SystemWebAdapterModule" />
		<add name="SystemWebAdapterModule" type="Microsoft.AspNetCore.SystemWebAdapters.SystemWebAdapterModule, Microsoft.AspNetCore.SystemWebAdapters.FrameworkServices" preCondition="managedHandler" />
    </modules>
</system.webServer>
```

然後在 `Global.asax.cs` 加上這串 , 他這裡還可以設定 Session 等其他進階用法 , 暫時沒玩到
ApiKey 需要是 guid , 稍後在 .net core 專案也要用一樣的 key 這樣才會正常連線
``` csharp
    public class MvcApplication : System.Web.HttpApplication
    {
        protected void Application_Start()
        {
            AreaRegistration.RegisterAllAreas();
            FilterConfig.RegisterGlobalFilters(GlobalFilters.Filters);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            BundleConfig.RegisterBundles(BundleTable.Bundles);

            SystemWebAdapterConfiguration.AddSystemWebAdapters(this)
                .AddProxySupport(options => options.UseForwardedHeaders = true)
                .AddRemoteAppServer(options => options.ApiKey = "25E65A2D-AFD2-4024-8C24-A81F8E9C5465")
                .AddAuthenticationServer();
        }
    }
```

接著開個 .net core mvc 新專案 , 安裝 `YARP` `Microsoft.AspNetCore.SystemWebAdapters` `Microsoft.AspNetCore.SystemWebAdapters.CoreServices` 這三個套件

這裡有一點要注意 , 如果你的 asp.net mvc 網站是放在 `subsite` 底下的話 網址應該會長這樣 `http://localhost:58588/ladisai`
這時候要設定 `RemoteAppUrl` 為 `http://localhost:58588/ladisai` 才能吃到 HttpContext , 如果你設定 `http://localhost:58588` 這樣的話會直接 GG 他會得到 null 被這個雷搞超久

Program 設定如下
``` csharp
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddReverseProxy().LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

// Add services to the container.
builder.Services.AddControllersWithViews();
builder.Services
    .AddSystemWebAdapters()
    .AddRemoteAppClient(options =>
    {
        //options.RemoteAppUrl = new(builder.Configuration["ReverseProxy:Clusters:fallbackCluster:Destinations:fallbackApp:Address"]);

        //注意這句要寫你的 asp.net mvc 站台 HttpContext 位置他跟 YARP Proxy 無關
        //建議不要用 YARP Proxy 裡面的設定
        options.RemoteAppUrl = new("http://localhost:58588/ladisai");
        options.ApiKey = builder.Configuration["RemoteAppApiKey"];
    })
    .AddAuthenticationClient(true);

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.UseSystemWebAdapters();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.MapReverseProxy();

app.Run();

```

`RemoteAppApiKey` 稍早我們在 asp.net mvc 上面設定的 key

`appsetting.json`
``` json
{
  "RemoteAppApiKey": "25E65A2D-AFD2-4024-8C24-A81F8E9C5465",
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ReverseProxy": {
    "Routes": {
      "fallbackRoute": {
        "ClusterId": "fallbackCluster",
        "Order": "1",
        "Match": {
          "Path": "{**catch-all}"
        }
      }
    },
    "Clusters": {
      "fallbackCluster": {
        "Destinations": {
          "fallbackApp": {
            "Address": ""
          }
        }
      }
    }
  }
}

```


這個裡面的 `ReverseProxy__Clusters__fallbackCluster__Destinations__fallbackApp__Address` 表示舊專案 asp.net mvc 的網址

`launchSettings.json`
``` json
{
  "$schema": "http://json.schemastore.org/launchsettings.json",
  "iisSettings": {
    "windowsAuthentication": false,
    "anonymousAuthentication": true,
    "iisExpress": {
      "applicationUrl": "http://localhost:2762",
      "sslPort": 0
    }
  },
  "profiles": {
    "http": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "http://localhost:5180",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ReverseProxy__Clusters__fallbackCluster__Destinations__fallbackApp__Address": "https://localhost:44350"
      }
    },
    "IIS Express": {
      "commandName": "IISExpress",
      "launchBrowser": true,
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development",
        "ReverseProxy__Clusters__fallbackCluster__Destinations__fallbackApp__Address": "https://localhost:44350"
      }
    }
  }
}

```

最後隨便蓋一個 controller 然後先登入到 asp.net mvc 的網站 , 接著呼叫這隻 .net core 的 controller 看看是否正常拿到值即可
```
    public  class Test : Controller
    {
        [Route("/Test")]
        public IActionResult Test()
        {
            var name = this.User.Identity.Name;
            return Ok();
        }
    }

```

今天實驗一個之前很困惑的問題 , 如果登入走 OIDC/OAuth2 的話最後不還是會 redirect 回去本來的舊站台嗎 , 經過實驗測試只要在 identityserver 把 redirect 的地方換成 yarp 的路徑就成功了 @@!

### WebOptimizer

如果以前專案使用如 jquery angularjs vue1 vue2 等等 , 很有可能前後端會混合使用 , 這時候就需要 [WebOptimizer](https://github.com/ligershark/WebOptimizer)
可以[參考這影片](https://www.youtube.com/watch?v=SmP38AW4KkY)
這裡可以把本來的 `Content` `Scripts` `Images` 等靜態資源搬進專案
注意不是放在 `wwwroot` 而是跟原本一樣階層原封不動搬過來

```
builder.Services.AddWebOptimizer(pipeline => {

    pipeline.AddJavaScriptBundle("/js/bundle",
        "Scripts/" + "jquery-3.7.0.min.js",
        "Scripts/" + "jquery-ui-1.12.1.js"
        ).UseContentRoot();

    pipeline.AddCssBundle("/css/bundle",
        "Content/" + "jquery-ui-1.12.1/jquery-ui.min.css",
        "Content/" + "jquery-ui-1.12.1/theme.css"
        ).UseContentRoot();

});
```
注意到 `UseWebOptimizer` 要在 `UseStaticFiles` 之前
```
//UseWebOptimizer 要在 StaticFiles 之前
app.UseWebOptimizer();
app.UseStaticFiles();
```

另外因為 legacy 難免有些髒髒的 code , 為了防止 bundle 以外的資源被引用的話 , 可以設定這樣
```
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(Directory.GetCurrentDirectory(), "Content")),
    RequestPath = "/Content"
});
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(Directory.GetCurrentDirectory(), "Scripts")),
    RequestPath = "/Scripts"
});
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(
        Path.Combine(Directory.GetCurrentDirectory(), "Images")),
    RequestPath = "/Images"
});

```

接著引用的部分舊版有 `Scripts.Render` `Styles.Render` 但是 .net core 已經沒了
```
@Scripts.Render("~/js/xxx")
@Styles.Render("~/css/xxx")
```

.net core 返璞歸真
```
<script src="~/js/xxx"></script>
<link rel="stylesheet" href="~/css/xxx" />
```

### subsite 問題
如果你的 asp.net mvc 5 站台跑在 subsite 的話應該還需要以下設定 , 參考[這裡](https://microsoft.github.io/reverse-proxy/articles/transforms.html)
```
builder.Services.AddReverseProxy().LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"))
    .AddTransforms(builderContext =>
    {
        //這裡與 basepath 好像都要設定
        //這裡應該要設定才不會多一層 YOURSUBSITENAME 變為 YOURSUBSITENAME/YOURSUBSITENAME
        //等價於設定 appsettings.json 裡面的 PathRemovePrefix
        builderContext.AddPathRemovePrefix("/YOURSUBSITENAME");
    });
```

這個設定還需要搭配 `UsePathBase`
```
app.UsePathBase("/YOURSUBSITENAME");
```


如果要在 `appsettings.json` 設定也可以
```
  "ReverseProxy": {
    "Routes": {
      "fallbackRoute": {
        "ClusterId": "fallbackCluster",
        "Order": "1",
        "Match": {
          "Path": "{**catch-all}"
        }
      },
      "MvcWebNetFramework": {
        "ClusterId": "MvcWebNetFramework",
        "Match": {
          "Path": "{**catch-all}"
        },
        "Transforms": [
          { "PathRemovePrefix": "/assemblyline" }
        ]
      }
    },
    "Clusters": {
      "MvcWebNetFramework": {
        "Destinations": {
          "MvcWebNetFramework/destination1": {
            "Address": "http://localhost:5987/YOURSUBSITENAME"
          }
        }
      },
      "fallbackCluster": {
        "Destinations": {
          "fallbackApp": {
            "Address": ""
          }
        }
      }
    }
  }

```

後來發現只要在 `environmentVariables` 底下設定 `ASPNETCORE_URLS` 就可以不用額外設定 `UsePathBase`
可以參考[這篇](https://github.com/dotnet/aspnetcore/issues/1682)

### Json.Encode 解法
舊版
```
var currentLang = @Html.Raw(Json.Encode((string)ViewData["CurrentLang"]));
```

.net core
```
var currentLang = @Html.Raw(JsonConvert.SerializeObject((string)ViewData["CurrentLang"]));
```


### 多語系切換

可以參考[這裡](https://learn.microsoft.com/zh-tw/aspnet/core/fundamentals/localization/select-language-culture?view=aspnetcore-8.0)
這個新舊寫法好像不太一樣  `CookieRequestCultureProvider.DefaultCookieName` 這個值為 `.AspNetCore.Culture`
然後要用 `CookieRequestCultureProvider.MakeCookieValue` 來建立才會正常

```
[AllowAnonymous]
[Route("switch-lang-core/{lang?}")]
[HttpGet]
public IActionResult SwitchLang(string lang = null)
{
	Response.Cookies.Append("MyLang", lang);
	Response.Cookies.Append(
		CookieRequestCultureProvider.DefaultCookieName,
		CookieRequestCultureProvider.MakeCookieValue(new RequestCulture(lang))
	);
	string referrerUrl = Request.Headers["Referer"].ToString();
	return Redirect(referrerUrl);
}

```

### ControllerBase 沒辦法接收到 Model 參數的問題
無意中發現 , 如果只用 ControllerBase 好像沒辦法收到 view 傳進來的參數
但加上 [ApiController] 這個 Attribute 就能動了

```
[ApiController]
public QQController : ControllerBase {
	public void Save(QQ model){}
}
```

### .net framework AddSystemWebAdapters 沒辦法取得 identity
這個問題滿雷的 , 花了不少時間才發現
使用 SystemWebAdapters 要特別注意到套件是否有 conflicts 這裡如果發生 conflicts 會造成 null 完全讀不出來 identity 的狀況

```
Warning		Found conflicts between different versions of the same dependent assembly. 
In Visual Studio, double-click this warning (or select it and press Enter) to fix the conflicts; 
otherwise, add the following binding redirects to the "runtime" node in the application configuration file: 
<assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
	<dependentAssembly>
		<assemblyIdentity name="Microsoft.Extensions.Logging" culture="neutral" publicKeyToken="adb9793829ddae60" />
		<bindingRedirect oldVersion="0.0.0.0-8.0.0.0" newVersion="8.0.0.0" />
	</dependentAssembly>
</assemblyBinding>
```

### wwwroot & UsePathBase 資源讀不到的問題

今天測的時候發現如果把本來的 `Scripts` `Content` 移動到 `wwwroot` 裡面的話搭配  `UsePathBase` 會出問題
好像要調整 `UseStaticFiles` 如下才會正常
```
#if DEBUG
    //這裡要設定 RequestPath 不然有設定 UsePathBase 會吃不到
    //https://learn.microsoft.com/en-us/answers/questions/800998/why-js-css-lib-didnt-load-from-wwwroot
    app.UseStaticFiles(new StaticFileOptions
    {
        RequestPath = "/lasai"
    });
    app.UsePathBase("/lasai");
#else
    app.UseStaticFiles();
#endif

```
