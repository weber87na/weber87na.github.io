---
title: css 可樂瓶效果
date: 2022-12-09 01:22:18
tags: css
---
![cola](https://raw.githubusercontent.com/weber87na/flowers/master/cola-turtle-example.png)
<!-- more -->

以前很菜的時候就看過 [可樂瓶效果](http://www.romancortes.com/blog/pure-css-coke-can) 當時不懂得原理
今天無意中發現這個[大陸人](https://blog.csdn.net/weixin_44990584/article/details/108826223) 網站也有類似的 code 就抓來玩看看
他 code 長這樣 , 很機車要登入後複製 , 懶得登入就用以下方法 , 先複製他 `code` 這個 block
接著用 chrome edit as html 加上 id
```
<code id="test" class="prism language-css has-numbering" onclick="mdcp.signin(event)" style="position: unset;"><span class="token selector">*</span><span class="token punctuation">{<!-- --></span>
    <span class="token property">margin</span><span class="token punctuation">:</span> 0<span class="token punctuation">;</span>
    <span class="token property">padding</span><span class="token punctuation">:</span> 0<span class="token punctuation">;</span>
<span class="token punctuation">}</span>
<span class="token selector">body</span><span class="token punctuation">{<!-- --></span>
    <span class="token property">height</span><span class="token punctuation">:</span> 100vh<span class="token punctuation">;</span>
    <span class="token property">display</span><span class="token punctuation">:</span> flex<span class="token punctuation">;</span>
    <span class="token property">justify-content</span><span class="token punctuation">:</span> center<span class="token punctuation">;</span>
    <span class="token property">align-items</span><span class="token punctuation">:</span> center<span class="token punctuation">;</span>
<span class="token punctuation">}</span>
<span class="token selector">.cola</span><span class="token punctuation">{<!-- --></span>
    <span class="token property">background-image</span><span class="token punctuation">:</span><span class="token url">url("bizhi.png")</span><span class="token punctuation">;</span>
    <span class="token property">background-repeat</span><span class="token punctuation">:</span> repeat-x<span class="token punctuation">;</span>
    <span class="token property">background-position</span><span class="token punctuation">:</span> 205px 10px<span class="token punctuation">;</span>
    <span class="token property">animation</span><span class="token punctuation">:</span> colaAnimation 5s infinite<span class="token punctuation">;</span>
    <span class="token property">-webkit-animation</span><span class="token punctuation">:</span> colaAnimation 5s linear infinite<span class="token punctuation">;</span><span class="token punctuation">;</span>
<span class="token punctuation">}</span>

<span class="token atrule"><span class="token rule">@keyframes</span> colaAnimation</span> <span class="token punctuation">{<!-- --></span>
    <span class="token selector">from</span><span class="token punctuation">{<!-- --></span>
        <span class="token property">background-position</span><span class="token punctuation">:</span> 205px 10px<span class="token punctuation">;</span>
    <span class="token punctuation">}</span>
    <span class="token selector">to</span><span class="token punctuation">{<!-- --></span>
        <span class="token property">background-position</span><span class="token punctuation">:</span> -332px 10px<span class="token punctuation">;</span>
    <span class="token punctuation">}</span>
<span class="token punctuation">}</span>
<div class="hljs-button signin" data-title="登录后复制" data-report-click="{&quot;spm&quot;:&quot;1001.2101.3001.4334&quot;}"></div></code>
```

最後這樣下 , 就可以把幹走 code 了
```
var test = document.querySelector('#test')
test.innerText
```

分析一下他的 html 結構 , `body.png` 寬高 `194 x 336`
```
<div class="cola">
	<img src="./body.png" alt="">
</div>
```

他這張 `body.png` 是很有玄機的 , 這個作者把瓶子挖空變成透明的 , 外圍則是白底背景
所以當利用 `cola` 搭配 `img` 的話就可以把可樂包裝圖片塞在中間 , 最後利用 `background-position` 進行位移就可以達成他這個效果
如果腦子不轉下還真想不出來是怎麼寫的 , 非常絕妙!


<p class="codepen" data-height="429" data-default-tab="html,result" data-slug-hash="oNyVbKL" data-user="weber87na" style="height: 429px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/oNyVbKL">
  Cola-turtle</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>
