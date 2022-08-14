---
title: 利用 fixed 修正 overflow hidden 造成子元素被擋住
date: 2022-03-30 19:10:14
tags: css
---
&nbsp;
<!-- more -->

最近工作上遇到的實際問題 , 平時好像沒被搞過 , 這次屎運解到 , 因為用 3rd 的元件 , 又不想修改 3rd 元件讓東西壞掉或是髒掉 , 所以想想其他方法解看看

因為希望 hover 後的內容可以被顯示在左側 , 平時只要設定 `absolute` 然後寫下定位應該就可以正常在左側
可是當你在 parent 層加上了 `overflow: hidden` 的話 , 子層淺綠色的小方塊 , 超出父層就會被隱藏起來 , 像是下面這樣

![parent-overflow-hidden](https://raw.githubusercontent.com/weber87na/video/main/parent-overflow-hidden.png)

爆炸的 html
```
<div class="parent">
	<div class="child">
	</div>
</div>
```

爆炸的 css
```
.parent {
	position: relative;
	/*因為 3rd 元件的更父層有這個所以爆炸*/
	overflow: hidden;
	background-color: #a0a;
	width: 500px;
	height: 500px;
	margin: 50px auto;
}

.child {
	position: absolute;
	top: 0px;
	left: -50px;
	width: 50px;
	height: 50px;
	background-color: #0fa;
}
```

因為 3rd 元件結構複雜 , 怕去破壞到影響了整體 , 所以需要調整我們自己的 html 結構 , 多增加一個 `fixed` 的區塊放在 `child` 區塊裡面 , 定位的時候一樣由 `child` 區塊進行控制
但是大小由 `fixed` 區塊進行控制 , 最後利用屬性 `position: fixed` 的特性讓 `fixed` 脫離文件流就可以貼在 hover 後的位置並且顯示出來

![child-fixed](https://raw.githubusercontent.com/weber87na/video/main/child-fixed.png)

修正後 html
```
<div class="parent">
	<div class="child">
		<div class="fixed"></div>
	</div>
</div>
```

修正後 css
```
.parent {
	position: relative;
	overflow: hidden;
	background-color: #a0a;
	width: 500px;
	height: 500px;
	margin: 50px auto;
}

.child {
	position: absolute;
	top: 0px;
	left: -50px;
	background-color: #0fa;
}

.fixed{
	position: fixed;
	width: 50px;
	height: 50px;
	background-color: #00f;
	display: none;
}

.parent:hover .fixed{
	display: block !important;
}
```
