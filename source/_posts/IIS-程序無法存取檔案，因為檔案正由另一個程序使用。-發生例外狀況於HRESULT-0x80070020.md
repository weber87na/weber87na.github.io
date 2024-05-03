---
title: 'IIS 程序無法存取檔案，因為檔案正由另一個程序使用。(發生例外狀況於HRESULT:0x80070020)'
date: 2024-04-23 22:25:21
tags:
---

&nbsp;
<!-- more -->

今天發生個靈異事件 IIS 莫名其妙就無法啟動然後噴這句 `程序無法存取檔案，因為檔案正由另一個程序使用。(發生例外狀況於HRESULT:0x80070020)`

主要參考[這篇](https://marcus116.blogspot.com/2019/03/iis-hresult0x80070020.html)

照著輸入指令 , 找到佔住 80 的 pid 然後砍了他即可
```
netstat -ano
```

最後發現是之前有安裝 ab 這個測試工具 , 導致 Apache24 的服務自動啟動 , 才導致 80 port 被佔住 , 把它服務停止就好 , 他路徑在此
```
C:\Users\YOURNAME\AppData\Roaming\Apache24\bin
```



