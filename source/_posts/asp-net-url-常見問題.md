---
title: asp.net url 常見問題
date: 2022-02-15 19:27:40
tags:
- asp.net
- c#
---
&nbsp;
<!-- more -->

這個問題是老生常談 , 在一些老舊的系統上常常可以看到 js 混合後端的 code 綁在一起
然後通常又會用一個 iis 80 port 去蓋 subsite , 導致 url 三不五時就在錯誤
所以可以用後端先去撈出正確的 url 路徑 , 接著宣告為 js 變數讓前端拿
另外一個常見問題是靜態資源 cache , 一般來說應該要設定 bundle , 但是老系統沒這些東西 , 所以為了讓 user 正確載入靜態資源可以這樣寫


### webform
```
<script src="<%=ResolveUrl("~/Scripts/Test.js")%>?v='<%=DateTime.Now.ToFileTimeUtc()%>'"></script>
```

`Test.aspx`
```
<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Test.aspx.cs" Inherits="Test" %>

<!DOCTYPE html>
<html lang="zh-Hant">
<head></head>
<body>
    <asp:Label ID="theBaseUrl" runat="server" Text=""></asp:Label>
    <script src="<%=ResolveUrl("~/Scripts/Test.js")%>?v='<%=DateTime.Now.ToFileTimeUtc()%>'"></script>
    <script>
        var theBaseUrl = document.getElementById('theBaseUrl').innerText;
		$.ajax({
			type: 'GET',
			url: theBaseUrl,
			success: function(resp) {
				console.log(resp);
			}
		});
    </script>
</body>
</html>

```

`Test.aspx.cs`
```
protected void Page_Load(object sender, EventArgs e)
{
	//設定網頁第一次載入的時候執行的動作
	if (!IsPostBack)
	{
		//先測看看 baseUrl
		//https://stackoverflow.com/questions/7413466/how-can-i-get-the-baseurl-of-site
		//https://stackoverflow.com/questions/18338042/relative-url-in-jquery-post-call

		string baseUrl = "";
		var subsite = Context.Request.ApplicationPath;
		baseUrl = Request.Url.Scheme + "://" + Request.Url.Authority + subsite;

		theBaseUrl.Text = baseUrl;
	}
}

```


### Razor Page

因為之前搞過 Razor Page , 所以也玩看看怎樣獲得相同結果
在 .net core 上多了一個 `asp-append-version` 屬性 , 設定下去的話可以搞定靜態資源被 cache 的問題

`Index.cshtml`
```
@page
@model IndexModel
@{
    ViewData["Title"] = "Home page";
}

<div id="theBaseUrl">@Model.TheBaseUrl</div>
<img src="@Url.Content("~/img/avatar.png")?v='@DateTime.Now.ToFileTimeUtc()'" width="50" />

<img asp-append-version="true" src="~/img/avatar.png" width="50" />

<script>
    var theBaseUrl = document.getElementById('theBaseUrl').innerText;
    alert(theBaseUrl)
</script>

```


基本上相差不遠 , 不過這裡要用 `PathBase` , PathBase 是不帶 slash 的 , 所以自己在串接要注意下 , 沒意外的話應該與 webform 得到相同結果
`Index.cshtml.cs`
```
public class IndexModel : PageModel
{
	private readonly ILogger<IndexModel> _logger;

	[BindProperty]
	public string TheBaseUrl { get; set; }

	public IndexModel(ILogger<IndexModel> logger)
	{
		_logger = logger;
	}

	public void OnGet()
	{
		string baseUrl = "";
		var subsite = HttpContext.Request.PathBase;
		baseUrl = HttpContext.Request.Scheme + "://" + HttpContext.Request.Host + subsite;
		TheBaseUrl = baseUrl;
	}
}
```


最後如果佈署至 IIS 遇到 `HTTP Error 500.19 - Internal Server Error`
記得要安裝 [hosting](https://dotnet.microsoft.com/en-us/download/dotnet/thank-you/runtime-aspnetcore-5.0.14-windows-hosting-bundle-installer)
