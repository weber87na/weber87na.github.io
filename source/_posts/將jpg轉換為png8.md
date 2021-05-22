---
title: 將jpg轉換為png8
date: 2020-07-05 14:11:45
tags:
- imagemagick
- gis
---
&nbsp;
<!-- more -->
某次任務中有個GIS軟體也是使用圖磚影像 , 詭異的是將圖磚丟進去卻無法讀取 , 後來經高人指點才發現原來該軟體吃的是 png8 格式 , 最後用 imagemagick 進行轉換 搞定!
```
magick convert d:\map.jpg png8:d:\map.png
```
當以為收工時圖磚卻出現了奇怪的雜點發現要加上-colors 256 才能讓 png8 有較好的色彩效果
```
magick convert d:\map.jpg -colors 256 png8:d:\map.png
```
