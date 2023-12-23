---
title: css 自訂 cursor 致敬 cs1.6
date: 2023-09-21 18:36:18
tags:
- css
- js
---
![dust2](https://raw.githubusercontent.com/weber87na/flowers/master/dust2.png)
<!-- more -->

<p class="codepen" data-height="500" data-default-tab="result" data-slug-hash="xxmpdZO" data-user="weber87na" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/xxmpdZO">
  cs1.6_dust2</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

自訂游標印象中以前在 `winform` 還有 `openlayers` 都有做過類似的案例 , 今天就來致敬下 `cs1.6` 的準心效果
之前寫刮刮樂的時候是用 `cursor` 發現有些限制只能用 `icon` , 偶然發現[這篇](https://medium.com/@flemming.dierlamm/create-a-simple-custom-cursor-87d033398c95)
研究下它的原理就是設定 `position: fixed` 然後當滑鼠移動時修改那個 `cursor div` 的位置 , 搞了半天還是要用這種 `hacker` 的方法才行
後來先寫出普通準心還算簡單 , 可是狙擊鏡讓人想半天
最後用個很大的 `border` 蓋住整個範圍 , 然後把 `cursor div` 背景顏色設定透明即可
後來發現還有 [clip-path](https://bennettfeely.com/clippy/) 這種屬性可以用 , 說不定也可以兜出來 , 就遇到再說吧
