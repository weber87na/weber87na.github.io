---
title: asp.net 爬蟲筆記
date: 2025-03-27 11:24:00
tags:
---

&nbsp;
<!-- more -->

## cookie
最近幫忙朋友搞爬蟲, 然後就遇到鬼打牆, 怎麼 post 都沒辦法正常登入, 仔細看發現忘了加上 `VIEWSTATE` `VIEWSTATEGENERATOR` `EVENTVALIDATION` 這三個咚咚, 這沒搞過 asp.net 的人大概都不會知道有這些 XD
因為平常沒怎麼 post 表單, 大多數都是用 puppeteer 然後開 headless, 這把則是用 AngleSharp
post 表單重點在於要抓 `name` 而非 `id` 另外一些看起來沒啥意義的 `RememberMe` `UserLogin` 最好也都帶進去這樣才會正確 post 過去
最後想到以前搞[畜生爬蟲就被 VIEWSTATE 雷過](https://www.blog.lasai.com.tw/2020/08/03/net-core-%E7%95%9C%E7%89%B2%E7%88%AC%E8%9F%B2/)

```
//取得登入 url
var url = "xxxurl";

// 使用 HttpClientHandler 管理 Cookies
var handler = new HttpClientHandler();
handler.CookieContainer = new CookieContainer();

var client = new HttpClient(handler);

// 發送 GET 請求，獲取頁面 HTML
var response = await client.GetStringAsync(url);

// 解析 HTML 頁面，使用 AngleSharp
var parser = new HtmlParser();
var document = await parser.ParseDocumentAsync(response);

var viewState = document.QuerySelector("input[name='__VIEWSTATE']")?.GetAttribute("value");
var viewStateGenerator = document.QuerySelector("input[name='__VIEWSTATEGENERATOR']")?.GetAttribute("value");
var eventValidation = document.QuerySelector("input[name='__EVENTVALIDATION']")?.GetAttribute("value");

Console.WriteLine($"__VIEWSTATE = {viewState}");
Console.WriteLine($"__VIEWSTATEGENERATOR = {viewStateGenerator}");
Console.WriteLine($"__EVENTVALIDATION = {eventValidation}");

if (viewState == null || viewStateGenerator == null || eventValidation == null)
{
    Console.WriteLine("無法獲取必要的表單欄位！");
    return;
}

var formData = new Dictionary<string, string>
        {
            { "__VIEWSTATE", viewState },
            { "__VIEWSTATEGENERATOR", viewStateGenerator },
            { "__EVENTVALIDATION", eventValidation },
            { "Username", "username },
            { "Password", "password" },
            //記住我
            //{ "RememberMe", "on" },

            //登錄按鈕
            { "UserLogin", "Login" }
        };

// 將表單數據編碼為 application/x-www-form-urlencoded 格式
var content = new FormUrlEncodedContent(formData);

// 發送 POST 請求提交表單，並包含 Cookies
var postResponse = await client.PostAsync(url, content);

// 檢查請求是否成功
if (postResponse.IsSuccessStatusCode)
{
    Console.WriteLine("表單提交成功！");

    // 在登入成功後列出 Cookies
    var cookies = handler.CookieContainer.GetCookies(new Uri(url));

    Console.WriteLine("登入成功後的 Cookies:");
    foreach (Cookie cookie in cookies)
    {
        Console.WriteLine($"{cookie.Name} = {cookie.Value}");
    }

}
else
{
    Console.WriteLine($"表單提交失敗，狀態碼: {postResponse.StatusCode}");
}
```

## appsettings
平常寫 asp.net core 的話預設都已經幫我們安裝好可以讀取 appsettings 的套件, 這把寫 console 沒想到這麼麻煩, 需要安裝以下套件

```
Microsoft.Extensions.Configuration
Microsoft.Extensions.Configuration.FileExtensions
Microsoft.Extensions.Configuration.Json
```

然後設定這樣才能動
```
//設定 appsettings 用
var configuration = new ConfigurationBuilder()
    .SetBasePath(AppDomain.CurrentDomain.BaseDirectory) // 設定根目錄
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .Build();

```

然後要記得補上 appsettings.json

```
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=localhost;Database=database;User=root;Password=passowrd"
  }
}

```


## MariaDB
因為對方用 MariaDB, 自從 MySQL 被 Oracle 買走以後這個生態系就再也沒用過了 XD
要用 GUI 可以安裝這套 [HeidiSQL](https://www.heidisql.com/)
用 terminal 則是這樣下

```
mysql -u root -p -h localhost -P 3306
```


本來想說弄個 ef core 後來想想太麻煩, 直接回去用 Dapper
安裝套件時竟然是安裝 `MySqlConnector` 真是意外
寫法大概就這樣

```
public class DatabaseHelper
{
    private IConfiguration configuration;
    public DatabaseHelper(IConfiguration configuration)
    {
        this.configuration = configuration;
    }

    public DateTime MaxDate()
    {
        // 使用 MySQL 連線和 Dapper 取得最大日期
        using (var dbConnection = new MySqlConnection(configuration.GetConnectionString("DefaultConnection")))
        {
            dbConnection.Open();

            // SQL 查詢語句
            string query = "SELECT MAX(datetime) FROM table;";

            // 執行查詢並取得最大日期
            DateTime maxDate = dbConnection.QuerySingleOrDefault<DateTime>(query);
            return maxDate;
        }
    }
}

```
