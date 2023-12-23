---
title: js 在點選按鈕後暫時 disable
date: 2023-07-03 19:00:44
tags: js
---
&nbsp;
<!-- more -->

我在舊版 angularjs 被 user 鍵盤卡住搞到的問題 , 所以研究下怎麼在按下去以後弄個 disable 倒數計時

html
```
<div class="m-1">
	<button type="button"
			ng-click="copy(event)"
			class="btn btn-danger">
		<i class="fas fa-copy"></i> copy
	</button>
</div>
```

js 如下
比較雷的是 `innerHTML` 是大寫 , 這個被雷了老半天
```
var confirmMsg = 'are you sure?'
var button = event.button
if (confirm(confirmMsg)) {
	button.disabled = true;
	var count = 6;
	var countDownTimer = setInterval(function() {
		count--;
		button.innerHTML = '<i class="fas fa-copy"></i> disable... ' + count + '';
		//如果倒計時結束
		if (count == 0) {
			clearInterval(countDownTimer);
			//啟用按鈕
			button.disabled = false;
			button.innerHTML = originalInnerHTML;
		}
	}, 1000);
}
```
