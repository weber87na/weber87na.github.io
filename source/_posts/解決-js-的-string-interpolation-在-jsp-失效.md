---
title: 解決 js 的 string interpolation 在 jsp 失效
date: 2023-09-05 19:31:56
tags: js
---
&nbsp;
<!-- more -->

今天同事問我個 js 的問題 , 他們 team 都用 jsp
公司現在都用 chrome , 所以可以用比較新的 js 語法去寫 , 不用受到 ie 折磨
可是當他用 `string interpolation` 時卻顯示 null
後來發現是因為他們 team 都把 script 掛在 jsp 上面跑 , 其實這樣還是後端 render , 並非真前端
真前端需要把 script 都單獨抽離到 js 檔內 , 這樣才玩真的 , 所以造成 `string interpolation` 失效

google 看看發現老外有[解答](https://medium.com/@daveford/template-literals-not-working-f5f0c7553f8b) , 不過也沒寫原理
反正只要加上反斜線 `\${xxx}` 即可
後來問看看 `gpt` 老半天才給出點不曉得對錯的答案 , 因為我也沒在寫 jsp - . - 沒法正確判斷


我 Q:
為什麼我在 jsp 用 javascript 的 string interpolation 會失效
```
<script>
	var a = "test2"
	var b = `aaa${a}bbb`
	console.log(b)
</script>
```

為什麼加了 `\` 就生效
```
<script>
	var a = "test2"
	var b = `aaa\${a}bbb`
	console.log(b)
</script>
```

GPT A (我翻成繁體大致意思 , 不然原文都很支語):
在 JSP 中，`<% %>` 或 `${ }` 等 JSP 標籤也可以看作特殊字元，它們可能和 JavaScript 中的特殊字元相互衝突，導致字串插值失效。
而在 JavaScript 中，`${ }` 是一種新的字串模板語法，可以完成字串的插值，JSP 不支援語法，因此會導致字串插值失效。
在 JSP 中需要插入 JavaScript 中的 `${ }` 時，需要在 `$` 前面加上反斜杠 `\`，這樣就可以轉為普通字元，解決此問題。
