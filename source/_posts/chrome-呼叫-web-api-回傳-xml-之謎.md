---
title: chrome 呼叫 web api 回傳 xml 之謎
date: 2024-11-15 12:47:52
tags: chrome
---
&nbsp;
<!-- more -->

一個網友遇到的問題, 最近上課也遇到不過沒半個人講對 LOL

在舊版的 `.net web api` 如果用 `chrome` 去呼叫 `api` 的話, 預設會送你 `xml`
因為年代久遠以前都是直接移除, 在 `Application_Start` 裡面補 `GlobalConfiguration.Configuration.Formatters.XmlFormatter.SupportedMediaTypes.Clear();` 即可
如果是 `WebApiConfig` 則這樣移除, 這下 `chrome` 一定收到 `json`

```
public static class WebApiConfig
{
	public static void Register(HttpConfiguration config)
	{
		// Web API configuration and services
		// 加這行就可以移除 request response 用 xml
		config.Formatters.Remove(config.Formatters.XmlFormatter);

		// Web API routes
		config.MapHttpAttributeRoutes();

		config.Routes.MapHttpRoute(
			name: "DefaultApi",
			routeTemplate: "api/{controller}/{id}",
			defaults: new { id = RouteParameter.Optional }
		);
	}
}
```

可是搞笑的來了, 如果不移除的話, 用 `HttpClient` 去打 api 預設竟然會是 `json`
追查下去才發現預設 `HttpClient` `header` 的 `content-type` 也是沒帶 `json`
那為何是撈到 `json` 呢, 其實舊版的 web api 預設順序是 `json` 然後才是 `xml`

只要用以下這樣來調整順序測就會得到 xml

```
config.Formatters.Clear();
config.Formatters.Add(new XmlMediaTypeFormatter());
config.Formatters.Add(new JsonMediaTypeFormatter());
```

那 `chrome` 為何預設會是拿 `xml` 呢? 他 `header` 也沒帶 `content-type` 阿

其實秘密就在 `chrome` 的 `accept` 這句裡面, 他優先拿 xml 然後很後面才拿 `*/*`

```
accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7
```
