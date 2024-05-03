---
title: css 龍珠雷達
date: 2024-03-10 15:16:55
tags: css
---
&nbsp;
<!-- more -->


<p class="codepen" data-height="500" data-default-tab="result" data-slug-hash="gOyPVJE" data-user="weber87na" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/gOyPVJE">
  DragonBallRadar</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

看到龍珠的作者掛了 RIP ~
以前一直想寫個龍珠雷達 , 可是因為懶都沒實際行動 , 而且滿多人寫過了 , 這次就正好來致敬下
太久沒寫 css , 又整個忘光光 QQ
主要參考[這個玩具的圖](https://www.toy-people.com/?p=49093)

自己覺得比較特別的點應該是雷達螢幕周圍的陰影 , 這裡分別套上四個 inset 的陰影表示上下左右

```
box-shadow: inset 0px 15px 15px #333333,
	inset 0px -10px 10px #272626,
	inset 10px 0px 15px #302f2f,
	inset -10px 0px 10px #444;
```

外殼的陰影可以用 `radial-gradient` 並搭配第一個參數為 `circle at 75%` 來調整圓的位置 , 看要怎樣偏移
```
background: radial-gradient(circle at 75%, #a0a0a0, #eee 75%, #fff 100%);
```

按鈕的部分則是可以用 `linear-gradient` 來調整光影
```
background: linear-gradient(to right,#fff,#dddddd 20%, #b9b9b9 90%, #f3f3f3);
```

螢幕格線的部分 , 因為之前做俄羅斯方塊 , 直接偷懶用 canvas 複製貼上來畫 XD , 記得要把 canvas 的邊框角度設定這樣 `border-radius: 50%`
```
let canvas = document.querySelector('#canvas')
let ctx = canvas.getContext('2d')
ctx.fillStyle = 'white'
function drawCells() {
	ctx.strokeStyle = 'black'
	ctx.fillStyle = "#000000";
	for (let y = 0; y < 10; y++) {
		for (let x = 0; x < 10; x++) {
			ctx.strokeRect(x * 35, y * 35, 35, 35);
		}
	}
}
drawCells()
```

中心三角形的部分直接偷用[這個網站](https://leekoho.github.io/)
```
width: 0;
height: 0;
border-style: solid;
border-width: 0 17.5px 30.3px;
border-color: transparent transparent #E94000;
```
