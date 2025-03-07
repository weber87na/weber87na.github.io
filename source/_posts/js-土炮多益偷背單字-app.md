---
title: js 土炮多益偷背單字 app
date: 2024-06-27 23:34:59
tags: js
---

![img](https://raw.githubusercontent.com/weber87na/ToeiCli/main/%E5%81%B7%E5%BF%B5.gif)
<!-- more -->

因為不小心下載到多益背單字的 App, 就順便玩看看, 結果點沒兩個單字就跳廣告, 不然就是要買單字, 什麼都要收摳摳 $___$
於是乎自己土炮用 js 寫看看, 還可以放在 terminal 當成障眼法 XD

核心大概就只有幾行, 首先以 `randomBetween` 取得(含) `min max` 之間的亂數
接著用 `genRand` 裝飾下 `randomBetween` 取得亂數
最後以 `genQuestion` 來產生每次要丟出來的題目與答案
這裡會用到 `splice` 他會從索引處拿 N 個出來, 他會減少本來 array 內的元素, 接著再從這四個詞裡面設定答案
都搞定後就是看 UI 是用啥做, 然後使用 閃開 展開運算子 XD, 每次都寫錯, 把整個題庫的 json 複製一份就好

他的 [repo 在此](https://github.com/weber87na/ToeiCli)

```js
let dict = [...db];
next(dict);

function randomBetween(min, max) {
  let result = Math.floor(Math.random() * (max - min + 1) + min);
  return result;
}

function genRand(dict, num = 4) {
  if (dict.length < num) return 0;
  if (dict.length > 0) return randomBetween(0, dict.length - num);
  return 0;
}

function genQuestion(dict, num = 4) {
  console.log('current dict', dict);
  if (!dict) return [];
  if (dict.length < 4) return [];

  let index = genRand(dict);
  let result = dict.splice(index, num);

  let ansIndex = randomBetween(0, result.length - 1);
  console.log('res', result);
  console.log('ansIndex', ansIndex);
  result[ansIndex].ans = true;
  return result;
}
```

<p class="codepen" data-height="713" data-default-tab="result" data-slug-hash="JjqVLoB" data-pen-title="多益練習" data-user="weber87na" style="height: 713px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/JjqVLoB">
  多益練習</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>
