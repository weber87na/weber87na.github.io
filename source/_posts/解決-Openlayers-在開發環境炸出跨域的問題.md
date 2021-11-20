---
title: 解決 Openlayers 在開發環境炸出跨域的問題
date: 2021-11-16 00:31:38
tags: GIS
---
&nbsp;
<!-- more -->

印象中好像是以前做匯出圖片又串一堆 wms 所以會讓 canvas 的 `getImageData` 炸出一堆跨域問題
如果碰不到 server 又要暫時開發順利的話可以這樣設定將就一下
或是也可以參考 [css 大神](https://www.zhangxinxu.com/wordpress/2018/02/crossorigin-canvas-getimagedata-cors/) 類似的解法

### chrome
複製 chrome 捷徑點選 `內容` 在 `目標` 設定這樣
"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe" --allow-file-access-from-files
記得要使用時先關掉全部的 chrome 才會有效

### ie
點齒輪 => `Internet Options` => `Security` => `Custom level` => `Miscellaneous` => `Access data sources across domains` => `Enable`
