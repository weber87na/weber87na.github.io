---
title: css grid 刮刮樂
date: 2023-08-22 22:16:19
tags:
- css
- js
---
&nbsp;
<!-- more -->

<p class="codepen" data-height="500" data-slug-hash="yLGywQy" data-user="weber87na" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/yLGywQy">
  一哭二鬧</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

<iframe width="853" height="480" src="https://www.youtube.com/embed/NQY69CNrcus" title="css grid 刮刮樂" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

今天無意間看到強國人[這篇寫刮刮樂的](https://juejin.cn/post/7134634087901298695) , 看他這個寫法應該是 vue
記憶中小時候有賣那種刮刮樂貼紙 , 只要貼上去就可以做出刮刮樂 , 自己也來寫看看

我的想法是直接用 `grid` 然後在裡面塞一堆格子 , 我先開一個 `50 * 50` 格的空間出來
然後在 `grid` 放上底圖 , 這裡就放一哭二鬧比較多人認識 , 雖然我比較喜歡三姊妹 XD
接著當 `hover` 到格子就設定透明度為 0 , 本來想說看看有無辦法不靠 js , 不過一時想不出來

這裡我懶得安裝 vue 這裡就直接用 vscode 的 `emmet` 來生
我測了下 `emmet` 好像上限就是 `1000` 個元素 , 超過就生不出來
所以當超過 `1000` 時可以用下面這個語法指定從 `1001` 開始計算 , 所以蓋 2500 格會這樣打
```
.item$*1000
.item$@1001*1000
.item$@2001*500
```

產生出 1 - 2500 格的 html
```
<div class="card">
	<div class="item1"></div>
	<div class="item2"></div>
	<div class="item3"></div>
	<!-- 更多格子 -->
	<div class="item2500"></div>
</div>
```

接著 css 的部分可以運用正則 `[class^="item"]` 直接取得開頭為 `item` 的 , 我加上數字是為了好 debug , 不加應該也可以
```
	* {
		margin: 0;
		padding: 0;
	}

	body {
		display: flex;
		justify-content: center;
		align-items: center;
		height: 100vh;
		cursor:ponter;
	}

	/* 用 grid 做出很多格子 */
	.card {
		width: 400px;
		height: 400px;
		border: 1px solid #000;
		display: grid;
		grid-template-columns: repeat(50, 1fr);
		grid-template-rows: repeat(50, 1fr);
		grid-column-gap: 0px;
		grid-row-gap: 0px;
		position: relative;

		/* background-image: url('girl.jpg'); */
		background-image: url('https://pgw.udn.com.tw/gw/photo.php?u=https://uc.udn.com.tw/photo/2023/06/23/0/22803886.jpg&x=0&y=0&sw=0&sh=0&sl=W&fw=500&exp=3600&w=930');
		background-position: left center;
		background-size: cover;
	}

	[class^="item"] {
		background-color: rgb(150, 150, 150);
		opacity: 1;
	}

	[class^="item"]:hover {
		opacity: 0;        
	}
```

最後 js 直接取得所有格子 , 然後當滑鼠移走的時候保持透明度也是 0
```

let items = document.querySelectorAll('[class^="item"]')
Array.from(items).forEach(x=>{
	x.addEventListener('mouseleave',function(){
		this.style.opacity = 0
	})
})
```


後來研究下 `animation` 發現他有個暫停屬性 , 所以只要把 css 的部分改成下面這樣就真的可以不用 js 了 XD
我的想法是一開始先讓動畫暫停 , hover 過去才撥放
這裡有個重點先在 `item` 一開始要設定 `opacity` 為 `0 透明` , 他會第一個執行 , 不然你 `hover` 過去正常 `hover` 回來會很靈異
然後他跑 `animation 0%` 設定不透明
最後 `100%` 的時候設定透明 , 然後 `paused` , 不寫應該也是回到 `paused` 因為 `item` 上面本來就有設定 `paused`
至於為啥我要寫 `[class^="item"]` 是因為我其他 case 還是有程式化需求
如果 opacity 效果覺得不好應該也可以換 z-index 看看
``` css
	[class^="item"] {
		background-color: rgb(150, 150, 150);
		/*透明*/
		opacity: 0;
		animation: scratch 0.1s;
		animation-play-state: paused;
	}

	[class^="item"]:hover {
		animation-play-state: running;
	}

	@keyframes scratch {
		0% {
			/*不透明*/
			opacity: 1;
		}

		100% {
			/*透明*/
			opacity: 0;
			/*不寫也可以*/
			animation-play-state: paused;
		}
	}
```


最後覺得沒有硬幣好像沒那麼有 fu , 可以先用手機拍個 1 摳
然後到 [這裡](https://www.remove.bg/) 去背
接著到 [這裡](https://www.photopea.com/) 把硬幣框起來 , 然後選 `image` => `crop`
接著改圖片大小為 `60` , 在 css 裡面 `cursor` 最大好像支援到 `128`
最後在 `card` 上面設定這樣即可 , 30 表示它的中心位置
``` css
cursor: url('onedollar60.png') 30 30, auto;
```
