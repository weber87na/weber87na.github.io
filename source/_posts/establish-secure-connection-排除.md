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
找到 Cryptographic Services => `右鍵` => `內容` => `停止` => `啟動` => `自動`
搜尋 `網際和網路` => `狀態` => `網路重設`
重新開啟電腦應該就可以了
