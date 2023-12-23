---
title: nginx 筆記
date: 2021-08-25 01:01:05
tags: nginx
---

&nbsp;
<!-- more -->

### 安裝 nginx
```
sudo apt-get update -y
sudo apt-get install nginx -y
```

看看狀態 , grep -v 排除查出 grep 的結果
```
ps auxw | grep nginx | grep -v grep
#root      607336  0.0  0.1  55720  5384 ?        Ss   02:40   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
#www-data  608302  0.0  0.0  56096  3168 ?        S    03:02   0:00 nginx: worker process
#www-data  608303  0.0  0.0  56096  3168 ?        S    03:02   0:00 nginx: worker process

systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2021-08-24 02:40:22 UTC; 32min ago
       Docs: man:nginx(8)
   Main PID: 607336 (nginx)
      Tasks: 3 (limit: 4557)
     Memory: 7.8M
     CGroup: /system.slice/nginx.service
             ├─607336 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             ├─608302 nginx: worker process
             └─608303 nginx: worker process

Aug 24 02:40:22 docker-lab systemd[1]: Starting A high performance web server and a reverse proxy server...
Aug 24 02:40:22 docker-lab systemd[1]: Started A high performance web server and a reverse proxy server.
```

預設的設定文件在 `/etc/nginx/`
另外重要的檔案 `/etc/nginx/sites-available/default` , 這個是 default server http 設定
```
ls /etc/nginx/
#conf.d        fastcgi_params  koi-win     modules-available  nginx.conf      proxy_params  sites-available  snippets      win-utf
#fastcgi.conf  koi-utf         mime.types  modules-enabled    nginx.conf.bak  scgi_params   sites-enabled    uwsgi_params

#備份預設檔案
sudo cp nginx.conf{,.bak}

#測 nginx 語法
sudo nginx -t
#nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#nginx: configuration file /etc/nginx/nginx.conf test is successful

#修改後重新載入
sudo nginx -s reload
```

預設的 nginx html 文件在 /usr/share/nginx/html/
讓人看得到的 index 文件在 /var/www/html , 這個改了就可以用 curl 打會看到改變
另外 nginx 常常會需要看些 header 之類的 , 所以 curl 執行時可以多加 -v 參數 , 有更詳細訊息
```
ls /usr/share/nginx/html/
index.html

/var/www/html
index.nginx-debian.html

sudo vim test.txt
helloworld
helloworld
helloworld
helloworld
helloworld
helloworld

curl 192.168.137.219/test.txt
curl -v 192.168.137.219/test.txt
```

### 多網站設定
參考[自此](https://webdock.io/en/docs/how-guides/shared-hosting-multiple-websites/how-configure-nginx-to-serve-multiple-websites-single-vps)
我本來有兩台 ubuntu , 各自都有 nginx 因為節費所以關閉一台
先確認要轉移的那台 , 確定連不上後把種花電信 or Godaddy 服務上面的 ip 換成要改用的那台
先複製設定檔 , 有噴權限問題就加上 sudo
```
cd /etc/nginx/sites-available
ls 
default  default.bak  default.full
mv default default_old
cp default.bak default
nginx -s reload
```

現在開始登入要改用的那台 , 建立資料夾然後慢慢搬內容
```
mkdir /var/www/html/rose
```

或是直接複製 zip 到 /var/www/html 底下
```
scp -i "rose.pem" rose.zip ubuntu@ec2-xx-xxx-xx-xxx.ap-northeast-1.compute.amazonaws.com:~/.
cp rose.zip /var/www/html/.
unzip rose.zip
```

萬一用 scp 複製噴這個錯誤表示權限太高
```
Permissions 0664 for 'ubuntu22.pem' are too open.
It is required that your private key files are NOT accessible by others.
This private key will be ignored.
Load key "ubuntu22.pem": bad permissions
ubuntu@yourip: Permission denied (publickey).
lost connection
```

可以用以下命令修正
```
chmod 400 ubuntu22.pem
```

接著新增你的設定檔大概長下面這樣 , 把原先有 Certbot 的地方註解
```
vim /etc/nginx/sites-available/rose


server {

	root /var/www/html/rose;

	# Add index.php to the list if you are using PHP
	index index.html index.htm index.nginx-debian.html;

	#server_name _;
	server_name www.rose.com rose.com; # managed by Certbot


	location / {
			# First attempt to serve request as file, then
			# as directory, then fall back to displaying a 404.
			try_files $uri $uri/ =404;
	}


    #listen [::]:443 ssl ipv6only=on; # managed by Certbot
    #listen 443 ssl; # managed by Certbot
    #ssl_certificate /etc/letsencrypt/live/xn--momo-tk3h402d.com/fullchain.pem; # managed by Certbot
    #ssl_certificate_key /etc/letsencrypt/live/xn--momo-tk3h402d.com/privkey.pem; # managed by Certbot
    #include /etc/letsencrypt/options-ssl-nginx.conf; # managed by Certbot
    #ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem; # managed by Certbot
}
```

接著建立連結
```
ln -s /etc/nginx/sites-available/rose /etc/nginx/sites-enabled/
ls /etc/nginx/sites-enabled/
```

測試看看有啥問題
```
nginx -t
```

都搞定的話
```
sudo nginx -s reload
```

此時還沒有 ssl , 所以需要去跑 Lets Encrypt 他會產 https 的部分在你的設定檔內 , 記得要刷新下
```
sudo certbot --nginx -d rose.com.tw -d www.rose.com.tw
sudo nginx -s reload
```


最後可以跑這個看看 log
```
sudo certbot renew --dry-run
```

### dotnet 反向代理
```
wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-5.0
```

新建 webapi
```
cd ~
mkdir forecast
cd forecast
dotnet new webapi
```

把 `launchSettings.json` https 給關掉 , 這個原本有 https , 把它移除
```
vim Properties/launchSettings.json


"forecast": {
  "commandName": "Project",
  "dotnetRunMessages": "true",
  "launchBrowser": true,
  "launchUrl": "swagger",
  "applicationUrl": "http://localhost:5000"
  "environmentVariables": {
	"ASPNETCORE_ENVIRONMENT": "Development"
  }
```

把 `Startup.cs` 內的 https 也註解起來
```
vim Startup.cs


public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
{
	if (env.IsDevelopment())
	{
		app.UseDeveloperExceptionPage();
		app.UseSwagger();
		app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "forecast v1"));
	}

	//app.UseHttpsRedirection();

	app.UseRouting();


	//這串要加 using Microsoft.AspNetCore.HttpOverrides;
	app.UseForwardedHeaders(new ForwardedHeadersOptions
	{
		ForwardedHeaders = ForwardedHeaders.XForwardedFor | ForwardedHeaders.XForwardedProto
	});

	app.UseAuthorization();

	app.UseEndpoints(endpoints =>
	{
		endpoints.MapControllers();
	});
}
```

因為預設的只能打 localhost 所以需要[設定 urls](https://andrewlock.net/5-ways-to-set-the-urls-for-an-aspnetcore-app/) 才可以正確打到 ip
```
dotnet bin/Debug/net5.0/forecast.dll --urls http://*:5000 &
curl 192.168.137.219:5000/WeatherForecast

#[{"date":"2021-08-25T07:00:35.210768+00:00","temperatureC":11,"temperatureF":51,"summary":"Balmy"},{"date":"2021-08-26T07:00:35.2132874+00:00","temperatureC":-5,"temperatureF":24,"summary":"Hot"},{"date":"2021-08-27T07:00:35.2132889+00:00","temperatureC":20,"temperatureF":67,"summary":"Chilly"},{"date":"2021-08-28T07:00:35.2132891+00:00","temperatureC":23,"temperatureF":73,"summary":"Chilly"},{"date":"2021-08-29T07:00:35.2132892+00:00","temperatureC":-11,"temperatureF":13,"summary":"Freezing"}]
```

[接著參考官方設定 nginx](https://docs.microsoft.com/zh-tw/aspnet/core/host-and-deploy/linux-nginx?view=aspnetcore-5.0)
注意 nginx 預設的網頁相關檔案放在 /var/www/ 之下 
```
dotnet publish --configuration Release
sudo cp -r ~/forecast/bin/Release/net5.0 /var/www/forecast
```

設定 nginx `/etc/nginx/sites-available/default` 或是 `/etc/nginx/nginx.conf`

```
sudo vim  /etc/nginx/nginx.conf

#因為不想讓預設的 80 nginx 被替換掉所以先設定 8080
server {
    listen        8080;
    #server_name   example.com *.example.com;
    location / {
        proxy_pass         http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}

#測 nginx 語法
sudo nginx -t
#nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
#nginx: configuration file /etc/nginx/nginx.conf test is successful

#修改後重新載入
sudo nginx -s reload
```

接著在後台跑 webapi , 並且打看看 , 至此就算成功啦 , 因為實際上環境會用 docker , 剩下就交給 docker
```
dotnet forecast.dll --urls http://*:5000 &
curl 192.168.137.219:8080/WeatherForecast
```



ngx_http_access_module
```
location / {
        # First attempt to serve request as file, then
        # as directory, then fall back to displaying a 404.
        try_files $uri $uri/ =404;
        #deny all; #這個 deny all 放最上面就全部不過
        allow 192.168.137.1; #hyperv 的 host 打的話要開
        allow 127.0.0.1; #用 curl 打的話 curl 127.0.0.1 才可以過
        allow 192.168.137.115; #用 curl 打 curl 192.168.137.115 才過
        deny all; #這個 deny all 放最下面才會過

		auth_basic "closed site";
		auth_basic_user_file conf.d/pwd;
}
```

[ngx_http_auth_basic_module](http://nginx.org/en/docs/http/ngx_http_auth_basic_module.html)
設定帳號 gg 密碼 123 , 特別注意好像要加 salt 才會生效
另外 `auth_basic_user_file` 最好要放在 nginx 的相關資料夾 , 我直接設定 root / 好像沒用
```
echo gg:$(openssl passwd -salt 123 123) | sudo tee /etc/nginx/conf.d/pwd
```


環境變數不設定的話預設是 Production
```
#設定環境變數
export ASPNETCORE_ENVIRONMENT=Development
export ASPNETCORE_URLS=http://+:5000
sudo vim ~/.bashrc

#印出環境變數
printenv


#解除環境變數
unset ASPNETCORE_ENVIRONMENT
unset ASPNETCORE_URLS
```

注意如果使用 nginx 的 reverse proxy 應該是不用指定 `ASPNETCORE_URLS=http://+:5000` 讓 nginx 去做服務就好
若有設定 `ASPNETCORE_URLS=http://+:5000` 的話 , 對外的 5000 port 還是會讓外面連得到
另外做 api 常常遇到 CORS 跨域問題可以補上 `add_header Access-Control-Allow-Origin "*"` 以便開放

```
sudo vim /etc/nginx/sites-available/default
server {
        listen 8080;
        location / {
                add_header Access-Control-Allow-Origin "*";
                proxy_pass http://127.0.0.1:5000;
        }
}


curl -i 192.168.137.115:8080/WeatherForecast
HTTP/1.1 200 OK
Server: nginx/1.18.0 (Ubuntu)
Date: Wed, 25 Aug 2021 06:24:28 GMT
Content-Type: application/json; charset=utf-8
Transfer-Encoding: chunked
Connection: keep-alive
Access-Control-Allow-Origin: *
```

### cesium terrain 設定

#### 狀況 1 直接使用 nginx 當 terrain server
最後順便筆記一下 [cesium terrain 有趣的設定](https://github.com/geo-data/cesium-terrain-server)
因為以前搞過 cesium terrain , 這邊就拿 nginx 練練手 , 最大重點兩層 location 都要設定 CORS , 這個地方雷了滿久
另外副檔名 match 到 terrain 時 header 要加上 gzip
```
#這個發 terrain
server {
        root /var/www/terrain;
        listen 8081;
        location / {

                add_header Access-Control-Allow-Origin "*";
                #add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
                #add_header Access-Control-Allow-Headers 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
                location ~* \.terrain$ {
                    add_header Access-Control-Allow-Origin "*";
                    #add_header Access-Control-Allow-Methods 'GET, POST, OPTIONS';
                    #add_header Access-Control-Allow-Headers 'DNT,X-Mx-ReqToken,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization';
                    add_header Content-Encoding gzip;
                }
        }
}

#這個給 .net core 做 reverse proxy
server {
        listen 8080;
        location / {
                proxy_pass http://127.0.0.1:5000;
        }

}
```

另外要追加設定 `/etc/nginx/mime.types` , 讓 terrain 認得
```
application/vnd.quantized-mesh        terrain;
```

#### 狀況 2 上游 upstream 已經事先設定 terrain 的 cors gzip 等參數 , nginx 只當代理
upstream 的 source code [可以直接參考我這篇](https://weber87na.github.io/2021/04/26/asp-net-core-%E7%99%BC%E4%BD%88-cesium-terrain/)

如果已經在上游設定好相關參數直接在 nginx 用 proxy 即可 , 無須額外設定

```
server {
        listen 8080;
        location / {
                proxy_pass http://127.0.0.1:5000;
				#CORS 可以不加
                #add_header Access-Control-Allow-Origin "*";
        }

}
```

另外上游的 code 其實不加 CORS 也 ok , 因對對上游來說都在 127.0.0.1 之上跑
所以下面這串 code 沒加也可以 work , 但是上游的 terrain 其他設定必須要加 , 本來我還以為可以在 nginx 設定內補 terrain 設定但是不 work
```
/*
	app.UseCors( builder =>
	{
		builder.AllowAnyOrigin( );
		builder.AllowAnyMethod( );
		builder.AllowAnyHeader( );
	 } );
*/
```


### dotnet 佈署在 ubuntu 上
先複製到 nginx 預設的 www 底下方便管理 , 記得加上 -r 參數整包讓他遞迴過去
```
cd /etc/systemd/system
cp -r ~/forecast/bin/Debug/net5.0/ /var/www/forecast
```

操作 systemctl 可以看看[這篇](https://blog.gtwang.org/linux/linux-create-systemd-service-unit-for-python-echo-server-tutorial-examples/) , 寫得還不錯

接著用 vim 編輯 forecast.service , 最重要的地方就是環境變數記得要補 , 特別是 ASPNETCORE_URLS=http://+:5000 , 不然預設只打得到 127.0.0.1
```
sudo vim forecast.service


[Unit]
Description=Forecast Web Api

[Service]
WorkingDirectory=/var/www/forecast
ExecStart=/usr/bin/dotnet /var/www/forecast/forecast.dll
Restart=always

RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=dotnet-forecast
User=www-data
#Environment=ASPNETCORE_ENVIRONMENT=Development
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
Environment=ASPNETCORE_URLS=http://+:5000

[Install]
WantedBy=multi-user.target
```


如果不小心手滑打錯了 , 先修改 service 內容接著執行以下指令
```
systemctl daemon-reload
systemctl restart forecast.service
```

像這樣就是 fail
```
● forecast.service - Forecast Web Api
     Loaded: loaded (/etc/systemd/system/forecast.service; enabled; vendor preset: enabled)
     Active: activating (auto-restart) (Result: exit-code) since Thu 2021-08-26 01:26:52 UTC; 7s ago
    Process: 3298 ExecStart=/usr/bin/dotnet /var/www/forecast.dll (code=exited, status=1/FAILURE)
   Main PID: 3298 (code=exited, status=1/FAILURE)
```

開啟自動 restart , 並且啟動 service
```
sudo systemctl enable forecast.service
sudo systemctl start forecast.service
```


正常會看到這樣
```
systemctl status forecast

● forecast.service - Forecast Web Api
     Loaded: loaded (/etc/systemd/system/forecast.service; enabled; vendor preset: enabled)
     Active: active (running) since Thu 2021-08-26 01:29:15 UTC; 1min 30s ago
   Main PID: 4068 (dotnet)
      Tasks: 13 (limit: 4557)
     Memory: 20.0M
     CGroup: /system.slice/forecast.service
             └─4068 /usr/bin/dotnet /var/www/forecast/forecast.dll

Aug 26 01:29:15 docker-lab systemd[1]: Started Forecast Web Api.
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]: info: Microsoft.Hosting.Lifetime[0]
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]:       Now listening on: http://localhost:5000
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]: info: Microsoft.Hosting.Lifetime[0]
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]:       Application started. Press Ctrl+C to shut down.
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]: info: Microsoft.Hosting.Lifetime[0]
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]:       Hosting environment: Development
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]: info: Microsoft.Hosting.Lifetime[0]
Aug 26 01:29:15 docker-lab dotnet-forecast[4068]:       Content root path: /var/www/forecast
```

這個指令可以看目前用了哪些 port , 更詳細可以[參考這個網站](https://www.cyberciti.biz/faq/unix-linux-check-if-port-is-in-use-command/)
```
sudo lsof -i -P -n
```

最後打 api 看看應該可以看到結果 , 先打 localhost 接著打自己的 ip 都要測看看 , 最後 try 看看 nginx reverse proxy
```
#local
curl 127.0.0.1:5000/WeatherForecast

#自己的 ip
curl 192.168.137.11:5000/WeatherForecast

#nginx reverse proxy
curl 192.168.137.11:8080/WeatherForecast

[{"date":"2021-08-27T01:37:59.6058877+00:00","temperatureC":-19,"temperatureF":-2,"summary":"Sweltering"},{"date":"2021-08-28T01:37:59.60589+00:00","temperatureC":52,"temperatureF":125,"summary":"Mild"},{"date":"2021-08-29T01:37:59.6058902+00:00","temperatureC":45,"temperatureF":112,"summary":"Sweltering"},{"date":"2021-08-30T01:37:59.6058903+00:00","temperatureC":42,"temperatureF":107,"summary":"Cool"},{"date":"2021-08-31T01:37:59.6058904+00:00","temperatureC":41,"temperatureF":105,"summary":"Warm"}]
```

最後重新開機看看
```
sudo reboot

systemctl --type=service
systemctl status forecast.service
```

看 log , log 有兩種普通的 log 跟 error log
```
#普通 log
cat /var/log/nginx/access.log

#error log
cat /var/log/nginx/error.log
```


### 包裝 docker
接著搞 docker , 參考[印度仔](https://dotnetthoughts.net/how-to-nginx-reverse-proxy-with-docker-compose/)
最大重點 `EXPOSE 5000` 跟 `ENV ASPNETCORE_URLS=http://+:5000` 最好放在最後一層 , 免得忘了加

Dockerfile
```
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build-env
WORKDIR /app


# Copy csproj and restore as distinct layers
COPY *.csproj ./
RUN dotnet restore

# Copy everything else and build
COPY . ./
RUN dotnet publish -c Release  -o out

# Build runtime image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
EXPOSE 5000
ENV ASPNETCORE_URLS=http://+:5000
WORKDIR /app
COPY --from=build-env /app/out .
ENTRYPOINT ["dotnet", "forecast.dll"]
```

執行
```
docker build -t forecast .
docker run -d --name forecast -p 5001:5000 forecast
```


最後 nginx 代理 , [參考自官方](https://hub.docker.com/_/nginx)

nginx 設定檔在 docker 上路徑有稍微不一樣 `/etc/nginx/conf.d/default`
一般要先複製現有的 nginx.conf 檔案讓 container 掛載 , 不然會無法啟動

首先先啟動一個 tmp 的 nginx container , 接著複製 container 裡面的  /etc/nginx 目錄到 host 的 /test-nginx 底下
```
#步驟一啟動暫時的 nginx 複製裡面的資料夾到 /test-nginx
docker run --name tmp-nginx-container -d nginx
sudo  docker cp tmp-nginx-container:/etc/nginx/ /test-nginx
docker rm -f tmp-nginx-container


#啟動正式的 nginx 提供代理
docker run -d -p 8087:80 -v /test-nginx:/etc/nginx --name nginx nginx
```

這邊設定 reverse proxy 參數讓 dotnet core 的 web api 可以被代理 , 注意修改後需要讓 nginx reload , 或是直接 restart nginx container
```
vim /test-nginx/conf.d/default

#try 看看 config 是否 ok
docker exec -it nginx nginx -t

#reload nginx 參數
docker exec -it nginx nginx -s reload


#懶得敲上面就直接 restart 應該也可以
#docker restart nginx
```

`conf.d/default`
```
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    #access_log  /var/log/nginx/host.access.log  main;

    location / {
        #root   /usr/share/nginx/html;
        add_header Access-Control-Allow-Origin '*';

		#dotnet web api 的 ip
        proxy_pass http://172.17.0.2:5000;
    }

    #error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    #
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    # proxy the PHP scripts to Apache listening on 127.0.0.1:80
    #
    #location ~ \.php$ {
    #    proxy_pass   http://127.0.0.1;
    #}

    # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
    #
    #location ~ \.php$ {
    #    root           html;
    #    fastcgi_pass   127.0.0.1:9000;
    #    fastcgi_index  index.php;
    #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
    #    include        fastcgi_params;
    #}

    # deny access to .htaccess files, if Apache's document root
    # concurs with nginx's one
    #
    #location ~ /\.ht {
    #    deny  all;
    #}
}
```

### envoy proxy
因為現代三不五時也會出現 envoy proxy 就隨手玩看看 , 有空在補完整點的筆記 , [可以看看大鬍子老外](https://www.youtube.com/watch?v=UsoH5cqE1OA)

設定 envoy 代理 .net core , 重點要加 cors 我雷了半天 , 最後發現是要加在 response_headers_to_add
另外 connect_timeout 官網明明寫預設會自動有 , 可是我 run 不起來只好手動加上去
```
static_resources:

  listeners:
  - name: listener_0
    address:
      socket_address:
        address: 0.0.0.0
        port_value: 10000
    filter_chains:
    - filters:
      - name: envoy.filters.network.http_connection_manager
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
          stat_prefix: ingress_http
          access_log:
          - name: envoy.access_loggers.stdout
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.access_loggers.stream.v3.StdoutAccessLog
          http_filters:
          - name: envoy.filters.http.router
          route_config:
            name: local_route
            virtual_hosts:
            - name: local_service
              domains: ["*"]
              response_headers_to_add:
              #允許 CORS
              - append: true
                header:
                  key: Access-Control-Allow-Origin
                  value: '*'
              routes:
              - match:
                  prefix: "/"
                route:
                  cluster: service_envoyproxy_io

  clusters:
  - name: service_envoyproxy_io
    connect_timeout: 5s
    type: LOGICAL_DNS
    # Comment out the following line to test on v6 networks
    dns_lookup_family: V4_ONLY
    load_assignment:
      cluster_name: service_envoyproxy_io
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 192.168.123.75
                port_value: 5001
```
