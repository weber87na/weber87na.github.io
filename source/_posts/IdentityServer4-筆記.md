---
title: IdentityServer4 筆記
date: 2022-09-27 19:12:51
tags: 
- sso
- .net 6
- c#
---
![identityserver4](https://identityserver4.readthedocs.io/en/latest/_images/logo.png)
<!-- more -->

因為接了個燙手山芋 , 要把 .net framework 升級到 .net 6 , 陳年的包袱不好搞 , 還要可以串 SSO , 所以筆記下
以前頂多就是串串 line login 自己內部網站要搞 SSO 還真沒頭緒 , 碰巧遇到 [保哥有開課](https://www.accupass.com/event/2202070459001516929761) 就自己丟錢去上
不過他這個課很講概念 , 後續沒自己實作一定陣亡 XD
如果不想花錢的話可以看 [這個大陸 MVP 教學](https://www.bilibili.com/video/BV16b411k7yM/?spm_id_from=333.337.search-card.all.click)
他的 [code 在此](https://github.com/solenovex/Identity-Server-4-Tutorial-Demo-Code)

我後來有做個 FineReport 串接 SSO 的 lab 有興趣也可以[參考看看](https://www.blog.lasai.com.tw/2023/03/08/FineReport-%E4%B8%B2%E6%8E%A5-Identity-Server-SSO-%E7%AD%86%E8%A8%98/)

### Skoruba identityserver4 Admin
純 IdentityServer4 是沒有 UI 去管理你的 Client , 如果要的話好像要付錢 , 所以有大神搞了個[免錢專案](https://github.com/skoruba/IdentityServer4.Admin)
老實說完全沒接觸過的話不太可能搞得起來 `OAuth 2.0` 實在複雜到暈頭轉向 , 廢話不多說實作先
他的文件 [在此](https://skoruba-identityserver4-admin.readthedocs.io/en/dev-doc/index.html)
```
git clone https://github.com/skoruba/IdentityServer4.Admin.git
```
clone 下來以後先在 `Solution` => `Properties` => `Common Properties` => `Startup Project` => `Multiple startup projects` 選單內
設定以下三個 `Skoruba.IdentityServer4.Admin` `Skoruba.IdentityServer4.Admin.Api` `Skoruba.IdentityServer4.STS.Identity` 為 Start 就能動了

#### Skoruba.IdentityServer4.Admin
https://localhost:44303/

這個做用是後臺 GUI , 也就是純 IdentityServer4 沒給你的東西 , 用這個可以管理你的 `Client`
他的帳號密碼是 `admin` `Pa$$word123` 其他詳細訊息可以在 `identitydata.json` or `identityserverdata.json` 這兩隻檔案找到

在 OAuth2.0 裡面 `Client` 可以看做 console app or web app 這類東西 , 類似 line api 後臺管理介面的概念
這個網站本身就是一個 `Client` 他也受到 `IdentityServer4.STS.Identity` 他進行保護 , 啟動後你的 localdb 會多一堆 table 之後再研究
點選 `https://localhost:44303/Configuration/Clients` 進去以後可以看到預設有兩個 client `skoruba_identity_admin_api_swaggerui` `skoruba_identity_admin`
接著點 `skoruba_identity_admin` => `Edit` => `Basic` 可以看到這個就是走 `authorization_code` 這個流程
另外有幾個重要的網址要記下 , 後續設定自己的 mvc 網站就要模仿這樣設定 , 如果近來看到中文的話右下角可以改成英文 , 不然翻譯的很鬼畜

`Redirect Uri` => `https://localhost:44303/signin-oidc`
`Front Channel Logout Uri ` => `https://localhost:44303/signout-oidc`
`Post Logout Redirect Uris ` => `https://localhost:44303/signout-callback-oidc`
`Allowed Cors Origins ` => `https://localhost:44303`
`Client Uri ` => `https://localhost:44303`

#### Skoruba.IdentityServer4.Admin.Api
https://localhost:44302/swagger/index.html

這個是他給的 swagger , 實作上暫時沒遇到要直接呼叫他

#### Skoruba.IdentityServer4.STS.Identity
https://localhost:44310/

這個等價於 IdentityServer4 的 STS (security token service) , 當你要設定你自己的網站受到保護時 , 要指向他 , 千萬不要設定錯了
剛開始不小心寫成 `https://localhost:44303/` 所以狂噴 Error
點選 `Discovery Document` 會跳到這個網址 `https://localhost:44310/.well-known/openid-configuration`
如果有在自己的 c# 程式上安裝 `IdentityModel` 這個套件的話他會自己去撈並且轉成類別 , 馬上收工
另外如果要讓登出以後回到自己的網站 , 可以改這個類別內的 `AutomaticRedirectAfterSignOut` 為 `true` 即可登出後回到自己網站
``` c#
    public class AccountOptions
    {
        public static bool AllowLocalLogin = true;
        public static bool AllowRememberLogin = true;
        public static TimeSpan RememberMeLoginDuration = TimeSpan.FromDays(30);

        public static bool ShowLogoutPrompt = true;
        public static bool AutomaticRedirectAfterSignOut = true;

        public static string InvalidCredentialsErrorMessage = "Invalid username or password";
    }

```

#### 實作 Client Credentials
這個比較簡單會用這個表示 `機器` 他不代表任何人 , 所以要走這個流程 , 說穿就是諸如 console 排程這類東西
這裡有個細節 , 如果你的 scope 寫 email openid 之類的會噴 error , 要記得先去新增 Api 自己的 scope

##### Identity Server 設定

先到 `https://localhost:44303/` => `Clients/Resources` => `Api Scopes`
`Add Api Scope` => `Name` => `DemoApiClientCredentials` => `Save Api Scope`
接著回到 `https://localhost:44303/`
`Add Client` => `Machine/Robot Client Credentials flow`
`ClientId` => `DemoApiClientCredentials`
`Allowed Scopes` => `DemoApiClientCredentials`
`Allowed Grant Types` => `client_credentials`
`Client Name` => `DemoApiClientCredentials` => `Save Client`
接著點 `Manage Client Secrets`
`Secret Value` => `DemoApiClientCredentials`
`Description` => `DemoApiClientCredentials`
`Add Client Secret`
另外注意到 `Access Token Lifetime` 預設 `token` 有效期限為 `3600 / 60 = 1hr` 視情況調整

##### 程式碼修正
首先安裝 `Microsoft.AspNetCore.Authentication.JwtBearer` 注意下版本 `6.0.16`

調整 `Program` , 多加一組給 `Jwt` 的設定在前面 , 最後 postman 呼叫時噴了個莫名其妙的錯誤 `the audience is invalid` , 可以參考[這篇](https://jscinin.medium.com/asp-net-core-3-1-%E7%B6%93jwt%E8%AA%8D%E8%AD%89%E5%BE%8C-post-api-%E9%8C%AF%E8%AA%A4%E8%A8%8A%E6%81%AF401-the-audience-is-invalid-39540ebe4b6e)處理
``` csharp
builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.Authority = "https://localhost:44310/";
        options.RequireHttpsMetadata = false;
        options.Audience = "DemoApiClientCredentials";

        //the audience is invalid
        //https://jscinin.medium.com/asp-net-core-3-1-%E7%B6%93jwt%E8%AA%8D%E8%AD%89%E5%BE%8C-post-api-%E9%8C%AF%E8%AA%A4%E8%A8%8A%E6%81%AF401-the-audience-is-invalid-39540ebe4b6e
        options.TokenValidationParameters = new TokenValidationParameters {
            ValidateIssuer = false,
            ValidateAudience = false,
        };
    });

```

最後在 `Controller` 上面加入 `[Authorize(AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]` 屬性即可

##### Postman 呼叫受保護的 Api
https://identityserver4.readthedocs.io/en/latest/endpoints/token.html
https://localhost:44310/.well-known/openid-configuration

`method` => `post`
`網址` => `https://localhost:44310/connect/token`
`content type` => `x-www-form-urlencoded`
`client_id` => `DemoApiClientCredentials`
`client_secret` => `DemoApiClientCredentials`
`grant_type` => `client_credentials`
`scope` => `DemoApiClientCredentials`

打出去後就得到下列結果

``` json
{
    "access_token": "eyJhbGciOiJSUzoxmtpZCI6000xxxEQTFFRURDNjNDQkVDNDY4N0Q5MzdDNThCM0ZBQjYxIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE2ODEzNTczMDAsImV4cCI6MTY4MTM2MDkwMCwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6NDQzMTAiLCJjbGllbnRfaWQiOiJEZW1vQXBpQ2xpZW50IiwiaWF0IjoxNjgxMzU3MzAwLCJzY29wZSI6WyJEZW1vQXBpQ2xpZW50Il19.CTV-fHoW9MYDMoPHGr5Xc9F1-9OJxLT84w18kdxZcFAr9BmtGW0LjYrAfZbnZCe6J1N_Wi5KsSHzsobeZc9MO6EhzFEe_48KsdM-qmYvY2NeQHMq0DM3RtHEflrN2lnICas0Vdv7HKGC3SLV0AipOAor6SSU8G3c_MDjZglQ-rz3rP-FwWVxWf1haJY2ZFEJYmdKuElNX2fbzpZRkiiSB82Bmudtec284hFfP1Wu4GLzY-3P6TKtbSyB0eH2YXHIgcqIjX5ZcIYCdMYmBlsngU34QHLgV-hD6m_3CNJFiKeR-jjBGxpZRYMZRYofxrld5iJp8lhQbbLzpwOTh6FmYw",
    "expires_in": 3600,
    "token_type": "Bearer",
    "scope": "DemoApiClientCredentials"
}
```

接著用 postman 呼叫你的 api

`method` => `post`
`網址` => `https://localhost:3001/LaSai/sais`
`Headers` => `Authorization` => `Bearer token` 特別注意要 Bearer 後面有空白格 XD

<iframe width="853" height="480" src="https://www.youtube.com/embed/XGvWCpu6cBs" title="湖南卫视我是歌手-杨宗纬《空白格》-20130215HD" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

```
Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IxxooxxxRURDNjNDQkVDNDY4N0Q5MzdDNThCM0ZBQjYxIiwidHlwIjoiYXQrand0In0.eyJuYmYiOjE2ODEzNTgzOTAsImV4cCI6MTY4MTM2MTk5MCwiaXNzIjoiaHR0cHM6Ly9sb2NhbGhvc3Q6NDQzMTAiLCJjbGllbnRfaWQiOiJEZW1vQXBpQ2xpZW50IiwiaWF0IjoxNjgxMzU4MzkwLCJzY29wZSI6WyJEZW1vQXBpQ2xpZW50Il19.nOO6CG8AkVZ6PAzsD5r4unmDK3wrnLBHCqhsjz0mmO_ZXL-NsKdTWPHPhDKKKhz9IXQ4CEKkKbPuxCwICO9TCjtWakLdB1S86NEqhXgeQ_i3BlYJYQyfMV5F1NgoTAOFUhdE1XdPiFjmE1YB8MAP3Db_LZ3jD940IcAVzFpEfnIG01qojvhjEpxlzo5LYc8hxaPHgDSRl9VyWrKzxV3iPCLWnuWRrVo6irHrpaJcbTaukjU9ZBkIJKdtdyJzi7E1Vl0BSmjAZhaXkJB0m10o4pEdOre4SmlXFaEHO6COt9Rl_LFC7bzAvNTujt7NOSpoDMQp3FlWQp4KIf3I6nAJcw 
```

#### 實作 Authorization Code
##### 實作
這個應該都是大多數人要搞 SSO 會用的 , 反正就是 mvc 站台拿 token 然後做事
先開一個 .net 6 mvc 專案 , 接著下載這個套件 `Microsoft.AspNetCore.Authentication.OpenIdConnect`
然後開啟 `launchSettings.json` 找到你的網址
``` json
    "Net6SSOMVC": {
      "commandName": "Project",
      "dotnetRunMessages": true,
      "launchBrowser": true,
      "applicationUrl": "https://localhost:7069;http://localhost:5069",
      "environmentVariables": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },

```

接著到 `Skoruba identityserver4 Admin` 後臺 `https://localhost:44303` 去新增一個 Client
`ClientId` => `mvc`
`Client Name` => `mvc`
`Client Secrets` => `mvc`
然後選 `Web Application - Server side Authorization Code Flow with PKCE` => `Save`
`Allowed Scopes` 這裡先把有的選項都加進去
`Redirect Uris` => `https://localhost:7069/signin-oidc` 注意這裡要設定你自己站台的網址
`Allowed Grant Types` => `authorization_code` 這個要留意下 , 我忘了加 XD 然後狂噴 Error
`Front Channel Logout Uri ` => `https://localhost:7069/signout-oidc`
`Post Logout Redirect Uris ` => `https://localhost:7069/signout-callback-oidc`
`Allowed Cors Origins ` => `https://localhost:7069` 應該沒設定也沒關係 暫無研究
`Client Uri ` => `https://localhost:7069`
`Require Consent` => 這個設定 `false` 的話其實有點強姦的味道 , 就是直接同意啦 (這個在企業內部應該表示資料是屬於公司的)
如果設定 `true` 的話就會跳出來你要允許那些的選項
`Logo Uri` => 這個用在同意頁面 , 有設定的話上面會有 logo 可是我測的機器上好像沒開 CORS 所以爆炸 `https://localhost:7069/images/logo.png`
`Always Include User Claims In IdToken` 這個選項有 `enable` 的話就會自動把你的 `Claim` 加上去 , 少寫一些 code
最後 Save

接著 `Program` 改成這樣 , 比較特別的就是 `Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true;` 這句
debug 過程中如果沒設定這樣的話 , 他會把詳細訊息吃掉 , 最好加上 , 不然那個訊息看不太懂
另外就是 `Authority` 這個要注意 , 不要寫成 `https://localhost:44303`

如果寫錯會炸這樣 (有加上 Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true)
```
InvalidOperationException: IDX20803: Unable to obtain configuration from: 'https://localhost:44303/.well-known/openid-configuration'.
```

如果寫錯會炸這樣 (沒加上 Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII) 會吃案 , 噴一堆看不懂的
```
IOException: IDX20807: Unable to retrieve document from: 'System.String'. HttpResponseMessage: 'System.Net.Http.HttpResponseMessage', HttpResponseMessage.Content: 'System.String'.
```

另外注意 `JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();` 這句如果不設定的話就會以網址形式呈現 , 加上去才會以 well-known 形式呈現


`Program`
``` c#
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.OpenIdConnect;
using System.IdentityModel.Tokens.Jwt;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

//這句如果不設定的話就會以網址形式呈現 , 加上去才會以 well-known 形式呈現
JwtSecurityTokenHandler.DefaultInboundClaimTypeMap.Clear();

//加入詳細訊息
Microsoft.IdentityModel.Logging.IdentityModelEventSource.ShowPII = true;


builder.Services.AddAuthentication(options =>
    {
        options.DefaultScheme = CookieAuthenticationDefaults.AuthenticationScheme;
        options.DefaultChallengeScheme = OpenIdConnectDefaults.AuthenticationScheme;
    })
    .AddCookie(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddOpenIdConnect(OpenIdConnectDefaults.AuthenticationScheme, options =>
    {
        options.Authority = "https://localhost:44310/";
        options.ClientId = "mvc";
        options.ClientSecret = "mvc";
        options.ResponseType = "code";

        //options.Scope.Add("openid");
        //options.Scope.Add("profile");
        options.SaveTokens = true;

		//這裡可以用來把以前 .net framework 內 UseOpenIdConnectAuthentication
		//Notifications = new OpenIdConnectAuthenticationNotifications { ... }
		//相關 Event 加上去 https://dotblogs.com.tw/anyun/2021/04/25/173529
        options.Events = new OpenIdConnectEvents
        {

        };

		
    });


var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}



app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");


app.Run();

```

後來發現之前舊版有插 log 所以補下 , 補在 `builder.Services.AddAuthentication` 前即可 , .net6 真是太精簡了 .. 都不太曉得要怎麼寫 XD
``` c#
//以工廠建立 log
using var loggerFactory = LoggerFactory.Create(x =>
{
    x.AddConsole();
});

var logger = loggerFactory.CreateLogger<Program>();
builder.Services.AddAuthentication(options => ...
```


另外要加工自己的一些 Claim 可以參考[這篇](https://dotblogs.com.tw/anyun/2021/04/25/173529) , 舊版這個叫做 `SecurityTokenValidated` , .net6 裡面叫做 `OnTokenValidated`
礙於之前沒玩過 , 反正一個 `Scope` 底下可以有很多的 `Claim` , 這部分可以自己去設定看權限要怎樣設計
此外要拿到 Code , AccessToken , RefreshToken 等等重要資訊則可以依靠 `TokenEndpointResponse` 這咚咚
我看舊版的在 `ProtocolMessage` 這裡面有寫東西 , 可是 .net6 我撈裡面的子屬性都 null
``` c#
OnTokenValidated = async notification => {
	var accessToken = context.TokenEndpointResponse.AccessToken;
	//... 看你還要拿啥
}
```

接著讓 `HomeController` 內受到保護 , 把需要保護的 Action 加上這段 `[Authorize]` 即可
``` c#
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Net6SSOMVC.Models;
using System.Diagnostics;

namespace Net6SSOMVC.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;

        public HomeController(ILogger<HomeController> logger)
        {
            _logger = logger;
        }

        public IActionResult Index()
        {
            return View();
        }
		
        public async Task LogOut()
        {
			//先登出自己的站台
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
			
			//登出 STS
            await HttpContext.SignOutAsync(OpenIdConnectDefaults.AuthenticationScheme);
        }

	//或這樣寫
	//public IActionResult Logout()
	//{
	//	return SignOut("Cookies", "oidc");
	//}


        [Authorize]
        public async Task<IActionResult> Privacy()
        {
            var accessToken = await HttpContext.GetTokenAsync(OpenIdConnectParameterNames.AccessToken);
            var idToken = await HttpContext.GetTokenAsync(OpenIdConnectParameterNames.IdToken);
            var refreshToken = await HttpContext.GetTokenAsync(OpenIdConnectParameterNames.RefreshToken);

            ViewData["accessToken"] = accessToken;
            ViewData["idToken"] = idToken;
            ViewData["refreshToken"] = refreshToken;

            return View();
        }


        [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}
```

然後修改 `_Layout.cshtml` 加入登出功能
```
<div class="navbar-collapse collapse d-sm-inline-flex justify-content-between">
	<ul class="navbar-nav flex-grow-1">
		<li class="nav-item">
			<a class="nav-link text-dark" asp-area="" asp-controller="Home" asp-action="Index">Home</a>
		</li>
		<li class="nav-item">
			<a class="nav-link text-dark" asp-area="" asp-controller="Home" asp-action="Privacy">Privacy</a>
		</li>
		<li class="nav-item">
			<a class="nav-link text-dark" asp-area="" asp-controller="Home" asp-action="LogOut">LogOut</a>
		</li>
	</ul>
</div>

```

至此就可以測看看 , 記得先從 `https://localhost:44310/` 上面登出 , 這樣才可以看到跳進去頁面的效果 後續應該就是自己串自己的 DB , 有空再寫


##### jquery 或 前後端混合的問題
一開始有點想不通 , 如果純前端用 `Implicit` 那混合前後端要用啥 , 後來想想應該依靠後端去走 `Authorization Code Flow`
下面這個 lab 如果你用 jquery 要呼叫受保護的 api 也是要先登入不然會噴 CORS 的 error
`TestController.cs`
``` c#
[Authorize]
public class TestController : ControllerBase
{
	public string HelloWorld()
	{
		return "HelloWorld";
	}
}
```


所以要把 `Authorize` 擋在 Controller or Action 上
`HomeController.cs`
```
	[Authorize]
	public IActionResult JQ()
	{
		return View();
	}
```

`JQ.cshtml`
```
<h2>JQuery</h2>


@section Scripts{
<script>
  console.log('test jq');
    $.get('https://localhost:7069/Test/HelloWorld', function(data, status){
      console.log('Data: ' + data + 'Status:' + status);
    });
</script>
}

```

沒擋的話會噴這樣 
```
Access to XMLHttpRequest at 'https://xxx.com/sts/connect/authorize?client_id=net6mvc&redirect_uri=....'
(redirected from 'https://localhost:7069/Test/HelloWorld') from 
origin 'https://localhost:7069' has been blocked by CORS policy: 
Response to preflight request doesn't pass access control check: 
No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

##### 補 CORS
``` c#
//加入允許 CORS
builder.Services.AddCors(p => p.AddPolicy("CORS", builder =>
{
    builder.WithOrigins("*").AllowAnyMethod().AllowAnyHeader();
}));


//設定允許 CORS
app.UseCors("CORS");

```

#### Angular 實作 Authorization Code
主要是靠這個[angular-auth-oidc-client 套件](https://angular-auth-oidc-client.com/docs/intro)
另外他還有提供大量[範例](https://angular-auth-oidc-client.com/docs/samples/) 可以參考看看

前端最主要的設定如下
`authority` => 表示你的 security token service , 所以應該會是 https://localhost:44310
`redirectUrl` => 表示你這個 angular 站台的網址 , 懶得寫的話就直接用 `window.location.origin`
`postLogoutRedirectUri` => 登出後回來的頁面 , 懶得寫也是直接用 `window.location.origin`
這裡實作上有遇到很雷的部分 , 一般啟動 `angular` 預設的 `port` 都是 `4200` , 測試的時候都會用自己 ip 去測試
可是 sso server 因為已經上線 , 並且還針對網域去限定 , 所以導致我狂噴 `CORS` , 而且也是使用 `https` 所以條件嚴苛
這時候可以先用 `ipconfig /all` 來查自己電腦在內網叫啥
所以你的網址應該長這樣 `https://hahaha.lasai.com` , 這時候 `redirectUrl` 實際上是 `https://hahaha.lasai.com`

另外還遇到忘了使用 `https` 噴的錯誤 , 如果噴這句的話應該是沒設定 `https` , 要確保自己的路徑都走 `https`
`main.c7f7bb43c5958d73.js:1 ERROR TypeError: Cannot read property 'digest' of undefined`

```
ipconfig /all

Windows IP 設定

   主機名稱 . . . . . . . . . . . . .: hahaha
   主要 DNS 尾碼  . . . . . . . . . .: lasai.com
   節點類型 . . . . . . . . . . . . .: 混合式
   IP 路由啟用 . . . . . . . . . . . : 否
   WINS Proxy 啟用 . . . . . . . . . : 否
   DNS 尾碼搜尋清單 . . . . . . . . .: lasai.com
```

接著要在 `package.json` 的 `scripts` 進行調整 , 追加 `ng serve --ssl --host 0.0.0.0 --disable-host-check --port 443` 就可以讓 angular 以 https 的方式啟動
```
  "scripts": {
    "ng": "ng",
    "start": "ng serve",
    "starthost": "ng serve --ssl --host 0.0.0.0 --disable-host-check",
    "startmachine": "ng serve --ssl --host 0.0.0.0 --disable-host-check --port 443",
    "build": "ng build",
    "watch": "ng build --watch --configuration development",
    "test": "ng test"
  },
```

`app.module.ts`
```
AuthModule.forRoot({
  config: {
	authority: 'https://localhost:44310',
	redirectUrl: 'https://hahaha.lasai.com',
	postLogoutRedirectUri: window.location.origin,
	clientId: 'angular',
	scope: 'openid profile email offline_access',
	responseType: 'code',
	silentRenew: true,
	useRefreshToken: true,
	logLevel: LogLevel.Debug,
  },
}),
```

還有個雷點 , 預設情況下當你開新分頁的話就需要重新登入 , 所以要在 `providers` 追加這個部分 , 就可以用 localStorage 去存
```
providers:[
	{
	  /**
	   * https://angular-auth-oidc-client.com/docs/documentation/configuration
	   * 這裡預設每次開新的視窗就會被清除登入 , 所以要設定以下這兩個 config 才可以 keep 住
	   * Using localstorage instead of default sessionstorage
	   * The angular-auth-oidc-client uses session storage by default that gets cleared whenever you open the website in a new tab, if you want to change it to localstorage then need to provide a different AbstractSecurityStorage.
	   */
	  provide: AbstractSecurityStorage,
	  useClass: DefaultLocalStorageService,
	}
]
```

最後我測試他好像不會自動判斷你的 idToken 是否已經到期 , 當 token 時間到以後你還是處於登入狀態 , 所以要點 `f5` 刷了才是登出
因為還在摸索中 , 我先在 app.component 的 ngOnInit 函數裡面加上 setInterval , 我看印度人是用 setTimeout 應該都類似
```
//當時間到了自動刷新登出
setInterval(() => {
  console.log('check idToken Expired')
  if (this.idToken) {
	console.log('isTokenExpired', this.jwtHelper.isTokenExpired(this.idToken))
	if (this.jwtHelper.isTokenExpired(this.idToken) === true) {
	  this.oidcSecurityService.logoff().subscribe((result) => console.log(result));
	}
  }
}, 1000 * 10)
```

另外 web api 有保護的話 , 可以用 `HttpInterceptor` 去加上 jwt token 類似這樣吧!? 還在摸索階段
```
export class BasicAuthHttpInterceptor implements HttpInterceptor {

  constructor(public oidcSecurityService: OidcSecurityService) { }

  intercept(req: HttpRequest<any>, next: HttpHandler) {
    //直接從 localstorage 去拿
    // if (req.url.startsWith('https://123.45.67.89:3001')) {
    //   let data = JSON.parse(localStorage.getItem('0-angular')!)
    //   if (data) {
    //     let token = data['authnResult']?.['access_token']
    //     if (token) {
    //       req = req.clone({
    //         setHeaders: { Authorization: `Bearer ${token}` }
    //       });

    //       //如果有拿到的話
    //       return next.handle(req);
    //     }
    //   }
    // }

    //不太確定會不會有其他問題 , 應該暫時可以
    if (req.url.startsWith('https://123.45.67.89:3001')) {
      this.oidcSecurityService.checkAuth().subscribe(({ accessToken }) => {
        req = req.clone({
          setHeaders: {
            Authorization: `Bearer ${accessToken}`,
          }
        });
        return next.handle(req);
      })
    }


    return next.handle(req);

  }
}
```


IdentityServer 設定

Name
`ClientId` => `angular`
`Client Name` => `angular`

Basics
`Allow Offline Access` => `打勾`
`Allow Access Token Via Browser` => `打勾`
`Allowed Scopes` => `openid profile email`
`Redirect Uris` => `https://hahaha.lasai.com`
`Allowed Grant Types` => `authorization_code`

Authentication/Logout
`Post Logout Redirect Uris` => `https://hahaha.lasai.com`

Token
`Identity Token Lifetime` => `86400 = 60秒 * 60分鐘 * 24小時` 這個預設只有 300 秒 5 分鐘的樣子 , 登出的頻率反映真實世界的登出頻率 XD

#### Implicit 實作
理論上來說會用這個實際上應該是 SPA 也就是純前端 `Angular` `Vue` `React` 這類 , 不過工作環境大多是混合前後 , 所以有空再寫詳細 XD
工作上遇到舊版的 code 也是走 Implicit 整個怪怪低
好像要在 UI 上勾選 `Allow Access Token Via Browser`
`Program.cs`
``` c#
//...

.AddOpenIdConnect(OpenIdConnectDefaults.AuthenticationScheme, options =>
//implicit
options.ResponseType = "id_token token";
```



### IdentityServer4
https://identityserver4.readthedocs.io/en/latest/quickstarts/0_overview.html#preparation
首先先安裝範本
```
dotnet new -i IdentityServer4.Templates

#查看目前範本
dotnet new -l

IdentityServer4 Empty                                 is4empty             [C#]        Web/IdentityServer4
IdentityServer4 Quickstart UI (UI assets only)        is4ui                [C#]        Web/IdentityServer4
IdentityServer4 with AdminUI                          is4admin             [C#]        Web/IdentityServer4
IdentityServer4 with ASP.NET Core Identity            is4aspid             [C#]        Web/IdentityServer4
IdentityServer4 with Entity Framework Stores          is4ef                [C#]        Web/IdentityServer4
IdentityServer4 with In-Memory Stores and Test Users  is4inmem             [C#]        Web/IdentityServer4
```

然後看到一個很懶的語法 `md` , 其實就是 `mkdir` .. 有必要這麼懶嗎 XD
```
md quickstart
cd quickstart

md src
cd src

dotnet new is4empty -n IdentityServer
```

未完
