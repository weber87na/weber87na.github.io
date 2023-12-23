---
title: css flex筆記
date: 2022-10-02 02:08:57
tags: css
---
&nbsp;
<!-- more -->

上課順手筆記下常用到的 flex , 以免又忘了

### 置中
首先先設定 `body` 為 `flex` , 並且設定高度為螢幕高度 , 因為 `flex` 會影響子層 , 所以設定 `container` 的 `margin` 為 `auto` 即可將 `container` 置中

<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="MWGGJVd" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/MWGGJVd">
  flex-center1</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

### 置中2
這種方法比較常見 , 一樣設定 `body` 為 `flex` , 並且加上 `align-items: center` 及 `justify-content: center` 這樣即可讓子層置中

<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="jOxxyKX" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/jOxxyKX">
  flex-center2</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>


### 三欄等寬 glow
有時候懶得計算寬度有多寬 , 所以可以直接用這招讓物件等寬 , 只要設定 `flex-glow` 就能輕鬆搞定

<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="GRddrPQ" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/GRddrPQ">
  flex-glow-col-same-width</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

### 三欄左右等寬 glow
這個主要利用 `flex-glow` 特性 , 先在左右設定寬度為 `200px` , 中間則分配剩餘空間 , 所以設定 `flex-grow: 1;`

<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="dyeeNgv" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/dyeeNgv">
  flex-grow-3col</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

### 三欄左右等寬 shrink
在中間元素以 `shrink` 特性設定為 `1` (shrink 預設值為 1) , 並且 `width` 設定為 `100%` 即可 , 另外左右設定想要的寬度 , 並且設定 `shrink` 為 `0` , 如果沒設定的話依然會收縮

<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="NWMMdme" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/NWMMdme">
  flex-shrink-3col</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

### 仿 FB 照片排列 
練習 flex 過程中剛好看到 FB 照片排法 , 左邊一大塊 , 右邊分成三小塊 , 右邊可以靠 `flex-direction: column` 去搞定 , 另外三小塊設定 flex-glow 即可輕鬆分成三份 , 仔細想想 flex 用太大也不太好 , 這裡因為小塊是直排所以靠 block 加上計算尺寸應該也可以搞定 , 這裡就懶得計算靠著 flex-glow 寫起來好像更簡單

<p class="codepen" data-height="300" data-default-tab="result" data-slug-hash="ExLRxWz" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/ExLRxWz">
  Untitled</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>
