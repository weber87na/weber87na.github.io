---
title: Lets Encrypt 筆記
date: 2022-05-06 09:59:34
tags: ubuntu
---
&nbsp;
<!-- more -->

[主要參考這篇](https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-22-04)
我的環境是 AWS EC2 上面的 Ubuntu 22.04 , 並且安裝 nginx 在 ubuntu 上 , nginx 可以參考我[這篇](https://weber87na.github.io/2021/08/25/nginx-%E7%AD%86%E8%A8%98/)

### 安裝步驟
```
sudo snap install core; sudo snap refresh core

#有裝舊版的話要移除
sudo apt remove certbot

sudo snap install --classic certbot

#建立連結沒加應該也沒差
sudo ln -s /snap/bin/certbot /usr/bin/certbot
```

### 設定 nginx

確保自己的設定有在 `server_name` 這段並且已經設定自己的網域 , 如果沒有自己的網域可以先到 GoDaddy 購買 , 可以參考我[這篇設定](https://weber87na.github.io/2022/05/06/AWS-Route-53-%E7%AD%86%E8%A8%98/)
```
cat /etc/nginx/sites-available/default

#server_name ggyy.com.tw;
```

最簡單的 nginx 設定大概長這樣
```
server {
    listen        80;
    server_name   ggyy.com.tw www.ggyy.com.tw;
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

```

### 設定防火牆
因為我用 aws 的雲端服務 , 所以這段應該是到 web 介面設定!?


### 申請憑證
他這裡會問你 email 輸入完後按 enter
```
sudo certbot --nginx -d ggyy.com.tw -d www.ggyy.com.tw

#Saving debug log to /var/log/letsencrypt/letsencrypt.log
#Enter email address (used for urgent renewal and security notices)
```

萬一打錯 domain 會跳這樣
```
Client with the currently selected authenticator does not support any combination of challenges that will satisfy the CA. You may need to use an authenticator plugin that can do challenges over DNS
```

正常的話會給這樣的訊息
```
Saving debug log to /var/log/letsencrypt/letsencrypt.log
Requesting a certificate for ggyy.com.tw

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/ggyy.com.tw/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/ggyy.com.tw/privkey.pem
This certificate expires on 2022-08-03.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

Deploying certificate
Successfully deployed certificate for ggyy.com.tw to /etc/nginx/sites-enabled/default
Congratulations! You have successfully enabled HTTPS on https://ggyy.com.tw

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
If you like Certbot, please consider supporting our work by:
 * Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
 * Donating to EFF:                    https://eff.org/donate-le
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```

最後你要看看之前的 nginx 設定檔 ,
```
cat /etc/nginx/sites-available/default
```


如果你已經申請過了然後又要補的話會長這樣 , 像我忘了加 www , 所以再補一次
```
sudo certbot --nginx -d ggyy.com.tw -d www.ggyy.com.tw


You have an existing certificate that contains a portion of the domains you
requested (ref: /etc/letsencrypt/renewal/ggyy.com.tw.conf)

It contains these names: ggyy.com.tw

You requested these names for the new certificate: ggyy.com.tw,
www.ggyy.com.tw.

Do you want to expand and replace this existing certificate with the new
certificate?
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
(E)xpand/(C)ancel: E
Renewing an existing certificate for ggyy.com.tw and www.ggyy.com.tw
```


### 自動更新

這裡好像預設就有自動更新
```
sudo systemctl status snap.certbot.renew.service
```

最後測試看看 , 正常會長這樣
```
sudo certbot renew --dry-run

Saving debug log to /var/log/letsencrypt/letsencrypt.log

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Processing /etc/letsencrypt/renewal/ggyy.com.tw.conf
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Account registered.
Simulating renewal of an existing certificate for ggyy.com.tw and www.ggyy.com.tw

- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
Congratulations, all simulated renewals succeeded:
  /etc/letsencrypt/live/ggyy.com.tw/fullchain.pem (success)
- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
```



### 其他參考
其他應該可以[參考看看](https://blog.hellojcc.tw/setup-https-with-letsencrypt-on-nginx/)
[letsencrypt 官網文件](https://letsencrypt.org/zh-tw/docs/)
[certbot 官網文件](https://certbot.eff.org/)
[保哥](https://blog.miniasp.com/post/2021/02/11/Create-SSL-TLS-certificates-from-LetsEncrypt-using-Certbot)
[willcard](https://codex.so/wildcard-ssl-certificate-by-let-s-encrypt)
