---
title: chrome 設定允許 http
date: 2022-05-15 15:25:42
tags: chrome
---
&nbsp;
![chrome](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Google_Chrome_icon_%28February_2022%29.svg/480px-Google_Chrome_icon_%28February_2022%29.svg.png)
<!-- more -->

有時候在開發東西 , 但是對方的 server 沒有開 https , 通常就會炸 mix-content
這時可以在 chrome 打上這串
```
chrome://flags/#unsafely-treat-insecure-origin-as-secure
```

接著設定 `Insecure origins treated as secure ` 打上 ip 即可過關 `http://123.45.123.456:1234`
