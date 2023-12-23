---
title: css 致敬幽遊白書片尾
date: 2023-09-25 02:07:14
tags:
- css
- js
---
![yuyu](https://raw.githubusercontent.com/weber87na/flowers/master/yuyu10.png)
<!-- more -->

<iframe width="688" height="480" src="https://www.youtube.com/embed/8jvGQuprP-w" title="幽遊白書 ED4 「太陽がまた輝くとき」(TV Size) HD" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

最近不曉得為啥 youtube 推薦富奸的幽遊白書 , 還是仙水篇 XD 應該至少有個 20 年沒看了吧 , 小時候看覺得仙水篇最精采 , 仙水就是個很複雜的角色阿 ~
然後看到片尾曲的效果就來順便寫看看 , 本來以為用 css 就全部搞定 , 可是照片浮起來的效果實在太機車了 , 最後還是靠 js 處理這塊

本來一開始做的時候是直接在每個 `photo` 上面去設定動畫旋轉效果 , 弄完才發現暈了 , 應該要圍繞著一個中心點轉
所以開了兩個中心點來用 , 一個讓照片跟著中心點轉 , 另外一個則是讓照片浮起來時當作參考位置用
這裡會用到一個老技巧 , 當設定父層這樣的時候 , 之後的子層就會從中間開始計算 , 比較符合常人思考的座標 , 而不是電腦座標 , 不然正常 `left:0 top:0` 都是從左上角計算
``` css
	position: absolute;
	margin: auto;
	left: 0;
	right: 0;
	bottom: 0;
	top: 0;
```

動畫的部分每隔 `10%` 增加 `36deg` , 最常見的雷大概就是 `deg` 忘了寫 , 還有做這類的東西最好角度都用正數 , 不然用負數到時候靠程式計算會被自己雷到 XD
``` css
	0% {
		--deg: 0deg;
	}

	10% {
		--deg: 36deg;
	}

	20% {
		--deg: 72deg;
	}
```

然後他圖片的灰色跟模糊效果就是如下 , 另外有時候會看到一些網站整頁都是灰色那是因為它直接在 `html` 設定 `filter: grayscale(100%)`
```
filter: grayscale(100%) blur(3px);
```

最後就是 js 的部分 , `run` 會取得隨機的照片元素 , 套用預先定義好的樣式 , 然後把它附加到 `outer-center` , 而 `clear` 則是清除樣式 , 並且把元素還原回 `center` 裡面
兩個函數結尾都會先 `clearInterval` 接著從新循環 `setInterval`
``` js
var photoNum = 1
var filterNum = 1
var interval = setInterval(run, 3000)

function clear() {
	let p = document.querySelector('.photo' + photoNum.toString())
	let center = document.querySelector('.center')
	p.classList.remove('normal-filter' + filterNum.toString())
	center.appendChild(p)
	clearInterval(interval)
	interval = setInterval(run, 3000)
}

function run() {
	photoNum = getRandomNumber(1, 20)
	let p = document.querySelector('.photo' + photoNum.toString())
	let outerCenter = document.querySelector('.outer-center')
	filterNum = getRandomNumber(1, 3)
	p.classList.add('normal-filter' + filterNum.toString())
	outerCenter.appendChild(p)
	clearInterval(interval)
	interval = setInterval(clear, 3000)
}

function getRandomNumber(min, max) {
	return Math.floor(Math.random() * (max - min + 1) + min);
}
```

<p class="codepen" data-height="620" data-default-tab="result" data-slug-hash="MWZVWbK" data-user="weber87na" style="height: 620px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/MWZVWbK">
  Untitled</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>
