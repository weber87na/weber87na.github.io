---
title: js canvas 手寫塗鴉
date: 2024-07-09 23:38:31
tags: js
---

<p class="codepen" data-height="700" data-default-tab="result" data-slug-hash="NWZWJRB" data-pen-title="Canvas手寫Demo" data-user="weber87na" style="height: 700px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/NWZWJRB">
  Canvas手寫Demo</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>
<!-- more -->

今天沒啥 fu 一直想搞個小畫家之類的, 還有之前在搞啥 FineReport 長官很想要有啥手寫簽名, 無聊就寫看看
本來覺得沒啥, 實際上也是要 try 才曉得一堆雷 XD

### 手機效果

先說電腦版, 電腦版用到 `mousedown mouseup mousemove` 事件
我的想法是用 `mousedown mouseup` 搭配 `isDrawing` 這個 flag 當作是否正在手寫
如果 `mousemove` 觸發的話則把它畫出來, 這裡可以直接拿到 `offsetX offsetY` 這兩個座標
這裡最關鍵就是當 isDrawing 時畫線, 反之讓他的 `ctx.beginPath()` 還原, 才可以正常做出想要的效果

```js
canvas.addEventListener('mousemove', (e) => {
	console.log(e);
	console.log(e.offsetX, e.offsetY);
	let x = e.offsetX;
	let y = e.offsetY;

	point.x = x;
	point.y = y;

	if (isDrawing) {
	  drawLine(ctx, point);
	} else {
	  //萬一非 Drawing 狀態則使用 beginPath 還原
	  ctx.beginPath();
	}
});
```

最後呼叫 `drawLine` 就可以畫出來了, 這裡的 `drawLine` 搞比較久, 換了好幾種作法畫起來都會是一點一點的, 解鎖小畫家筆刷的原理 XD
另外如果每次都用 `ctx.beginPath()` 就會有怪小怪小的 bug`

```js
function drawLine(ctx, point) {
	let x = point.x;
	let y = point.y;
	ctx.lineTo(x, y);
	ctx.stroke();
}
```

手機版則是要依靠 `touchstart touchend touchmove` 這三個事件, 他們拿座標的方法不太一樣
另外就是要呼叫 `ctx.beginPath` 的寫法也不太一樣, 實測要下面這樣才正常

```js
canvas.addEventListener(
	'touchmove',
	(e) => {
		console.log(e);

		//獲取觸摸點的坐標
		const touch = e.touches[0];
		//計算相對於 Canvas 的 xy 坐標
		const x = touch.clientX - canvas.offsetLeft;
		const y = touch.clientY - canvas.offsetTop;

		point.x = x;
		point.y = y;

		if (isDrawing) drawLine(ctx, point);
	},
	false
);
```

最後存檔我直接偷懶用 ChatGPT 來生, 印象中以前搞 openlayers 好像也寫過把很多圖層變成一張圖的
當時折磨得半死還有 CORS 問題, 現在有 AI 來搞這些真的好快阿

```js
btnSave.addEventListener('click', () => {
	// 使用 toBlob 方法生成 Blob 對象
	canvas.toBlob(function (blob) {
	// 創建一個下載連結
	const a = document.createElement('a');
	a.download = 'canvas-image.png'; // 下載文件名

	// 生成一個 URL 對象來表示這個 Blob 對象
	const url = URL.createObjectURL(blob);

	// 設置下載連結的 href 屬性為這個 URL
	a.href = url;

	// 將下載連結插入到文檔中
	document.body.appendChild(a);

	// 點擊下載連結，下載圖片
	a.click();

	// 釋放 URL 對象的資源
	URL.revokeObjectURL(url);

	// 移除下載連結
	document.body.removeChild(a);
	}, 'image/png');
});
```

### Undo/Redo

後來又搞個 Undo/Redo 效果

<p class="codepen" data-height="700" data-default-tab="result" data-slug-hash="wvLKPby" data-pen-title="Canvas手寫Demo(可 Undo/Redo)" data-user="weber87na" style="height: 700px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/wvLKPby">
  Canvas手寫Demo(可 Undo/Redo)</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>

`Undo` 主要是依靠 `pop` 這個函數, 把最後一筆彈出去改變 array 大小
此時 array 的最後一筆即為上一步所繪製的圖

```js
if (imageListUndo.length > 0) {
	//取得最後一筆, 並縮減 array 大小
	var lastBlob = imageListUndo.pop();
	console.log('lastBlob', lastBlob);

	imageListRedo.push(lastBlob);

	//取得實際上要被繪製的圖片
	//如果 index 是負數的話會直接給 undefined
	var recoveryBlob = imageListUndo[imageListUndo.length - 1];
	console.log('realBlob', recoveryBlob);

	if (recoveryBlob) {
		renderImage(recoveryBlob);
	} else {
		clearCanvas();
	}
}
```

`Redo` 本身不難, 但萬一中間又執行其他動作會發生奇怪的現象
可以觀察小畫家先畫兩筆然後 `Undo` 之後又接著畫, 就可以得到正確邏輯
為了因應這個操作, 必須要有 `canRedo` 這個變數來決定可否使用 `Redo` 的功能

所以當執行 `Undo` 時將 `canRedo` flag 設為 `true`

```js
if (event.ctrlKey && (event.key === 'z' || event.key === 'Z')) {
	// 使用者按下了 Ctrl + Z
	console.log('User pressed Ctrl + Z');

	// 讓使用者可以呼叫 redo
	canRedo = true;
	
	//其他 code ...
```

萬一中間有新增筆畫的話需要於 `mouseup` 加上 `canRedo` 這個判斷, 需要把 `canRedo` 回歸為 `false` 並且 `imageListRedo` 清空

```js
canvas.addEventListener('mouseup',(e) => {
		isDrawing = false;

		//萬一中間有新增筆畫的話, 需要把 canRedo 回歸為 false 並且 imageListRedo 清空
		if (canRedo) {
			canRedo = false;
			imageListRedo = [];
		}
		addToImageList();
	},
	false
);
```

最後看到本身的邏輯, 一樣使用 `pop` 把 `imageListRedo` 彈出來的最後一筆加入回 `imageListUndo` 的 array 即可完成
```js
document.addEventListener('keydown', function (event) {
	// 當狀態可以 redo 時才能夠觸發
	if (event.ctrlKey && event.key === 'y' && canRedo === true) {
		if (imageListRedo.length > 0) {
			let lastBlob = imageListRedo.pop();
			imageListUndo.push(lastBlob);

			renderImage(lastBlob);
		}
	}
});
```
