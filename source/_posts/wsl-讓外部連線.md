---
title: wsl 讓外部連線
date: 2024-09-11 10:51:09
tags: wsl
---
&nbsp;
<!-- more -->

工作上遇到的問題, 以前好像設定過, 久了又忘了, 筆記下
我有一台 wsl 裡面是 ubuntu ip 是 `172.1.23.45`
我 windows 的 ip 則是 `10.1.23.45`
windows 可以用 localhost 正常連到 wsl 內的 docker 服務, 但是發現 wsl 沒辦法讓外部連
希望外部的電腦可以訪問到 wsl `172.1.23.45` 裡面某個 `8080` port 的服務

顯示

```
netsh interface portproxy show all

接聽 ipv4:             連線到 ipv4:

位址            連接埠      位址            連接埠
--------------- ----------  --------------- ----------
0.0.0.0         8081        172.30.86.10    8081
```

新增 `需要用系統管理員 gsudo`

```
netsh interface portproxy add v4tov4 listenaddress=10.1.23.45 listenport=8080 connectaddress=172.1.23.45 connectport=8080
```

移除

```
netsh interface portproxy delete v4tov4 listenaddress=10.1.23.45 listenport=8080
```

