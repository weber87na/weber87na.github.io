---
title: 運用powershell快速轉換sql server查詢結果為json
date: 2020-07-11 23:25:57
tags:
- powershell
- sqlserver
- mssql
- json
---
&nbsp;
<!-- more -->
工作上時常有些資料轉換小需求 , 但一時之間又不好搞定 , 多半會透過各種亂七八糟的方式轉換 , 無聊看看 powershell 的功能裡面可以連接 sql server 操作一些這種雜亂的工作!
如果需要直接參考原生的在 sql server 上操作 json 可以看這個[老外](https://www.red-gate.com/simple-talk/sql/t-sql-programming/consuming-json-strings-in-sql-server/?article=1176)

首先需要 [安裝 SQL Server PowerShell 模組](https://docs.microsoft.com/zh-tw/sql/powershell/download-sql-server-ps-module?view=sql-server-ver15)

特別注意需要[安裝 powershell 5.x](https://www.microsoft.com/en-us/download/details.aspx?id=54616) 以上版本
如果是 win7 選這個 Win7AndW2K8R2-KB3191566-x64.zip ，可以參考[這篇](http://shaurong.blogspot.com/2017/09/powershell-51windows-management.html)講得比較詳細
搞定後又遇到一堆地雷
Install-Module : 需要 NuGet 提供者才能與 NuGet 型存放庫互動。請確定已安裝 '2.8.5.201' 或更新的 NuGet 提供者
後來發現要照[這篇老外](https://stackoverflow.com/questions/51406685/how-do-i-install-the-nuget-provider-for-powershell-on-a-unconnected-machine-so-i)的解法才 ok
最主要就是要用 admin 執行以下指令
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet
```
也可以考慮順便安裝 [gsudo](https://github.com/gerardog/gsudo)

接著就可以進入正題

``` powershell
Install-Module -Name SqlServer -AllowClobber -Scope CurrentUser
```
接著匯入模組
```
Import-Module SqlServer
```
然後設定路徑想到的位置 , 並且可以用 ls cd 這類指令看目前的物件如 table , view

若設定過程中機器遇到權限問題 [SQL Server Error 18456](https://channel9.msdn.com/Blogs/raw-tech/How-To-Fix-Login-Failed-for-User-Microsoft-SQL-Server-Error-18456-Step-By-Step) 可以參考這篇解答
```
Set-Location SQLSERVER:\SQL\localhost\DEFAULT\Databases
```
最後透過類似以下指令快篩內容並且轉換為 json 輸出 , 以前很多很阿雜的工作瞬間快速搞定!
```
$customers = Invoke-Sqlcmd "select * from customers"
$customers | select CompanyName | ConvertTo-Json
```

後來發現一個很智障的問題就是沒在 localdb 上跑過，原來 LocalDB 要特別用括號把圓括號特別框起來
```
Import-Module SqlServer
Set-Location SQLSERVER:\SQL\"(LocalDB)"\MSSQLLocalDB\Databases\test
```

有閒暇時間其實還可以安裝個 [vscode powershell 整合](https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell)比起在 powershell ise 上陽春的功能還好用太多

