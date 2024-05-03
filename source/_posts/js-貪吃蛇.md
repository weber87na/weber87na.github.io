---
title: js 貪吃蛇
date: 2024-02-11 14:30:40
tags: js
---
&nbsp;
<!-- more -->

龍年啦 無聊寫個貪吃龍來玩玩
記憶中學生時期還是用 nokia 的無敵 3310 手機 , 裡面附的貪吃蛇伴我渡過不少個 `沒翹課` 也 `沒睡著` 的時光
很後悔以前念書沒好好念 , 貪吃蛇應該是寫不出來低 , 這回來試看看
不過又兩三個月沒寫 js 了 , 忘得差不多

重點如下

蛇的身體移動其實就是讓 `上個方塊移動前` 的位置賦予到上面
```
function moveBody(before) {
  for (var i = 1; i < snake.length; i++) {
    var prev = before[i - 1]
    snake[i].x = prev.x
    snake[i].y = prev.y
  }
}
```

用 `JSON.parse(JSON.stringify(xxx))` 來複製 Array 物件 , 避免修改到 reference
如果直接改 Array 或是用展開運算子 [...xxx] 都會改到 reference
```
function right() {
  var before = JSON.parse(JSON.stringify(snake))
  head.x += 1 * cellSize
  moveBody(before)
  gg = hitSelf() || isOutOfWorld()
  if (gg) alert('gg')
  eatStar()

}
```

canvas 縮放電腦跟手機板可用 `matchMedia` 這個 js 函數 , 來決定 canvas 大小
```
let canvasSize = 500

//假如手機的話用 300 * 300
//電腦則是 500 * 500
var isMobileMatch = window.matchMedia("(max-width: 400px)")
if (isMobileMatch.matches) {
  canvasSize = 300
  console.log('canvasSize', canvasSize)
}
canvas.width = canvasSize
canvas.height = canvasSize
```

<p class="codepen" data-height="300" data-default-tab="result" data-slug-hash="ExMdvrY" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/ExMdvrY">
  貪吃龍</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>
