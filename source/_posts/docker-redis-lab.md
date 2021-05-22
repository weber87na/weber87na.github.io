---
title: docker redis lab
date: 2021-05-16 23:25:55
tags: docker
---
&nbsp;
<!-- more -->

[redis image](https://hub.docker.com/_/redis)
免錢管理工具[AnotherRedisDesktopManager](https://github.com/qishibo/AnotherRedisDesktopManager/releases)
最好裝一下剛剛的管理工具 , 才可以快速驗證後續的 lab 內容
```
#下載 redis image
docker search redis
docker pull redis

#執行 redis 並且保存資料
cd $home
mkdir redis_data

#啟動 redis
docker run --name redis -p 6379:6379 `
-v $home/redis_data:/data -d redis
```

進入到 container redis bash , 並且用 redis-cli 進行連線
注意這邊是用 `string` , 跟稍後在程式內使用 `hash` 不同 , 測試 `abp` 寫入是會用 `string` , 沒研究那麼深
```
docker exec -it 435 /bin/bash
redis-cli
set test helloworld
```

直接在 host 使用 telnet 對 redis 進行連線
`win + r` => `control` => `程式和功能` => `開啟或關閉 windows 功能` => `Telnet Client`
```
telnet 127.0.0.1 6379
get test
```

安裝以下套件
```
Microsoft.Extensions.Caching.StackExchangeRedis
```

設定 `Startup`
```
public void ConfigureServices( IServiceCollection services )
{

	services.AddControllers();
	services.AddSwaggerGen( c =>
	 {
		 c.SwaggerDoc( "v1", new OpenApiInfo { Title = "DockerRedisLab", Version = "v1" } );
	 } );
	services.AddStackExchangeRedisCache( options => {
		options.Configuration = "localhost:6379";
	} );
}

```

新增一個 `TestController`
```
    [ApiController]
    [Route( "[controller]" )]
    public class TestController : ControllerBase
    {
        private readonly IDistributedCache distributedCache;
        public TestController(IDistributedCache distributedCache)
        {
            this.distributedCache = distributedCache;
        }

        [HttpGet]
        public ActionResult<Person> Get()
        {
            Person p = new Person
            {
                Name = "Docker",
                Age = 18
            };


            if(distributedCache.Get( "Docker" ) == null)
            {
                var str = JsonSerializer.Serialize( p );
                var bty = Encoding.UTF8.GetBytes( str );
                distributedCache.Set( "Docker", bty );
                return p;
            }
            else
            {
                var docker = distributedCache.Get( "Docker" );
                var result = JsonSerializer.Deserialize<Person>( docker );
                return result;
            }
        }


        [HttpGet()]
        [Route("Get2")]
        public string Get2()
        {
            distributedCache.SetString( "qqq", "abc" );
            var x = distributedCache.GetString( "qqq" );
            return x;
        }
    }

    public class Person
    {
        public string Name { get; set; }
        public int Age { get; set; }
    }

```

[佛心老外的 powershell 傳送檔案到 linux 教學](https://thedarksource.com/powershell-scp-to-transfer-files-between-windows-linux/)
```
#匯入模組
Install-Module -Name Posh-SSH

#輸入 linux 登入帳號密碼
$credential = Get-Credential

#注意要用系統管理員 , 並且在 $home 底下先新增資料夾 redis_data
#10.1.25.123 => 你的遠端 linux 機器 ip
gsudo Set-SCPFile -ComputerName '10.1.25.123' -Credential $credential  `
-RemotePath "/home/yourname/redis_data/" -LocalFile 'C:\Users\YourName\redis_data\dump.rdb'
```

開第二台 redis , 拿其它 linux 機器上的 redis 測試 (注意本次是在遠端 linux 上執行)
```
#蓋資料夾
cd ~
mkdir redis_data

#執行 redis
docker run --name linux-redis -p 6379:6379 -v /home/yourname/redis_data:/data -d redis

#看看是否執行成功
docker container ls
```


加入 docker support , 預設的 docker file 如下
```
FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["DockerRedisLab/DockerRedisLab.csproj", "DockerRedisLab/"]
RUN dotnet restore "DockerRedisLab/DockerRedisLab.csproj"
COPY . .
WORKDIR "/src/DockerRedisLab"
RUN dotnet build "DockerRedisLab.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DockerRedisLab.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "DockerRedisLab.dll"]
```

特別注意 , 預設用 visual studio 在專案點右鍵 `Open Folder in File Explorer` 如果執行 docker build 一定會出現以下錯誤
```
#目前位置
#C:\Users\YourName\source\repos\DockerRedisLab\DockerRedisLab
=> ERROR [build 3/7] COPY [DockerRedisLab/DockerRedisLab.csproj, DockerRedisLab/]
failed to compute cache key: "/DockerRedisLab/DockerRedisLab.csproj" not found: not found
```

其實只要往上切一層就可以正常運作了
```
docker build --no-cache -t lab -f .\DockerRedisLab\Dockerfile .
```

其實可以偷偷加上 redis 在裡面
```
docker exec -it f28 /bin/bash
apt update
apt install
```

自己加 curl 在我們的 lab container 裡面
dockerfile
```
#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/aspnet:5.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /src
COPY ["DockerRedisLab/DockerRedisLab.csproj", "DockerRedisLab/"]
RUN dotnet restore "DockerRedisLab/DockerRedisLab.csproj"
COPY . .
WORKDIR "/src/DockerRedisLab"
RUN dotnet build "DockerRedisLab.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "DockerRedisLab.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
#這兩行是自己加上去的
RUN apt update
RUN apt install -y curl
RUN apt install -y vim
ENTRYPOINT ["dotnet", "DockerRedisLab.dll"]
```


```
docker container run -it -P 1f8ce3923dc4 /bin/bash
#偷開 redis-server
redis-server --daemonize yes
#執行 redis-cli
redis-cli
keys *
```


```
docker run -d -p 5000:80 d9588 5001:443
docker run -d -p 5000:80 -p 5001:443 d9588
```
