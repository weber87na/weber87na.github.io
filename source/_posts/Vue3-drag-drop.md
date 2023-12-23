---
title: Vue3 drag drop
date: 2023-07-10 18:55:44
tags:
- vue3
- css
- js
---
![電龜](https://raw.githubusercontent.com/weber87na/flowers/master/電龜2.png)
<!-- more -->

同事遇到的問題 , 剛好有空閒就順手研究看看 , 結果就生出這個小遊戲!
印象中以前 jquery 時代也做過類似的需求 , 需要 `drag` `drop` , 第一次寫 vue3 , 感覺前端變化真快 , 以前學 vue2 才用過一個小案子
然後就沒再碰過了 , 要怎麼寫也忘光光 XD
我看網路上有兩種寫法一種長得跟 vue2 類似 , 還有一種用啥 `ref` 缺點是每次拿值都要加上 `value` , 本來是想直接上 ts , 不過考量到自己是新手的關係就先放棄 ~
主要的原理是看[這篇](https://learnvue.co/articles/vue-drag-and-drop) 還有[這個](https://www.w3schools.com/html/html5_draganddrop.asp) , 只要在需要被 `drag` `drop` 的 `tag` 上標記 `draggable`
然後搭配他的相關事件 `ondragstart` `ondrop` 即可 , 關鍵如下

同事因為要做類似每個小時可以安排任務 , 所以 array 有個 `seq` 屬性 , 所以核心寫在 `onDrop` 這個函數裡面
一開始取得 `drag` 的的元素 , 比較雷的應該這句 , 他得到 `id` 時會給 `string` , 要自己轉換
```
    const dragId = parseInt(event.dataTransfer.getData('id'))
```

接著找到 `drag` `drop` 的索引位置 , 然後用一個 `tmp` 變數保存元素 , 並且也要把 `seq` 屬性保存並且交換 , 不然只會更新 arrray 內的位置
不過我這個遊戲應該是不用去交換 seq 這個動作 , 純粹為了 demo 給同事
```
const dragSeq = dragTurtle.seq
const dropSeq = dropTurtle.seq
const tmp = turtles.value[dragTurtleIndex]
turtles.value[dragTurtleIndex] = turtles.value[dropTurtleIndex]
turtles.value[dragTurtleIndex].seq = dragSeq
turtles.value[dropTurtleIndex] = tmp
turtles.value[dropTurtleIndex].seq = dropSeq
```

最後就是[洗牌功能](https://stackoverflow.com/questions/49555273/how-to-shuffle-an-array-of-objects-in-javascript)

```
turtlesQuestion.value = turtlesQuestion.value.sort(() => Math.random() - 0.5)
```

還有比對 `array` 功能 , 因為我會動到 `seq` , 所以應該只要比較兩者的 `id` 順序是否相同即可
然後可以用 `JSON.stringify` 去比較兩者
```
let ids = turtles.value.map(x => x.id)
let questionIds = turtlesQuestion.value.map(x => x.id)
let win = JSON.stringify(ids) === JSON.stringify(questionIds)
```

最後送上 example , 螢幕太小的話建議直接上 codepen 看 , 或是用 0.5 倍率

<p class="codepen" data-height="561" data-slug-hash="LYXOyab" data-user="weber87na" style="height: 561px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/LYXOyab">
  龜小Game</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>
