---
title: NCL 網格資料地雷
date: 2020-07-06 23:44:32
tags:
- ncl
- wrf
- gis
---
&nbsp;
<!-- more -->
一般的網格資料都會是切成等間距的方格 , 鮮少會遇到不規則狀.

某次拿到一組網格資料在地圖上怎麼畫就是不對 , 本來以為是投影問題 , 沒想到原來是資料源的網格是不規則狀

後來在 NCL 官網爬了很久才發現使用 NCL 產製的網格分為 Gaussian Grids , Fixed Grids , Fixed-Offset Grids , Regular Grids , Curvilinear Grids
共 5 種 , 詳細可以參考[這個說明](https://www.ncl.ucar.edu/Document/Functions/sphpk_grids.shtml)

最後在 NCL 官網上找到[相關函數](https://www.ncl.ucar.edu/Applications/regrid.shtml)

下面這張圖參考[相關函數](https://www.ncl.ucar.edu/Applications/regrid.shtml)的 ESMF_regrid_32.ncl

非常明顯可以看出來從不規則的 WRF 資料網格轉換為等間距的固定網格

<img src="https://www.ncl.ucar.edu/Applications/Images/ESMF_regrid_32_lg.png" />

