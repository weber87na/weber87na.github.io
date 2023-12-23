---
title: css has selector 點香效果
date: 2022-11-30 19:02:14
tags: css
---
&nbsp;
![點香](https://raw.githubusercontent.com/weber87na/flowers/master/incense-and-turtle.png)
<!-- more -->
因為在 codepen 上看到老外的這個 [煙霧效果](https://codepen.io/wikyware-net/pen/GRrNMbw) 覺得很酷 , 就幹來變成夢寐以求的點香效果 , 順便練練手 XD

點香原理就是利用 `checkbox` 先放在開頭 , 看是要設定位置為負的還是隱藏皆可 , 反正就是撒旦常說的障眼法 , 接著讓 `~` 去選到後面的元素 , 利用 `label` 的 `for` 屬性去控制 `checkbox` 被點到即可搞定
<p class="codepen" data-height="700" data-slug-hash="LYrJxNp" data-user="weber87na" style="height: 700px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/LYrJxNp">
  incense-and-turtle</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

此外剛好看到 css has selector , 所以順手玩看看 , 比較有趣的是以前用這種寫法的話 `checkbox` 通常都要放在 html 的開頭才有辦法用 `~` 去吃到後面的元素
有了 has selector 以後就可以不用一定要放在開頭 , html 結構上來說相對彈性
```
	body:has(input:checked) .ag-sherlock_smoke,
	body:has(input:checked) .incense::before{
		display: block;
	}
```
