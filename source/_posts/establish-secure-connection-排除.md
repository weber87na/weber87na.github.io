---
title: establish secure connection 排除
date: 2020-08-30 23:19:34
tags:
- chrome
---
&nbsp;
<!-- more -->
七月問題多，今天 windows 更新後 chrome 莫名其妙發生 establish secure connection 導致一直開不起網頁
用手機爬文後發現可以參考[這篇](https://support.google.com/chrome/thread/2029071?hl=en)進行排除
<kbd>win + r</kbd>
```
services.msc
```
接著關閉服務 Cryptographic Services
然後以系統管理員開啟 cmd or windows terminal 輸入底下指令應該就可以解決
```
netsh winsock reset
```
後來又有問題[參考](https://appuals.com/how-to-fix-the-establishing-secure-connection-slow-problem-in-google-chrome/)這篇有點崩潰
