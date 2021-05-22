---
title: chrome 快速切換 url 小技巧
date: 2020-08-20 06:04:04
tags:
- chrome
---
&nbsp;
<!-- more -->
在 chrome 一個長年困擾的問題，我用 vim 一陣子了，每次都要使用滑鼠移動到 url 網址列上很浪費時間，卻一直懶得找出方法
無意中發現 ctrl + L 可以在 chrome 快速移動到 url 網址列
但是取消 focus 呢 ?

<!-- more -->

只好參考[老外](https://xavierchow.github.io/2016/03/07/vimium-leave-address-bar/) 及 [chrome文件](https://support.google.com/chrome/answer/95426?co=GENIE.Platform%3DDesktop&hl=en)
後來發現下面有老外留言說只要按兩次 F6 或是 shift + F6 在 windows 底下也可以搞定
結果更下面的老外婊說 mac 沒法 F6

原來可以透過以下步驟快速完成這個操作
chrome -> more -> settings -> search engines -> Other search engines -> add
Search engine 輸入 leaveAddressBar 隨便啦
Keyword 輸入 u 或其他你喜歡的按鍵
URL with %s in place of query 輸入 javascript:

終於解決長年來的困擾感動!
