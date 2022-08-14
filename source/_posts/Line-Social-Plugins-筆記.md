---
title: Line Social Plugins 筆記
date: 2022-02-23 18:29:08
tags: line
---

&nbsp;
<!-- more -->

這個好像很久以前賣謎片的朋友要跟風 line 分享 , 所以無聊研究看看怎麼用 `LINE Social Plugins` 順便在自己的 blog 加看看

主要可以看[官方說明](https://developers.line.biz/en/docs/line-social-plugins/install-guide/using-line-share-buttons/) 弄個謎片還要懂英文真是辛苦

### 分享給朋友
主要把 `data-url` 設定上去就搞定了 , 就看要填入啥內容
```
<div class="line-it-button"
	data-lang="zh_Hant"
	data-type="share-b"
	data-env="REAL"
	data-url=""
	data-color="default"
	data-size="small"
	data-count="true"
	data-ver="3"
	style="display: none;"></div>

<script src="https://www.line-website.com/social-plugins/js/thirdparty/loader.min.js"
	async="async"
	defer="defer"></script>
```


不過通常會希望直接分享這頁 , 以前好像都用 jquery , 現在也忘光怎麼拿 data attribute 啦
```
<script>
	var btn = document.querySelector('.line-it-button');
	btn.dataset.url = document.URL;
</script>
```

如果想要客製化的話只要這樣加就可以啦
```
<a href="https://social-plugins.line.me/lineit/share?url=https%3A%2F%2Fline.me%2Fen">Hello World</a>
```

### 加朋友
加朋友也滿簡單的 , 主要靠 `data-lineId` , 沒想到經營謎片之類的也是滿辛苦的 , 還要搞這些

```
<div class="line-it-button"
	data-lang="en"
	data-type="friend"
	data-env="REAL"
	data-count="true"
	data-home="true"
	data-lineId="@FQ謎片"
	style="display: none;"></div>
```

### 點讚
點讚也是差不多的動作 , 想不到還滿無腦的
```
<div class="line-it-button"
	data-lang="zh_Hant"
	data-type="like"
	data-env="REAL"
	data-url="很讚的謎片網址"
	style="display: none;"></div>
```


### fullcode

`fullcode`
```
<!DOCTYPE html>
<html lang="en">

<head>
</head>

<body>
    <p>Hello World</p>

    <div class="line-it-button"
        data-lang="zh_Hant"
        data-type="share-b"
        data-env="REAL"
        data-url=""
        data-color="default"
        data-size="small"
        data-count="true"
        data-ver="3"
        style="display: none;"></div>

    <a href="https://social-plugins.line.me/lineit/share?url=https%3A%2F%2Fline.me%2Fen">Hello World</a>

    <div class="line-it-button"
        data-lang="en"
        data-type="friend"
        data-env="REAL"
        data-count="true"
        data-home="true"
        data-lineId="@fq87"
        style="display: none;"></div>

	<div class="line-it-button"
		data-lang="zh_Hant"
		data-type="like"
		data-env="REAL"
		data-url="很讚的謎片網址"
		style="display: none;"></div>


    <script src="https://www.line-website.com/social-plugins/js/thirdparty/loader.min.js"
        async="async"
        defer="defer"></script>

	<script>
		var btn = document.querySelector('.line-it-button');
		btn.dataset.url = document.URL;
	</script>


</body>

</html>
```
