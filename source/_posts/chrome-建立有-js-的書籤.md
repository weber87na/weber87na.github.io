---
title: chrome 建立有 js 的書籤
date: 2020-11-21 08:17:56
tags: chrome
---
&nbsp;
<!-- more -->
工作上遇到常常需要切換多組帳號，每次都要敲帳號密碼覺得很麻煩，所以研究有無方法可以自訂 script
首先輸入 chrome://bookmarks/
右鍵 add new bookmark
然後在 url 打上自訂的 js 即可，注意需要把 js 壓成一整行才會正常執行

``` javascript
javascript: alert('hello world')
```
後來跟低能兒一樣傻傻壓縮，原來在 vim 裡面可以先切換到 visual mode 選取多行，接著 shift + j 快速壓成一行，vim 的指令太多久沒用又忘光了，慘
