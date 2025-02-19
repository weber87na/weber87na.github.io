---
title: Asp.net Core OCR Middleware 練習
date: 2024-05-21 17:42:35
tags: c#
---
&nbsp;
<!-- more -->

最近上課的作業開開腦洞, 原來 linqpad 也可以跑 asp.net core XD, 不過我是覺得不太習慣

操作步驟如下
確認 `linqpad` 暫時路徑, 大概長這樣 `C:\Users\YOURNAME\AppData\Local\Temp\LINQPad8\_zagynzui\shadow-3`
建立 `tessdata` 及 `wwwroot` 資料夾
切換到 `tessdata` 下載[語言檔](https://github.com/tesseract-ocr/tessdata/raw/4.00/chi_tra.traineddata)放進去
隨便找張有中文的 `jpg` 圖片丟到 `wwwroot` 底下

找到以下兩個資料看是 `x86 or x64` 夾複製到你這個 `linqpad` 暫時路徑 `C:\Users\YOURNAME\.nuget\packages\tesseract\5.2.0\x64`

最後執行 `Query` 即可 `http://localhost:5000/testimg.png`

他的 `header` 會加上 `OCR` 辨識文字的結果
```
X-OCR-Result: %E4%BD%A0+%E5%A5%BD+%E9%98%BF%0A%E6%B8%AC+%E8%A9%A6+%E7%9C%8B+%E7%9C%8B%0A
```

可以呼叫 `decode` 取得中文

http://localhost:5000/decode?str=%25E4%25BD%25A0%2B%25E5%25A5%25BD%2B%25E9%2598%25BF%250A%25E6%25B8%25AC%2B%25E8%25A9%25A6%2B%25E7%259C%258B%2B%25E7%259C%258B%250A

```csharp
<Query Kind="Program">
  <NuGetReference>Tesseract</NuGetReference>
  <Namespace>Tesseract</Namespace>
  <Namespace>System.Net</Namespace>
  <Namespace>Microsoft.AspNetCore.Builder</Namespace>
  <Namespace>Microsoft.AspNetCore.Http</Namespace>
  <Namespace>Microsoft.AspNetCore.HttpOverrides</Namespace>
  <Namespace>Microsoft.Extensions.Configuration</Namespace>
  <Namespace>Microsoft.Extensions.DependencyInjection</Namespace>
  <Namespace>Microsoft.Extensions.Hosting</Namespace>
  <Namespace>System.Net.Http</Namespace>
  <Namespace>System.Threading.Tasks</Namespace>
  <IncludeAspNet>true</IncludeAspNet>
</Query>

void Main()
{
	// 設定環境變數
	Environment.SetEnvironmentVariable("ASPNETCORE_ENVIRONMENT", "Development");
	var builder = WebApplication.CreateBuilder();

	var app = builder.Build();

	//將 OCR 加在 header 上面
	app.UseStaticFiles(new StaticFileOptions
	{
	    OnPrepareResponse = ctx =>
	    {
	        string extension = System.IO.Path.GetExtension(ctx.File.Name).TrimStart('.');
	        if (extension == "jpg")
	        {
	            //設定路徑
	            string tessPath = Path.Combine("tessdata", "");
	            string text = "";

	            using (var engine = new TesseractEngine(tessPath, "chi_tra"))
	            {
	                using (var img = Pix.LoadFromFile(ctx.File.PhysicalPath))
	                {
	                    var page = engine.Process(img);
	                    text = page.GetText();
	                    //因為 http header 沒辦法使用中文一定要用 ascii 所以要用 UrlEncode 轉一下
	                    var textEncode = WebUtility.UrlEncode(text);
	                    ctx.Context.Response.Headers.Add("X-OCR-Result", textEncode);
	                }
	            }
	        }
	    }
	});	

	//用來 decode X-OCR-Result
	app.MapGet("decode", (string str) =>
	{
	    var result = WebUtility.UrlDecode(str);
	    return result;
	});


	app.Run();
}
```
