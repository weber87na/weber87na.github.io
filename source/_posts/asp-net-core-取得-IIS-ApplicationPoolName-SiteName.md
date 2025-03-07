---
title: asp.net core 取得 IIS ApplicationPoolName SiteName
date: 2024-10-22 12:07:45
tags: c#
---
&nbsp;
<!-- more -->

工作上遇到的問題, 因為有佈署一堆同樣的 api 在 IIS 做 load balancer, 導致難以確定到底是哪個 api 發生問題
研究下要怎麼拿到 IIS 上面的 `ApplicationPoolName` 及 `Site Name` 查了老半天最後發現以下方式
問 GPT 也問不出什麼來 LOL

```
string GetApplicationPoolName()
{
    return Environment.GetEnvironmentVariable( "APP_POOL_ID" ) ?? "Not Running in IIS";
}

string GetSiteName()
{
    return Environment.GetEnvironmentVariable( "ASPNETCORE_IIS_SITE_NAME" ) ?? "Not Running in IIS";
}
```

拿到以後就可以跟 serilog 做搭配 `Enrich.WithProperty( "APP_POOL_ID", GetApplicationPoolName() )` 這樣 log 就很明確可以知道是哪個 api 發生錯誤

如果還想拿其他的環境變數可以直接呼叫 `Environment.GetEnvironmentVariables();` 就可以拿全部了

如果搭配之前研究的 GitInfo 套件就可以明確有 commit 版本, 使除錯訊息粒度更細緻
