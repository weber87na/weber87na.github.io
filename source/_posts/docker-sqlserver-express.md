---
title: docker sqlserver express
date: 2021-05-16 23:49:01
tags: docker
---
&nbsp;
<!-- more -->

[官方 hub](https://hub.docker.com/r/microsoft/mssql-server-windows-express/)
執行這個 lab 前請先切換成 windows 版本的 docker , 接著才 pull 官方的 image 下來
特別注意到官方這句 `The password must meet the password complexity requirements found here`
密碼要設定複雜一點 , 不然又炸得不要不要的 , 此外看看 port 有無衝到
```
docker pull microsoft/mssql-server-windows-express

docker run -d -p 1433:1433 `
--name sqlexpress `
-e sa_password=P@ssw0rd!23 `
-e ACCEPT_EULA=Y microsoft/mssql-server-windows-express
```

用 powershell 進入到這個 windows 容器裡面 , 可以發現就是台閹割過的 windows server , 但還有 13GB
```
docker exec -it sqlexpress powershell
```

powershell 安裝 sql 模組 , 注意要在自己的 host 執行 , 並且裝相關套件
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet
Install-Module -Name SqlServer -AllowClobber -Scope CurrentUser
```

在 host 執行 , 測試建立資料庫在 container 內
```
#匯入sqlserver模組
Import-Module SqlServer

#取得 container 的 ip
$ip = (docker container inspect sqlexpress | ConvertFrom-Json).NetworkSettings.Networks.nat.IPAddress

#這句會執行指定的 sqlserver instance
$result = Invoke-SqlCmd -ServerInstance "$ip,1433" `
-Database "master" `
-Username "sa" `
-Password "P@ssw0rd!23" `
-InputFile "$home\test\mssql\helloworld.sql"
```

helloworld.sql
```
create database HelloWorldSqlServerContainer
GO

use HelloWorldSqlServerContainer
GO

create table HelloWorld(
	id int primary key identity,
	title nvarchar(200),
	content nvarchar(max)
)
GO

insert into HelloWorld values ('test1' , 'test1');
insert into HelloWorld values ('test2' , 'test2');
insert into HelloWorld values ('test3' , 'test3');
GO

select *
from HelloWorld
GO
```
