---
title: css 峮峮 炸裂陳子豪
date: 2023-09-19 18:43:17
tags:
- css
- js
top: true
---
<img src="https://raw.githubusercontent.com/weber87na/flowers/master/chun.png" width="50%">

<!-- more -->

今天看到 youtube 推薦 `峮峮` 靈感乍現 , 就想說來還原一下很多年前在 yahoo 看到一個 `大元` 車展的 flash 效果
印象中好像是有台相機可以讓你拍照 , 當時看到覺得很酷
可惜手上也沒相機的面板可以模擬 , 就拿手機來充當下

遇到的難點就是不曉得就是怎麼把 video 存成圖 , 以前好像有做過 canvas , 後來 google 下參考這個 [老外](https://codepen.io/GDur/pen/eYBLeLM)
沒想到只要一小段 js 即可

``` js
function capture() {
	let canvas = document.querySelector('#canvas');
	let video = document.querySelector('video');
	canvas.width = video.videoWidth;
	canvas.height = video.videoHeight;
	canvas.getContext('2d')
		.drawImage(video, 0, 0, video.videoWidth, video.videoHeight);
}
```

另外就是沒設定 canvas 的 css 狀況下拍出來整個人會走鐘 , 後來發現 canvas 也是可以用 `object-fit: contain;` 這個屬性 , 就把走鐘問題搞定

然後就是現在的 `video` 這個 tag 要能夠 `autoplay` 的話好像都要設定 `muted` 不然沒辦法自動撥放
```
<video loop
	autoplay
	muted
	width="300"
	height="350">
	<source src="https://github.com/weber87na/video/raw/main/Chun.mp4"
		type="video/mp4" />
</video>
```

<p class="codepen" data-height="700" data-default-tab="result" data-slug-hash="qBLVOMG" data-user="weber87na" style="height: 700px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/qBLVOMG">
  炸裂陳子豪</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>
