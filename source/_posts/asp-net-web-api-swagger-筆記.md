---
title: asp.net web api swagger 筆記
date: 2021-02-24 00:41:30
tags:
- swagger
---
&nbsp;
<!-- more -->

### 設定 logo
[可以採用類似這篇老外的作法](https://stackoverflow.com/questions/36291146/modifications-to-swagger-ui-header)
在 Content 資料夾底下加入 logo , 接著加入自訂的 css 注意 css 要設定 Embedded Resource
在 SwaggerConfig.cs 開啟 `c.InjectStylesheet` 這串
PS: 如果是掛在討厭的 subsite 要處理路徑問題實在太麻煩了 , 還是先用 base 64 吧 [可以用這個線上工具](https://www.base64-image.de/)
``` css
#logo .logo__img{
    width:120px;
    height:28px;
    content:url('/Content/logo.png');
    background-image:none;
}

#logo .logo__title{
    display:none !important;
    width:0;
    height:0;
}
.swagger-section .swagger-ui-wrap {
    min-width:1200px;
}

.swagger-section #api_selector {
    float:left;
    display: block;
    clear: none;
    padding-left: 10px;
    margin-top: 3px;
}
```

### 在正式環境只能用 local 進入 swagger ui
這個需求比較麻煩 try 了半天 , 本以為在 filter 裡面加入自訂邏輯即可 , 但是這樣是對 api 進行設定 , 好像找不太到直接屏蔽 swagger ui 的這種方法
所以只好搬出以前 asp.net 時代 `Global.asax` 這隻檔案進行全域設定
```
protected void Application_BeginRequest(object sender, EventArgs e)
{
	var request = ((System.Web.HttpApplication) sender).Request;
	var response = ((System.Web.HttpApplication) sender).Response;
	
	string swaggerPath = request.Path;
	Regex regex = new Regex("^swagger");
	var match = regex.Match(swaggerPath);
	if(match.Success && request.IsLocal == false){
		response.StatusCode = 403;
	}
	
}
```

### 設定起始頁面為 swagger ui 頁面
[可以直接參考這篇老外做法](https://stackoverflow.com/questions/47457681/how-to-set-swagger-as-default-start-page)
直接在 `RouteConfig.cs` 設定
``` csharp
    routes.MapHttpRoute(
        name: "swagger_root",
        routeTemplate: "",
        defaults: null,
        constraints: null,
        handler: new RedirectHandler((message => message.RequestUri.ToString()), "swagger"));

    routes.MapRoute(
        name: "Default",
        url: "{controller}/{action}/{id}",
        defaults: new { controller = "Home", action = "Index", id = UrlParameter.Optional }
    );
```

### 設定多層 swagger api 中文說明
在專案上右鍵 => `Properties` => `Build` => `Output` => `Output path` => 填入 `bin\` => 打勾 `XML documentation file:` (他會自己產正確的路徑)

今天做專案遇到的問題 swagger api 不能正常顯示中文說明 , 之前大多數都是 model 掛在同個專案底下 , 鮮少分層分很明確 , 所以沒遇過這個
google 一下感謝大神 , 參考自[大神](https://dotblogs.com.tw/shadowkk/2019/09/03/092620)
其他設定可以[參考官方](https://docs.microsoft.com/zh-tw/aspnet/core/tutorials/getting-started-with-swashbuckle?view=aspnetcore-6.0&tabs=visual-studio)


```
//建立 swagger api 的 schema 文件讓 api 有相關使用說明 , 每一層都會套用到
var files = Directory.GetFiles(
	AppDomain.CurrentDomain.BaseDirectory, $"Your.ProjectName.*.xml",
	SearchOption.AllDirectories
);

foreach (var name in files)
{
	options.IncludeXmlComments( name );
}
```

後來又發現應該也可以參考[老外](https://stackoverflow.com/questions/44643151/how-to-include-xml-comments-files-in-swagger-in-asp-net-core)不過沒 try
```
foreach (var filePath in System.IO.Directory.GetFiles(Path.Combine(Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location)), "*.xml"))
{
	try
	{
		c.IncludeXmlComments(filePath);
	}
	catch (Exception e)
	{
		Console.WriteLine(e);
	}
}
```

