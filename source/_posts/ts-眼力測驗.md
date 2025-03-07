---
title: ts 眼力測驗
date: 2024-08-29 01:33:32
tags: ts
---

<p class="codepen" data-height="680" data-default-tab="result" data-slug-hash="Yzojwee" data-pen-title="顏色測驗" data-user="weber87na" style="height: 680px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/Yzojwee">
  顏色測驗</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>
<!-- more -->

今天朋友傳個眼力測驗, 心血來潮就來模擬看看大概怎麼寫, 這次直接在 codepen 用 ts 來寫看看

遇到第一個特別的點就是 2d array 的宣告, 在 js 只要宣告 [] 即可, but ts 就麻煩些, 要寫成 let arr: number[][] = [];
接著把 2d array 塞滿, 這裡先在外層迴圈設定 arr[y] = [] 表示塞入 [[]] , 讓他變成 2d
接著把每個格子寫 0 即可

```ts
let arr: number[][] = [];

function fillArr(arr: number[][]) {
  for (let y = 0; y < size; y++) {
    arr[y] = [];
    for (let x = 0; x < size; x++) {
      arr[y][x] = 0;
    }
  }

  return arr;
}
```

再來則是取得兩數之間的數, 不過這次看到一個很炫炮的寫法
如果 +1 就可以取得 1 - 16 (size * size) 中的亂數

```ts
function genNum() {
  return ((Math.random() * (size * size)) | 0) + 1;
}
```

接著是亂數取得一格要設定為異色的格子, 這裡練下遞迴
首先看到 inner function 這裡面為遞迴主要邏輯
先將 y 設定為 -1, 每次執行則往前推進, 最後會得到正確的 Y (高度)值
x 則是小於等於 size 則回傳, 否則遞迴每次減去 size, 最後就可以得到答案

```ts
function genPos() {
  let y = -1;
  let n = genNum();
  console.log("n:", n);
  let x = pos(n) - 1;

  let reuslt = { x: x, y: y };
  console.log("pos:", reuslt);
  return reuslt;

  function pos(num: number) {
    y++;
    if (num <= size) return num;
    else {
      return pos(num - size);
    }
  }
}
```

再來比較特別的是如何取得 canvas 與 2d array 的相對位置轉換
首先取得目前 canvas 的滑鼠位置

```ts
function getMousePosition(event: MouseEvent) {
  const rect = canvas.getBoundingClientRect();
  const x = event.clientX - rect.left;
  const y = event.clientY - rect.top;
  return { x, y };
}
```

接著在點選格子的時候利用 Math.floor(y / cellH) 這樣就可以計算出轉換結果

```ts
const { x, y } = getMousePosition(event);
const theY = Math.floor(y / cellH);
const theX = Math.floor(x / cellW);
```

最後就是將 hex 轉為 rgb 然後把需要設為異色的做顏色加減, 便可完成

```ts
function hexToRgb(hex: string) {
  const canvas = document.createElement("canvas");
  const ctx = canvas.getContext("2d");
  canvas.width = 1;
  canvas.height = 1;

  ctx!.fillStyle = hex;
  ctx!.fillRect(0, 0, 1, 1);

  const data = ctx!.getImageData(0, 0, 1, 1).data;
  const r = data[0];
  const g = data[1];
  const b = data[2];

  const increase = 10 - level * 2;
  let newR = r + increase;
  if (newR >= 255) newR = 255;

  let newG = g + increase;
  if (newG >= 255) newG = 255;

  let newB = b + increase;
  if (newB >= 255) newB = 255;

  // return `rgb(${r + increase}, ${g + increase}, ${b + increase})`;
  return `rgb(${newR}, ${newG}, ${newB})`;
}
```

後來覺得 html 147 色實在太噁心了, 玩不到兩關就 gg, 所以選些比較中間的, 又額外做了這個, 然後挑出比較中間的顏色

<p class="codepen" data-height="300" data-default-tab="result" data-slug-hash="oNrMdgz" data-pen-title="Html147色" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/oNrMdgz">
  Html147色</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>
