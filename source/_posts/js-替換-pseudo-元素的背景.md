---
title: js-替換-pseudo-元素的背景
date: 2023-06-19 18:40:56
tags:
- css
- js
---
&nbsp;
<!-- more -->

工作上遇到的問題 , 希望讓 table 的 tr hover 的時候顯示出照片 , 我先寫了段 css , 發現沒辦法直接抓到 pseudo 虛擬元素 , 以前好像也遇過類似的 , 不過沒筆記
如果希望讓 `tr:hover::after` 的背景圖變換的話 , 看老外是用 css 變數去變換目前的網址 , 可以看看這個[影片](https://www.youtube.com/watch?v=LszEboGO_zw)
```
var styles = document.createElement("style");
styles.setAttribute("type", "text/css");
styles.textContent = `
tr:hover::after {
    width: 200px;
    height: 200px;
    content: '';
    position: absolute;
	background-color: #4258de29;
    left: 196px;
	background-image: var(--imgUrl);
    background-size: contain;
    background-repeat: no-repeat;
    background-position: center;
	border: 1px solid;
}
`;
document.head.appendChild(styles);
```

接著用 `MutationObserver` 偵測元素變化 , 當發生變化時重新 `addEventListener`
另外一個重點就是這裡是 `HTMLCollection` , 所以要用 `Array.from(mutation.target.rows)` 才可以 `forEach`
這邊有個不錯的 [MutationObserver 解說](https://addyosmani.com/blog/mutation-observers/)
```
var tbody = document.querySelector('tbody');
const observer = new MutationObserver(function (mutations) {
	mutations.forEach(function(mutation){
		Array.from(mutation.target.rows).forEach(function(row){
			row.addEventListener('mouseenter', function() {
				var id = document.querySelectorAll('tr:hover td:nth-child(2)')[0].textContent;
				this.style.setProperty('--imgUrl',  `url('http://yourphoto/${id}.jpg')`);
			});
		});
		
	});
});
observer.observe(tbody, {
	childList: true,
	attributes: true,
	characterData: true,
});
```
