---
title: ef core 8 oracle 版本不相容問題
date: 2024-09-30 11:54:47
tags:
- c#
- oracle
---
&nbsp;
<!-- more -->

今天練習時無意中發現, 如果用 ef core 8 搭配 oracle11g 的話, 又有個往生的消息 XD
以前可以這樣寫 `opt.UseOracleSQLCompatibility("11")`
現在只會跳出 `OracleSQLCompatibility.DatabaseVersion19,21,23` 這三個版本的 enum 選項

可以參考官方討論 或 這篇
最後只能把版本鎖定在 `Oracle EF Core 8.21.140`, 整個悲劇 lol ~


```csharp
builder.Services.AddDbContext<TestDbContext>(options =>
{
    var conn = builder.Configuration.GetConnectionString("TestConnection");
	
	//舊版 ok
    options.UseOracle(conn, opt=> opt.UseOracleSQLCompatibility("11"));
	
	//新版要這樣寫, 不過有些功能還是會往生 XD
	//options.UseOracle(conn);
});
```
