---
title: 私有 Nuget Server 架設 BaGet
date: 2021-05-11 20:01:04
tags:
- docker
- nuget
---
&nbsp;
<!-- more -->

### BaGet 安裝並執行 container
[官方說明](https://loic-sharma.github.io/BaGet/installation/docker/)
[下載位置](https://hub.docker.com/r/loicsharma/baget)
```
#切到 root
cd ~

#拉 image
docker pull loicsharma/baget

#建立資料夾
mkdir ~/baget-data

#執行 container 注意這個是 linux 的 container
docker container run -d --name nuget-server -p 5555:80 `
-e baget.env -v "${PWD}/baget-data:/var/baget" loicsharma/baget:latest

#執行私有的 nuget
start http://localhost:5555/
```

### 編輯 baget.env
注意這邊他是設定在 user home 執行 , 所以這個檔案要放在 user home (~)
```
# The following config is the API Key used to publish packages.
# You should change this to a secret value to secure your server.
# 可以直接在 sql or 其他工具生 guid 來用 select NEWID()
# 這裡先設定 123 方便
ApiKey=123

Storage__Type=FileSystem
Storage__Path=/var/baget/packages
Database__Type=Sqlite
Database__ConnectionString=Data Source=/var/baget/baget.db
Search__Type=Database
```

### 發行寫好的 nuget package
新增 project HelloWorldBaGet , 蓋一個 .net core 的類別
```
using System;

namespace HelloWorldBaGet
{
    public class HelloWorld
    {
        public string Hello(){
            return "Hello";
        }

        public string World(){
            return "World";
        }
    }
}
```

切到專案的 `Properties` => `Package` => `Generate NuGet package on build`
```
dotnet build
#在此目錄底下會生出 HelloWorldBaGet.1.0.0.nupkg
#C:\Users\YourName\source\repos\HelloWorldBaGet\HelloWorldBaGet\bin\Debug

#發行 -k 是之前設定的金鑰 NUGET-SERVER-API-KEY (之前設定是 123)
dotnet nuget push -s http://localhost:5555/v3/index.json -k 123 HelloWorldBaGet.1.0.0.nupkg
```

回到網站 http://localhost:5555/ 就可以看見 HelloWorldBaGet
新增 `console` 專案 ConsoleApp
回到 visual studio `Manage NuGet Packages` , 點選 `Package source` 旁邊的齒輪
新增 Source `http://localhost:5555/v3/index.json` , Name 這裡設定 BaGet
```
using System;

namespace ConsoleApp
{
    class Program
    {
        static void Main( string[] args )
        {
            HelloWorldBaGet.HelloWorld helloWorld = new HelloWorldBaGet.HelloWorld();
            var str = helloWorld.Hello() + helloWorld.World();
            Console.WriteLine(str);
        }
    }
}
```
