---
title: SignalR 筆記
date: 2021-12-20 02:41:11
tags: c#
---
&nbsp;
<!-- more -->

這個問題年代久遠 , 剛好看到以前手上的資料就整理一下 , 主要參考[官方](https://docs.microsoft.com/zh-tw/aspnet/signalr/overview/guide-to-the-api/hubs-api-guide-javascript-client) [官方教學](https://docs.microsoft.com/zh-tw/aspnet/signalr/overview/getting-started/tutorial-getting-started-with-signalr) 還有[強國人](https://www.bilibili.com/video/BV1nt41177ff?from=search&seid=10936084741887719888&spm_id_from=333.337.0.0)

### 起手
加入類別 `TestHub`
```
public class TestHub : Hub
{
	//給 client 呼叫 server 上的方法
	public void LaSai(string message)
	{
		//server 丟一些 result 回去給 client
		Clients.All.hello(message);
	}
}

```

加入類別 `Startup`
```
public class Startup
{
	public void Configuration(IAppBuilder app)
	{
		// Any connection or hub wire up and configuration should go here
		app.MapSignalR();
	}
}
```

接著驗證是否成功 `http://localhost:12345/signalr/hubs` 正常的話會看到一個 js 文件
然後撰寫前端 code 記得要引用 jquery & signalr 最後是動態生出來的 js `/signalr/hubs`
```
<script src="Scripts/jquery-3.4.1.js"></script>
<script src="Scripts/jquery.signalR-2.2.2.js"></script>
<script src="/signalr/hubs"></script>
```

最後玩看看 , 寫 js 時特別注意大小寫 , 不然錯了就出不來
```
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8" />
    <title></title>
    <script src="Scripts/jquery-3.4.1.js"></script>
    <script src="Scripts/jquery.signalR-2.2.2.js"></script>
    <script src="/signalr/hubs"></script>

	<!--使用靜態生出來的-->
    <!--<script src="Scripts/server.js"></script>-->
</head>
<body>
    <script>

		//如果是其他站台要用的話要加上這句
		//$.connection.hub.url = 'http://localhost:23007/signalr';
        var chat = $.connection.testHub;

        $.connection.hub.start().done(function () {
            $(document).on('click' , '#btn', function () {
                chat.server.laSai('la di sai');
            })
        })

        chat.client.hello = function (message) {
            $('#display').append(`<p>${message}</p>`);
        }
    </script>
    <div id="display"></div>
    <button id="btn">go</button>
</body>
</html>
```

### 產生靜態 js 檔
因為 signalr 都是動態去產生出檔案 , 礙於一些特別需求需要用靜態的 , 首先安裝 `Microsoft.AspNet.SignalR.Utils`
接著 cd 到這個底下
```
YourProject\packages\Microsoft.AspNet.SignalR.Utils.2.4.1\tools\net40
signalr.exe ghp /path:C:\Users\YourName\source\repos\YourProject\YourProject\bin
```

如果出現如下錯誤
```
Error: Failed to load assembly 'Newtonsoft.Json, Version=7.0.0.0, Culture=neutral, PublicKeyToken=30ad4fe6b2a6aeed' referenced by the server.
If your application uses a newer version of this assembly, this error is likely due to a missing or inaccurate binding redirect.
If your server application has a 'Web.config' or '[AppName].exe.config' file with binding redirects in it, provide the path to that file with the '/configFile' parameter.
If you have already provided a '/configFile' parameter, make sure the config file it points to has a binding redirect for 'Newtonsoft.Json, Version=7.0.0.0, Culture=neutral, PublicKeyToken=30ad4fe6b2a6aeed' within it.
See https://aka.ms/about-binding-redirects for more information on binding redirects

```

請在剛剛那個 signalr 產生靜態 js 工具的資料夾底下新增 `signalr.exe.config`
注意要跟 csproj 裡面的套件版本一致 , 基本上複製我這份應該就搞定

```
<?xml version="1.0"?>
<configuration>
  <runtime>
    <assemblyBinding xmlns="urn:schemas-microsoft-com:asm.v1">
      <dependentAssembly>
        <assemblyIdentity name="Newtonsoft.Json" culture="neutral" publicKeyToken="30ad4fe6b2a6aeed" />
        <bindingRedirect oldVersion="0.0.0.0-7.0.0.0" newVersion="12.0.0.0" />
      </dependentAssembly>
    </assemblyBinding>
  </runtime>
</configuration>
```

最後會生出 `server.js` 特別需要注意到最底下會有這句 , 這個 `/signalr` 需要改成你自己的 signalr 站台網址才有效
```
signalR.hub = $.hubConnection("/signalr", { useDefaultPath: false });
```
所以可能最後會長這樣
```
signalR.hub = $.hubConnection("http://localhost:23007/signalr", { useDefaultPath: false });
```

不過實務上去改 `server.js` 太蠢 , 所以通常會這樣建立 hub
```
//如果是其他站台要用的話要加上這句
$.connection.hub.url = 'http://localhost:23007/signalr';
var chat = $.connection.testHub;
```


然後調整你前端的 code 參考至 `server.js` 即可 , 大概像這樣
```
<script src="jquery-3.4.1.js"></script>
<script src="jquery.signalR-2.2.2.js"></script>
<script src="server.js"></script>
```

最後注意如果產出來的 hub 是錯誤的記得先清空專案有可能因為專案指到舊的 cache 所以無法產出正確的程式碼
若以上方法都不行的話直接把動態產生的 `~/signalr/hubs` 檔案內容複製起來成為一個新的檔案直接把 script 指向他也 ok

### cors 問題處理

通常會炸這樣
```
Access to XMLHttpRequest at 'http://localhost:23007/signalr/negotiate?clientProtocol=1.5&connectionData=%5B%7B%22name%22%3A%22testhub%22%7D%5D&_=1639937665706' from origin 'http://127.0.0.1:5500' has been blocked by CORS policy: No 'Access-Control-Allow-Origin' header is present on the requested resource.
```

安裝 nuget 套件 `Microsoft.Owin.Cors`
特別注意是舊版的 visual studio 現在都會提示你安裝新版 , 不要裝錯了
接著在 Startup.cs 類別中加入如下程式碼 , 正常來說就搞定了
```

public class Startup
{
	public void Configuration(IAppBuilder app)
	{
		// Any connection or hub wire up and configuration should go here
		//app.MapSignalR();
		app.Map("/signalr", map =>
		{
			map.UseCors(CorsOptions.AllowAll);
			var hubConfiguration = new HubConfiguration { };
			map.RunSignalR(hubConfiguration);
		});
	}
}

```
