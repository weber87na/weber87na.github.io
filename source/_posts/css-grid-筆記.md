---
title: css grid 筆記
date: 2022-10-04 21:05:08
tags: css
---
![蒙娜麗莎](https://raw.githubusercontent.com/weber87na/flowers/master/MonLaLisa.png)
<!-- more -->

練習 grid 順便筆記 , 想到啥就寫啥 XD
### 眼睛跟隨滑鼠轉動
記得之前有看到大陸人寫類似原理 , 可是一時找不到在哪 , 反正就是有老外寫出可愛表單 , 眼睛會跟著滑鼠轉動就對了
剛好寫到 grid 練習看看 , 先設定 5x5 的 grid 然後 hover 時就去改上下左右定位
比較意外的是用 position absolute 搭配上下左右為 0 及 margin 的居中後 , 這時再去設定內層定位竟然格外輕鬆 , 算是屎運矇到 XD

<p class="codepen" data-height="300" data-default-tab="result" data-slug-hash="wvjXQQp" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/wvjXQQp">
  MonnaLisa</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>
