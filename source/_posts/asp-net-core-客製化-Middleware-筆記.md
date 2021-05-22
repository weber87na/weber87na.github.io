---
title: asp.net core 客製化 Middleware 筆記
date: 2021-04-19 19:14:19
tags: asp.net core
---
&nbsp;
<!-- more -->

### 如何對取得 HttpContext 內的 Route 資料
新增個 Middleware
```
public class GGMiddleware
{
	private readonly RequestDelegate next;
	public GGMiddleware(RequestDelegate next)
	{
		this.next = next;
	}


	public async Task Invoke(HttpContext context)
	{
		Console.WriteLine( context.Request );
		Console.WriteLine(context.Request.RouteValues);
		await next(context);
	}
}
```

Startup.cs
注意此處順序很重要 , 萬一自訂的 Middleware 卡在 app.UseRouting 前面就無法取得 Route 內的資料 , 算是很低能的錯誤
```
app.UseStaticFiles();
app.UseRouting();

//注意順序要在 UseRouting 後面 , 因為 .net core 的 middleware 是依照順序執行
app.UseMiddleware<GGMiddleware>();
```

### 客製化 Regex Middleware
這邊用 regex 客製化一個 Middleware , 去判斷是否傳入的 route 為 `gg or yy` , 藉此達到更加細緻的操作
```
public class RegexMiddleware
{
	private readonly RequestDelegate next;
	public RegexMiddleware(RequestDelegate next)
	{
		this.next = next;
	}

	public async Task Invoke(HttpContext context)
	{
		//防 null 的新版寫法 , 到底是 c# 抄 kotlin 還是 kotlin 抄 c# ?
		var controller = context.Request.RouteValues["controller"]?.ToString();
		var action = context.Request.RouteValues["action"]?.ToString();

		if(controller == "GG" && action == "YY")
		{
			//就算 route 有用 regex 去擋也會先進入此處 , 所以可以客製化 response 給接收端
			var GG = context.Request.RouteValues["GG"]?.ToString();

			//一定要加上小老鼠符號 @ regex 才會真的去判斷 full match
			//參考自老外 https://stackoverflow.com/questions/1209049/regex-match-whole-words
			//裝 B 的概念
			Regex regex = new Regex(@"\b(gg|yy)\b");
			var flag = regex.IsMatch(GG);

			if (flag == false)
			{
				//提前輸出想要的 json
				context.Response.StatusCode = 200;
				context.Response.ContentType = "application/json";
				await context.Response.WriteAsync( JsonConvert.SerializeObject( 
					new { "message" = "your message" }
				));
			}
			else
			{
				await next(context);
			}

		}
		else
		{
			await next(context);
		}

	}
}
```
