---
title: AWS Route 53 筆記
date: 2022-05-06 09:34:43
tags: AWS
---
&nbsp;
<!-- more -->

一直以來都沒有自己的網域 , 今天嘗試在 [GoDaddy](https://tw.godaddy.com/) 買看看
整個買的過程還算是簡單就沒詳細記錄 , 除了英文網域以外也有賣中文網域
買完後搭配 aws 雲端主機 (ubuntu) 及 aws route 53 來設定看看

### aws route 53 設定
可以參考這個[印度人影片](https://www.youtube.com/watch?v=hRSj2n-XKGM)

先點選 `create hosted zone`
接著點選 `create record`
輸入你的網域 `ggyy.com.tw`
輸入你的 ip `123.45.67.89`

接著建立 `cname`
輸入 `www.ggyy.com.tw`
輸入 `ggyy.com.tw`


最後想要 `subdomain` 的話
這個步驟是跟主 domain 在同一個 hosted zone 下面
點選 `create record`
輸入你的網域 `blog.ggyy.com.tw`
輸入跟主網域一樣的 ip `123.45.67.89`

接著建立 `subdomain` 的 `cname`
點選 `create record`
輸入你的網域 `www.blog.ggyy.com.tw`

### GoDaddy 設定
接著回到 GoDaddy 自行更改對應的網域 https://dcc.godaddy.com/manage/ggyy.com.tw/dns

`接著點選域名伺服器` => `變更`

預設可能是這樣
```
ns41.domaincontrol.com
ns42.domaincontrol.com
```

ns (nameserver) 要改成 aws route 52 上面發的 4 個 , 等大概 5分鐘 , 到這邊應該就能動了
```
ns-8778.awsdns-42.fq.uk
ns-5987.awsdns-05.org
ns-0487.awsdns-61.com
ns-9487.awsdns-44.net
```

### 中文網域問題
後來發現 aws 上面好像不能用中文網域 , 所以我直接用 GoDaddy 的 , GoDaddy 網站如果會導到 `Parked` 的話應該要把 `Parked` 換成自己的 ip

另外如果用 certbot 申請 https 中文網域的話會噴下面這些
```
Non-ASCII domain names not supported. To issue for an Internationalized Domain Name, use Punycode.
Ask for help or search for solutions at https://community.letsencrypt.org. See the logfile /tmp/tmpql1tj5r8/log or re-run Certbot with -v for more details.
```

所以在用 certbot 時要改回用他付給你的怪異網址去申請 (我這邊用 GoDaddy) 大概會長類似這樣
```
sudo certbot --nginx -d xn--test-tk3h402d.com -d www.xn--test-tk3h402d.com
```

### github page 設定
參考[這篇](https://askie.today/customize-hexo-blog-url-on-github-pages/)
[官網文件](https://docs.github.com/cn/pages/configuring-a-custom-domain-for-your-github-pages-site/managing-a-custom-domain-for-your-github-pages-site)

先到你 github 放 blog 的 repo 上面
`Settings` => `Code and automation` => `Pages`

找到 `Custom domain` 輸入你的網址 `www.blog.lasai.com.tw`

在 AWS Route 53 建立一個 `CNAME`
`www.blog.lasai.com.tw` 讓他指到 `weber87na.github.io`

最後在 hexo 的 source 資料夾底下蓋個 `CNAME` 即可
```
vim CNAME
www.blog.lasai.com.tw
```

最後等他跑下記得要勾上強制 `https`
