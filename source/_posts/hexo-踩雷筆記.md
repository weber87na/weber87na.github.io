---
title: hexo 踩雷筆記
date: 2020-08-22 03:00:46
tags:
- hexo
---
&nbsp;
<!-- more -->
## 如何設定純 html 檔案
想要新增我的喇賽地圖到網頁上，但是如何新增純html檔案呢？
在 _config.yml 底下找到 skip_render 加上 資料夾名稱/* 就搞定了

```
skip_render: map/*
```

## 如何設定繁體中文語系
我發現我自己的 menu 一直是英文語系但是我明明有設定中文了呀
後來發現原來是我的 zh-tw 設定是小寫，實際上應該要寫為 zh-TW (一樣在 _config.yml 底下)
```
language: zh-TW
```

## 如何客製化自己的 css
我看網路上的其他教學大部分都是舊版，後來翻了文件發現要先在 next 底下的 _config.yml 設定
```
~/gg/themes/next/_config.yml

custom_file_path:
  style: source/_data/styles.styl
```
接著在自己的 source 資料夾底下建立資料夾 _data 以及檔案 styles.styl，這邊要特別注意不是在 next 資料夾底下
接著可以寫個測試的樣式如果正常執行就搞定了，因為忌妒別人有緞帶我也要有就拿他為例子
```
.content-wrap {
    border-bottom-left-radius: 85px 155px;
    border-bottom-right-radius: 225px 35px;
    border-top-left-radius: 55px 15px;
    border-top-right-radius: 155px 25px;
    border: 2px solid #41403e;
    position: relative;
    overflow:hidden;
}
.content-wrap:after {
    /* color : #fff000; */
    /* background-color : #000; */
    color : #000;
    background-color : #fff000;
    z-index:99;
    font-size:22px;
    text-align:center;
    content:'別人有緞帶我也要有';
    top:50px;
    left:-40px;
    position: absolute;
    /* position: fixed; */
    transform:rotate(-35deg);
    width:280px;
    height:40px;
    border-bottom-left-radius: 85px 155px;
    border-bottom-right-radius: 225px 35px;
    border-top-left-radius: 55px 15px;
    border-top-right-radius: 155px 25px;
    border: 2px solid #41403e;
}
```

