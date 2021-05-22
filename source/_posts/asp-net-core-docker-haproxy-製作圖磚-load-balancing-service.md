---
title: asp.net core & docker & haproxy 製作圖磚 load balancing service
date: 2021-05-12 22:34:41
tags:
- asp.net core
- docker
- haproxy
- GIS
---
&nbsp;
<!-- more -->

### 事前準備下載圖磚
剛好研究 docker 就隨手紀錄一下 , 把以前的遺珠給完整
[國土測繪中心官網](https://maps.nlsc.gov.tw/homePage.action?in_type=web#)
[臺灣通用電子地圖 MBTiles](https://maps.nlsc.gov.tw/download/TaiwanEMap6.mbtiles)
[下載 mbutil](https://github.com/mapbox/mbutil)
萬一沒 gsudo 可以安裝一下 [gsudo](https://github.com/gerardog/gsudo)
```
mkdir map
cd map
git clone git://github.com/mapbox/mbutil.git
cd mbutil

#安裝
gsudo python setup.py install

#解壓縮
python mb-util TaiwanEMap6.mbtiles Taiwan

#最後複製到你的 $home 目錄裡
```

### 建立 asp.net core 圖磚 server
新增一個 `asp.net core web api` 專案 => 專案名稱 `TaiwanMap` => `選 5.0` => 直接建立
多蓋一個 `wwwroot` 資料夾 => 把剛剛解壓的 `Taiwan` 丟進去
特別注意到 , 如果 wwwroot 是空的 , 系統不會偵測到 , 所以就算用 bash 登入進去也不會有資料夾 , 建議先隨便新增個檔案

後端驗證用的 `LogMiddleware` 要用來看看圖磚被請求的 path 是哪台
```
    public class LogMiddleware
    {
        private readonly RequestDelegate next;
        public LogMiddleware(RequestDelegate next)
        {
            this.next = next;
        }


        public async Task Invoke(HttpContext context)
        {
            Console.WriteLine( context.Request.Path );
            await next( context );
        }
    }
```

插入 `LogMiddleware` 在 `app.UseRouting();` 後面 , 因為之前有做過怎麼發 terrain 就直接拿來複製貼上
```
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment( ))
            {
                app.UseDeveloperExceptionPage( );
            }

            app.UseCors( builder =>
            {
                builder.AllowAnyOrigin( );
                builder.AllowAnyMethod( );
                builder.AllowAnyHeader( );
            } );

            app.UseRouting( );
            app.UseMiddleware<LogMiddleware>();

            var provider = new FileExtensionContentTypeProvider( );
            provider.Mappings.Add( ".terrain", "application/vnd.quantized-mesh" );

            app.UseStaticFiles( new StaticFileOptions
            {
                ContentTypeProvider = provider,
                OnPrepareResponse = ctx =>
                {
                    string extension = System.IO.Path.GetExtension( ctx.File.Name );
                    if (extension == ".terrain")
                    {
                        ctx.Context.Response.Headers.Add( "Content-Encoding", "gzip" );
                    }
                },
            } );

            app.UseAuthorization( );

            app.UseEndpoints( endpoints =>
             {
                 endpoints.MapControllers( );
             } );
        }

```

新增前端地圖程式碼 `map.html`
```
<!doctype html>
<html lang="en">
<head>
    <!--<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.5.0/css/ol.css" type="text/css">-->
    <link rel="stylesheet" href="ol.css"/>
    <style>
        body {
            padding: 0px;
            margin: 0px;
            height: 100vh;
        }

        .map {
            height:100%;
            width: 100%;
        }

        h2 {
            position: absolute;
            top:0px;
            right:0px;
        }
    </style>
    <!--<script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.5.0/build/ol.js"></script>-->
    <script src="ol.js"></script>
    <title>Docker map example</title>
</head>
<body>
    <h2>Docker Load Balancing Example</h2>
    <div id="map" class="map"></div>
    <script type="text/javascript">
        var map = new ol.Map({
            target: 'map',
            layers: [
                new ol.layer.Tile({
                    source: new ol.source.XYZ({
                        //給 load balancing 用的網址
                        url: 'http://localhost:3080/Taiwan/{z}/{x}/{y}.png'

                        //給直接跑 docker 用的網址
                        //url: 'http://localhost:5000/Taiwan/{z}/{x}/{y}.png'
                    })
                })
            ],
            view: new ol.View({
                center: ol.proj.fromLonLat([121.5, 22.5]),
                zoom: 4
            })
        });
    </script>
</body>
</html>
```

接著新增 Dockerfile 在目前的專案底下
```
FROM mcr.microsoft.com/dotnet/aspnet:5.0
COPY bin/Release/net5.0/publish/ App/
#RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /etc/ssl/openssl.cnf
#RUN sed -i 's/MinProtocol = TLSv1.2/MinProtocol = TLSv1/g' /usr/lib/ssl/openssl.cnf

WORKDIR /App
EXPOSE 5000
#ENV ASPNETCORE_URLS=http://0.0.0.0:5000;https://0.0.0.0:5001
ENV ASPNETCORE_URLS=http://0.0.0.0:5000
ENTRYPOINT ["dotnet", "TaiwanMap.dll"]
```



自己 build docker
```
#專案的路徑
#~\source\repos\TaiwanMap\TaiwanMap
dotnet build
dotnet publish -c Release
docker build --no-cache -t map -f Dockerfile .
```

開另外一個 powershell , 前端先用 5000 port 驗證是否成功吃到圖磚
```
cd ~
docker container create -p 5000:5000 -v $home/map/Taiwan:/App/wwwroot/Taiwan --name map map

#直接執行
#docker container run -p 5000:5000 -v $home/map/Taiwan:/App/wwwroot/Taiwan --name map map

docker start map

docker exec 8b0da2096d60 ls /app

#進入到 bash 內
docker container exec -it map bash
cd /App/wwwroot/Taiwan
ls
#0  1  10  11  12  13  14  15  2  3  4  5  6  7  8  9  metadata.json
```

最後開這兩個 url 測看看 api or 地圖服務是否正常運作
http://localhost:5000/WeatherForecast
http://localhost:5000/Taiwan/0/0/0.png

接著我們建立 haproxy
```
#對應到 haproxy 內的 backend
docker network create backend

#對應到 haproxy 內的 frontend
docker network create frontend

#圖磚主機 1
docker create --name map1 -v $home/map/Taiwan:/App/wwwroot/Taiwan -p 5000:5000 --network backend map

#圖磚主機 2
docker create --name map2 -v $home/map/Taiwan:/App/wwwroot/Taiwan -p 6000:5000 --network backend map

#將網路串連起來
docker network connect frontend map1
docker network connect frontend map2

#啟動
docker container start map1 map2

#load balancing 主機
docker container run --network frontend -d -p 3080:80 -p 3081:443 -v $home/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg --name haproxy haproxy
```

注意換行符號只能用 LF , 在 windows 是 CR LF 會炸 error
haproxy.cfg
```
defaults
	timeout connect 5000
	timeout client 50000
	timeout server 50000

frontend localhosts
	bind *:80
	bind *:443
	mode http
	default_backend map

backend map
	mode http
	balance roundrobin
	server map1 map1:5000
	server map2 map2:5000
```

最後執行 http://localhost:3080/map.html 即可 , 可以看到 docker 目前 print 出來到底是哪個容器被呼叫圖磚服務
