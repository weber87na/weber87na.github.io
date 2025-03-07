---
title: js 抽鬼牌
date: 2024-07-13 01:28:17
tags: js
---

&nbsp;
<!-- more -->

七月要到了, 無聊想說搞個抽鬼牌看看, 果然寫得卡到卡到的 ~
卡到後來 UI 也懶得弄了, 沒想像中那麼容易寫, 順便筆記下

## 發牌
一個花色有 13 張牌, 共 4 個花色 , 外加一張鬼牌, 所以共 53 張


```js
function initCards() {
  //交叉花色發從 1 - 13
  for (let i = 1; i <= 13; i++) {
    for (let j = 0; j < 4; j++) {
      cards.push({
        suit: suits[j],
        num: i,
      });
    }
  }
  cards.push({ suit: 'joker', num: 99 });
}
```

## 取得兩數之間的亂數
老朋友, 怎麼寫怎麼忘, 每次都用 gpt 產生

```js
function getRandomNumber(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}
```

## 洗牌

洗牌就隨便亂數產個兩張卡, 互相交換位置即可, 萬一抽到重覆的直接用遞迴再抽一次
接著用 doShuffle 洗個 100 次

```
function shuffle(cards) {
  let num1 = getRandomNumber(0, 52);
  let num2 = getRandomNumber(0, 52);
  if (num1 === num2) return shuffle(cards);

  let card1 = cards[num1];
  let tmpCard1 = { ...card1 };
  let card2 = cards[num2];
  cards[num1] = card2;
  cards[num2] = tmpCard1;

  return cards;
}


//執行 100 次洗牌
function doShuffle(cards) {
  let result = [];
  for (let i = 0; i < 100; i++) {
    result = shuffle(cards);
  }

  return result;
}
```

## 發牌

發牌只針對一個花色處理, 從一個牌堆不斷 pop 彈出 13 張給該玩家, 如果牌堆只剩一張就把這張給最後一個玩家

```js
function dealingCards(player) {
  for (let i = 0; i < 13; i++) {
    let card = cards.pop();
    player.push(card);
  }
  if (cards.length === 1) {
    let card = cards.pop();
    player.push(card);
  }
}
```

## 找對子
這個函數應該可以拆兩個, 不過偷懶就一個做完
首先用一個 keeper 物件來保存每個數字出現幾次

```json
{
	3: 2
	6: 1
	7: 2
	8: 3
	9: 1
	10: 1
	11: 1
	12: 2
	99: 1
}
```

接著從這裏面撈出 value > 1 的, 即為該 array 內可以組成對子的, 最後回傳

```json
[
	{num: 3, count:2},
	{num: 7, count:2},
	{num: 8, count:3},
	{num: 12, count:2},
]
```

```js
//撈出相同數字的卡片有可能, 同個數字有可能 2 3 4 張
function findCanPair(player) {
  if (player.length === 0) return [];

  let keeper = {};
  for (let card of player) {
    if (!keeper[card.num]) {
      keeper[card.num] = 1;
    } else {
      keeper[card.num] += 1;
    }
  }

  let result = [];
  for (const key in keeper) {
    if (keeper.hasOwnProperty(key)) {
      let value = keeper[key];
      //可能 2 3 4
      if (value > 1)
        result.push({
          num: parseInt(key),
          count: value,
        });
    }
  }

  console.log('keeper', keeper);
  console.log('result', result);

  return result;
}
```

## 取得匹配 2 張或 4 張可以組成對子的卡

這裡可以用 every 來得到該牌堆是否能組成 2 張或 4 張對子的卡
然後呼叫 canPairCards.map 做出類似 sql select num from xxx 的效果
接著用 card2.filter((ele) => !card1.includes(ele)) 把玩家本身的卡與能夠為對子的卡相減
類似 sql 的 minus or except 最後回傳相減的集合

```js
function dropEven(player) {
  if (player.length === 0) return [];

  let canPairCards = findCanPair(player);
  //判斷是否直接把牌丟掉
  let dropAll = canPairCards.every((x) => x.count === 2 || x.count === 4);
  if (dropAll) {
    //用 map 達成 sql select 效果取得 num
    let card1 = canPairCards.map((x) => x.num);
    //玩家的卡
    let card2 = player.map((x) => x.num);

    //array 相減取得結果, 必須要是玩家減去可以丟的
    let subCards = card2.filter((ele) => !card1.includes(ele));
    // console.log('card2 - card1 = ', subCards);

    //取得結果
    let result = player.filter((ele) => subCards.includes(ele.num));
    // console.log('the result', result);

    return result;
  }

  return [];
}
```

## 找出一個數字出現 3 次的卡

這裡用 some 判斷是否有出現一次以上 3 張卡數字相同的
如果有的話, 先用 filter 做成一個只留數字的 array
接著跑兩層迴圈把有符合連續三個數字的 前兩張卡 丟棄, 只留下一張
這裡需要用 splice 來移除, 並且要呼叫 i-- 來減少索引, 不然索引會錯誤

```js
function dropAny3NumToNormal(player) {
  if (player.length === 0) return [];

  let canPairCards = findCanPair(player);
  let any3Counts = canPairCards.some((x) => x.count === 3);
  if (any3Counts) {
    let specialNums = canPairCards
      .filter((ele) => ele.count === 3)
      .map((x) => x.num);
    console.log('specialNums', specialNums);

    let clonePlayer = [...player];
    for (let num of specialNums) {
      let counter = 0;
      for (let i = 0; i < clonePlayer.length; i++) {
        if (counter === 2) break;

        if (clonePlayer[i].num === num) {
          //刪除符合的前兩個數字, 調整 array
          clonePlayer.splice(i, 1);
          i--;
          counter++;
        }
      }
    }

    return clonePlayer;
  }

  return [];
}
```

### 丟棄對子

丟棄對子有三種情況

首先可能很賽都沒對子, 直接 return 本來的牌堆

第二種則是拿到可以組成對子的卡剛好都是 2 or 4, 只要呼叫 dropEven 就搞定了

最後一種則是有拿到 3 張相同數字的, 所以先呼叫 dropAny3NumToNormal 把牌丟成正常狀況
接著再呼叫 dropEven 讓剩餘的卡有組成 2 or 4 對子的丟掉即可

```js
function dropPlayerPairs(player) {
  if (player.length === 0) return [];

  // console.log('orig cards', player)

  let canPairCards = findCanPair(player);

  //萬一很賽都沒拿到對子
  if (canPairCards.length === 0) return player;

  //刪除數字可以組成正常對子的
  let result = dropEven(player);
  if (result.length > 0) return result;

  //刪除數字組成對子但是有三張相同數字的
  let normalize = dropAny3NumToNormal(player);
  result = dropEven(normalize);
  return result;
}
```

## 抽卡

抽卡則是由 A 抽 B
所以亂數取得卡片位置, 接著把 B 的 array 減小
最後把抽到的卡 push 進去 A

```js
function drawCard(players, numA, numB) {
  let playerA = players[numA];
  let playerB = players[numB];

  let num = getRandomNumber(0, playerB.length - 1);
  let theCard = playerB[num];

  for (let i = playerB.length - 1; i >= 0; i--) {
    if (JSON.stringify(playerB[i]) === JSON.stringify(theCard)) {
      playerB.splice(i, 1);
    }
  }

  playerA.push(theCard);

  return players;
}

```

## 是否只剩下鬼牌

這個比較簡單, 因為丟對子函數會幫我們把其他非鬼牌都處理掉
所以只要判斷卡堆是否只剩下一張卡, 並且其他幾個卡堆都沒卡即可

```js
function isOnlyJoker() {
  if (
    players[0].length === 1 &&
    players[1].length === 0 &&
    players[2].length === 0 &&
    players[3].length === 0
  )
    return true;

  if (
    players[0].length === 0 &&
    players[1].length === 1 &&
    players[2].length === 0 &&
    players[3].length === 0
  )
    return true;

  if (
    players[0].length === 0 &&
    players[1].length === 0 &&
    players[2].length === 1 &&
    players[3].length === 0
  )
    return true;

  if (
    players[0].length === 0 &&
    players[1].length === 0 &&
    players[2].length === 0 &&
    players[3].length === 1
  )
    return true;

  return false;
}
```

## 取得真正執行抽卡或被抽卡的人

這個函數比較燒腦點

正常情況下, 抽排會由 0 ~ 3 這樣的順序執行, 因為這個函數同時負責取得目前玩家, 還有下個玩家
所以使用上有可能會傳入 turn + 1 造成超越 array 範圍的狀況, 所以先放個防禦式
當超過範圍時, 先把 turn 設定為 0, 才進入下個步驟

由於牌有可能被抽完, 這時候則需要把 turn + 1 讓下個人抽, 由於下個人也可能卡已經抽完, 所以將此動作寫為遞迴

最後則是正常情況, 直接返回 turn 即可

```js
function realTurn(turn) {
  if (turn > 3) turn = 0;

  if (players[turn].length === 0) {
    turn++;
    return realTurn(turn);
  }

  return turn;
}
```

## 判斷是否 gg

這個函數將先前的函數組合起來, 先用 realTurn 取得真正要執行抽卡的人, 接著用 realTurn(turn + 1) 取得下家
分別將索引放入 drawCard 來修改這兩者的 array
接續使用 dropPlayerPairs 判斷抽卡結束是否可以組成對子
最後看看是否只剩下鬼牌, 是的話回傳 -1
反之則回傳下個回合輪到誰

```js
function isGG(turn, players) {
  turn = realTurn(turn);
  console.log('current turn', turn);

  let nextTurn = realTurn(turn + 1);
  console.log('nextTurn', nextTurn);

  players = drawCard(players, turn, nextTurn);
  let player = dropPlayerPairs(players[turn]);
  players[turn] = player;

  if (isOnlyJoker()) return -1;

  return nextTurn;
}
```

## 自動執行

這裡只需要跑個迴圈, 如果回傳 -1 表示 gg

```
function run() {
  let counter = 1;
  while (true) {
    console.log(`第: ${counter} 次`);
    turn = isGG(turn, players);
    if (turn === -1) {
      alert('G___G +');
      break;
    }

    counter++;
  }
}
```

## 卡片 css content 特殊用法

雖然還沒寫 UI, 不過想到一個用法可以玩看看

```html
<div class="card" suit="♠️" num="10">
	<div class="card-img"></div>
</div>
```

因為撲克牌的花色通常都在數字上面, 所以可以用 `content` 把字放上去, 此外可以用 `\A` 來換行
還可以用 `attr` 這個屬性把自訂的 suit num 串接起來 `content: attr(num) '\A'attr(suit)`
最後可以拿到 `content: '10\A♠️'` 這樣的等價效果

```css
.card {
	width: 150px;
	height: 200px;
	border-radius: 3px;
	display: flex;
	border: solid 1px #ccc;
	position: absolute;
	bottom: 0;
	left: 0;
}
.card-img {
	margin: auto;
	height: 140px;
	width: 100px;
	background-image: url('https://raw.githubusercontent.com/weber87na/flowers/master/chun.png');
	background-position: center/center;
	background-repeat: no-repeat;
	background-size: cover;
	border: 1px solid #dedede;
}

.card::before,
.card::after {
	font-family: '微軟正黑體';
	text-align: center;
	font-size: 16px;
	height: 40px;
	width: 30px;
	position: absolute;
	/* content: '10\A♠️'; */
	content: attr(num) '\A'attr(suit);
}
.card::before {
	top: 2px;
	left: 2px;
}
.card::after {
	transform: rotate(180deg);
	bottom: 2px;
	right: 2px;
}
```

## fullcode

<p class="codepen" data-height="300" data-default-tab="result" data-slug-hash="GRbrjMb" data-pen-title="Joker" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/GRbrjMb">
  Joker</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>
