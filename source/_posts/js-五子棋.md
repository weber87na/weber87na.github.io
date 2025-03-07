---
title: js 五子棋
date: 2024-07-20 01:13:10
tags: js
---

<p class="codepen" data-height="600" data-default-tab="result" data-slug-hash="poXyvwx" data-pen-title="Gomoku" data-user="weber87na" style="height: 600px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/poXyvwx">
  Gomoku</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>

<!-- more -->


## 五子棋
印象中很多年前學程式的時候, 有買過一本書 `silverlight` 他有個範例就是五子棋, 那時也看不懂到底怎麼做的
他還有個教學影片, 不過聽起來滿痛苦的, 看完還是不曉得在做啥, 直接登出 ~
今天就來用 js 挑戰看看, 好像應該要用 `silverlight` 挑戰看看才對 XD

首先是建立 2d array, 然後用雙重迴圈把格子塞滿, 只要棋類好像都這樣
這次相對單純, 沒太多的狀態判斷, 所以就只塞 string 在格子裡

```js
function fillCells(cells, len) {
    for (let i = 0; i < len; i++) cells.push([]);

    for (let y = 0; y < len; y++) {
        for (let x = 0; x < len; x++) {
            cells[y][x] = ' ';
        }
    }
}
```

接著撰寫一個落子的函數, 因為 2d array 座標通常都是 cells[y][x] 有點反直覺, 所以包裝下讓他變成呼叫函數用 x, y 去寫入格子

```js
function go(x, y, suit) {
    cells[y][x] = suit;
}
```


接著當確定棋子座標以後, 就需要計算出勝負, 共有四種方位要判斷, `水平` `垂直` `左下右上斜線(slash /)` `左上右下 (backslash \)`
以 `水平` 為例, 當棋子落在 `x4, y0` 的情況下, 總共有以下 5 種排列的搭配

* `*` 表示可能形成線的位置
* `O` 表示棋子

```js
|   | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 |
|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:-:|:--:|:--:|:--:|:--:|:--:|
| 0 |   |   |   |   | O | * | * | * | * |   |    |    |    |    |    |
| 1 |   |   |   | * | O | * | * | * |   |   |    |    |    |    |    |
| 2 |   |   | * | * | O | * | * |   |   |   |    |    |    |    |    |
| 3 |   | * | * | * | O | * |   |   |   |   |    |    |    |    |    |
| 4 | * | * | * | * | O |   |   |   |   |   |    |    |    |    |    |
| 5 |   |   |   |   |   |   |   |   |   |   |    |    |    |    |    |
| 6 |   |   |   |   |   |   |   |   |   |   |    |    |    |    |    |
| 7 |   |   |   |   |   |   |   |   |   |   |    |    |    |    |    |
| 8 |   |   |   |   |   |   |   |   |   |   |    |    |    |    |    |
```


我的思考方式是將這 `5 種` 可能的 `水平線`, 都收集起來, 總共要跑五次迴圈
並且又有個內層迴圈滑動 `min` 與 `max` 變數 (術語應該是 sliding window 的一種技巧)
因為是水平移動所以這樣撰寫即可 `cells[y][x + begin]`, 其他幾種方向則與一反三便可知道答案
此外當滑出棋盤範圍時, 仍然把條線段空的 array push 進去, 確保始終 return 五條線段

```js
//蒐集水平線 回傳五個結果
function horizontalLines(x, y) {
    //滑動範圍
    let max = 4;
    let min = 0;
    let result = [];
    for (let i = 1; i <= 5; i++) {
        let line = [];
        for (let begin = min; begin <= max; begin++) {
            if (x + begin >= len || x + begin < 0) break;

            //萬一為 0 的話 x 可以不用 + begin
            let cell = cells[y][x + begin];
            line.push(cell);
        }
        result.push(line);

        //滑動範圍
        max = max - 1;
        min = min - 1;
    }
    //回傳五個結果
    return result;
}
```

當蒐集完線段 array 以後, 便要判斷這個方向的線段是否能獲勝
這裡將 `O` 當作黑色, `X` 當作白色, 因為獲勝需要 `OOOOO` 這樣的 string, 所以用 `repeat` 來製作
將線段跑個 loop, 然後利用 `join` 函數把 array 內的內容串在一起, 最後與該花色的線段比對就可以拿到答案

```js
function isWin(lines, suit = 'O') {
    let suitLine = suit.repeat(5);
    for (let line of lines) {
        let strLine = line.join('');

        if (suitLine === strLine) return true;
    }

    return false;
}
```

最後用 `isGG` 把四個方向組合起來就可以得知是否連成一線

```js
//組合四個方向取得遊戲是否結束
function isGG(x, y, suit = 'O') {
    let horizontal = horizontalLines(x, y);
    if (isWin(horizontal, suit)) return true;

    let vertical = verticalLines(x, y);
    if (isWin(vertical, suit)) return true;

    let slash = slashLines(x, y);
    if (isWin(slash, suit)) return true;

    let backSlash = backSlashLines(x, y);
    if (isWin(backSlash, suit)) return true;

    return false;
}
```

UI 則沒啥特別的部分, 在腦波一弱的狀況下, 不小心就直接寫 html
這種 dom 元素太多的手寫還是太累, 不過頭洗下去了就做到底
這裡可以用 vscode emmet 技巧, 比較特別的是 emmet 用 `$` 產生數字會從 `1` 開始, 要設定為 `0` 開始的話需要用 `$@0`
不然 15 * 15 還真的是寫到登出 ~

```
.cell*15[data-y=0][data-x=$@0]>.chess
```

## 四子棋

後來又順便搞個四子棋, 還是第一次看到這東東
他最核心的 code 就是他的 Y 是看現在疊了幾顆子在 Y 那條上面決定的, 所以要給 X 然後計算出真正的 Y
算法就是讓 result 起始為 -1 , 萬一遇到空格則 `+1` , 反之直接 return

```js
//計算真正的 Y
function getY(x) {
	let line = []
	for (let i = 0; i < size; i++) {
		let cell = cells[i][x]
		line.push(cell)
	}
	let result = -1
	for (let cell of line) {
		if (cell === ' ') {
			result++
		} else {
			return result
		}
	}
	return result
}
```

取得 dom 上面因為使用撈 xy 的方式, 一次需要使用兩個自訂屬性 querySelector 可以這樣寫

```js
let realDomCell = document.querySelector(`[data-x="${x}"][data-y="${y}"]`)
```

另外這把想說做完整點, 順便加了獲勝 `alert` 然後重新開始的功能, 結果沒想到 `alert` 的優先權高於設定背景, 所以要用 `setTimeout` 來避免
js 真是莫名其妙 XD

```js
let gg = isGG(x, y, turn)
if (gg) {
//因為 alert thread 的關係會先執行
setTimeout(function () {
    if (turn === 'X') alert('G__G 白方獲勝 ~~')
    else alert('G__G 黑方獲勝 ~~')
    startGame()
}, 0)
} else {
//切換回合
turn = toggleSuit(turn)
}
```

<p class="codepen" data-height="625" data-default-tab="result" data-slug-hash="zYVqJWV" data-pen-title="Connect4" data-user="weber87na" style="height: 625px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/zYVqJWV">
  Connect4</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>
