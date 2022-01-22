---
title: localdb 筆記
date: 2020-12-18 01:03:30
tags: sql
---
&nbsp;
<!-- more -->

sqllocaldb info
MSSQLLocalDB

組合
OUTPUT=$(sqllocaldb info)

sqllocaldb info $OUTPUT

連線字串
(LocalDB)\MSSQLLocalDB

Rdier 可以參考[官方](https://www.jetbrains.com/help/rider/Connecting_to_SQL_Server_Express_LocalDB.html#step-2-create-the-localdb-connection)
注意 `driver` 部分要選 `Microsoft SQL Server (jTds)`
`Connection type` 要選 `LocalDB`
`instance` => `MSSQLLocalDB`

預設會在 `C:\Users\YourName\AppData\Roaming\JetBrains\Rider2021.2\consoles\db` 看到你 console 裡面 sql
