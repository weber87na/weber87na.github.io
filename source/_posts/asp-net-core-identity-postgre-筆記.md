---
title: asp.net core identity postgre 筆記
date: 2024-04-06 20:30:28
tags:
- postgre
- c#
---
&nbsp;
<!-- more -->

被盧小又要搞 postgres 怕之後又忘記順手記錄下
主要參考[這篇](https://www.webnethelper.com/2023/03/aspnet-core-7-using-postgresql-to-store.html) 還有 [官方](https://learn.microsoft.com/zh-tw/aspnet/core/security/authentication/scaffold-identity?view=aspnetcore-8.0&tabs=visual-studio#scaffold-identity-into-an-mvc-project-with-authorization)

先安裝 ef core 的工具
```
dotnet tool install -g dotnet-ef
```

然後開個 asp.net core mvc 新專案這裡用 `Backend` , 然後驗證記得選 `Individual Identity`
nuget 先安裝 `Npgsql.EntityFrameworkCore.PostgreSQL`
在 `Data\Migrations` 底下會有 `00000000000000_CreateIdentitySchema` `ApplicationDbContextModelSnapshot`
這目前是給 sql server localdb 用的 , 直接把他倆註解
找到 Program 這句 `options.UseSqlServer(connectionString)` 改用 `options.UseNpgsql(connectionString)`
設定 postgres 連線字串
`appsettings.json`
```
    "DefaultConnection": "Host=localhost:5432;Username=postgres;Password=postgres;Database=backend_identity"
```

先在 postgres 建立資料庫
```
create database backend_identity;
```

接著編譯專案 執行以下指令即可
```
dotnet ef migrations add firstMigration -c Backend.Data.ApplicationDbContext
dotnet ef database update -c Backend.Data.ApplicationDbContext
```

然後自己註冊一個使用者 , 他的 schema 是在 public 底下 , 查的時候記得要下雙引號
```
select *
from "AspNetUsers";
```
