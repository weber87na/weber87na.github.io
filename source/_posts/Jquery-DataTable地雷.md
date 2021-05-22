---
title: Jquery DataTable地雷
date: 2020-07-05 21:40:52
tags:
- jquery
- jquery datatable
---
&nbsp;
<!-- more -->
工作上遇到一個非常雷的問題 , 我串接其他 3rd 的 api 原本以為是資料量過大導致 jquery datatable 跟前端回應較慢 , 問題是這個 api 速度極為不穩定從 3 - 5 秒到 30 秒以上都有可能發生 , 害我一度以為要做後端 pagging . 

最後發現原來是 jquery datatable 要設定 [deferRender 這個 option](https://datatables.net/examples/ajax/defer_render.html) 這樣 render 速度才會快 , 這個痛點搞了我整整一週時間去 Trace 沒想到是前端的問題 無奈 ..
