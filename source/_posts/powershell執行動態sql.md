---
title: powershell執行動態sql
date: 2020-07-15 00:08:58
tags:
- powershell
- sqlserver
- sql
- mssql
---
&nbsp;
<!-- more -->
以往要執行動態 sql 多半都會用半手動方式先在 sql server 裡面寫好 script 然後才執行 , 萬一有一堆 sql 要執行時就是一場噩夢了!
最近用 powershell 搭配簡化一下整體工作流程 (可惜 postgresql 沒法用)
可以參考這個[example](https://www.sqlshack.com/working-with-powershells-invoke-sqlcmd/)
``` powershell
#匯入sqlserver模組
Import-Module SqlServer

#cd 到指定的資料庫也可以不用
#Set-Location SQLSERVER:\SQL\localhost\DEFAULT\Databases
#如果有 cd 到指定位置可以直接執行就好不用指定 instance
#$result = Invoke-Sqlcmd -InputFile "d:\test.txt"

#這句會執行指定的 sqlserver instance
$result = Invoke-SqlCmd -ServerInstance "localhost,1433" -Database "test2" -Username "User" -Password "Password" -InputFile "d:\test.txt"

#注意這邊最關鍵
#回傳為來的物件為 Array 故使用 join 將動態 script 轉換為一條 sql
$genCreateSQLOneline = $result.genCreateSQL -join " "

#最後執行先前動態產生的sql
Invoke-Sqlcmd -ServerInstance "localhost,1433" -Database "test2" -Username "User" -Password "Password" -Query $genCreateSQLOneline
```
