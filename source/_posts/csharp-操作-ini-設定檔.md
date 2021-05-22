---
title: csharp 操作 ini 設定檔
date: 2021-01-10 20:34:07
tags: csharp
---
&nbsp;
<!-- more -->

生涯中好像第二次做這種類似的任務，多半是一些比較古老的系統會使用 ini 這種格式進行 config。
可以使用好用套件 [SharpConfig](https://github.com/cemdervis/SharpConfig)
整體操作還滿簡單的讀取 section => 選擇屬性大概就可以做好了，可以看他的 example ，美中不足的雷點就是他的 ToObject 函式，
明明沒有那個 section 卻依然會建立出物件來，但是屬性回全部給 null ，有點怪怪的。
有空在把跟 automapper , ef 的整合放上來。
