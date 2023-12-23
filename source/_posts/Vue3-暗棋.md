---
title: Vue3 暗棋
date: 2023-07-31 19:19:55
tags:
- js
- vue3
---
![電龜](https://raw.githubusercontent.com/weber87na/flowers/master/電龜3.png)
<!-- more -->
自己 coding 也有些年了 , 記得非常遠古以前學 java 的時候 , 曾經問要怎麼做出象棋 or 暗棋 , 不過對方卻回說非常困難 , 你還是放棄吧 ~ 直接勸退的概念
這次剛好弄到 vue drag & drop 就順便開開腦洞來寫看看 , 此外我還有搞個 [angular 版本](https://stackblitz.com/edit/dark-chess?file=src%2Fmain.ts)

<p class="codepen" data-height="300" data-default-tab="result" data-slug-hash="ExOoYMx" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/ExOoYMx">
  龜小暗棋</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

## 資料結構
### 棋子
首先棋子的部分主要有以下幾個屬性
`id` => 區分每個子的唯一識別編號
`name` => 顯示該棋子是 `兵` `炮` 或其他兵種使用
`suit` => 紅色或黑色
`lv` => 棋子的等級 , 由此判斷他能吃什麼子 , 或他的移動行為
`isDie` => 判定這個子是否被打掛了 , 這個後來沒用到 , 不然應該要做個陣亡區之類的
`isOpen` => 判斷是否已經翻開
`x` => 目前的 x 座標
`y` => 目前的 y 座標
```
{ id: 1, name: '兵', suit: 'red', lv: 1, isDie: false, isOpen: false, x: 0, y: 0 },
```
接著把所有棋子都定義好 , 然後塞到一個 cheesPool 的 array 裡面即可

### 棋盤
棋盤其實就是由一堆格子構成 , 它的結構比較簡單
`id` => 區分每格的唯一識別編號
`x` => 該格的 x 座標
`y` => 該格的 y 座標
`chees` => 這格上面的棋子
```
{ id: 1, x: 0, y: 0, chees: undefined }
```
如同棋子一樣 , 先定義 `cells` 這個 array 然後把格子塞進去就變成棋盤了
最後用 `shuffle` 方法把棋子設定擺滿整個棋盤 , 並且洗亂順序
``` js
function shuffle() {
    cheesPool.value = cheesPool.value.sort(() => Math.random() - 0.5)

    for (let i = 0; i < cells.value.length; i++) {
        let cell = cells.value[i]
        let chees = cheesPool.value[i]
        chees.isOpen = false
        chees.isDie = false
        chees.x = cell.x
        chees.y = cell.y
        cell.chees = chees
    }
}
```

## UI 設計
### html
首先 drag & drop 主要原理可以看[這篇](https://learnvue.co/articles/vue-drag-and-drop)

接著關鍵如下所述

先用 `v-for` 對整個棋盤進行 `loop` 每個格子 `cell`
`@drop` 需要設定 `onDrop` 讓棋子可以被拖拉到格子上
`@dragover` & `@dragover` 都要設定 `prevent`

然後在格子內塞個 div  `v-if` 去判斷這格是否有棋子 , 如果有的話則顯示該子 , 並讓他的事件 & 樣式可以觸發
首先看 `:data-xy` 這個會把該子的座標利用 `attr` 傳進去給 `css` 裡面方便 `debug`
`@click` 的 `onCheesClick` 方法則負責翻子的動作
`:class` 內設定這個棋子是否被翻開及套用它的花色
`:draggable` 需要該子已經翻開後 , 才可以觸發 `drag` 的事件
`@dragstart` 裡面放 `onDrag` 這個事件
最後 `div` 內的文字則依照該子是否翻開才進行顯示

`status-panel` 的部分則 show 出現在是誰的回合

``` html
    <div id="app" class="wrap">
          <div class="board">
        <div class="cell"
            v-for="cell in cells"
            @drop="onDrop($event, cell)"
            @dragover.prevent
            @dragenter.prevent>
            <div v-if="cell.chees">
                <div class="chees"
                    :data-xy="`x:${cell.chees.x},y:${cell.chees.y}`"
                    @click="onCheesClick($event, cell.chees)"
                    :class="[{ 'chees-open': cell.chees.isOpen }, cell.chees.suit]"
                    :draggable="cell.chees.isOpen"
                    @dragstart="onDrag($event, cell)">
                    {{ cell.chees.isOpen ? cell.chees.name : '' }}
                </div>
            </div>
        </div>
    </div>

    <div class="status-panel">
        <button id="go"
            @click="shuffle()">GO</button>
        <h3>
            誰的回合: <span :class="currentPlayer">{{ currentPlayer }}</span>
        </h3>
    </div>
```

### css
核心關鍵如下
首先先用 flex 繪製一個居中的區塊 , 接著裡面擺上 grid 當作棋盤即可
我的想法是棋盤是方格子 , 所以用 grid 應該比較可以快速建構布局 , 自己對 grid 也比較陌生就玩看看
真的不行還有[這個工具](https://cssgrid-generator.netlify.app/) 可以輔助產生 grid
棋盤一共 32 格所以可以定義如下
``` css
.board {
    /*
    因為 gap 是內部畫線
    8 - 1 = 7
    4 - 1 = 3
    */
    width: 647px;
    height: 323px;
    display: grid;

    grid-template-columns: repeat(8, 1fr);
    grid-template-rows: repeat(4, 1fr);
    grid-column-gap: 1px;
    grid-row-gap: 1px;
    background-color: red;

}
```

棋子被翻開要設定 `chees-open` 讓他的色彩為白色 , 反之綠色則為蓋起來的時候
``` css
.chees-open {
    background-color: #fff;
}
```

接著利用偽元素的 `after` 設定 `content: attr(data-xy)` 讓棋子有 xy 座標方便 debug
``` css
.chees::after {
    color: black;
    font-family: '微軟正黑體';
    font-size: 8px;
    content: attr(data-xy);
    line-height: 20px;
    height: 20px;
    width: 60px;
    position: absolute;
    bottom: 0;
    right: 0;
}
```

最後則是花色部分記得要設定 `red` & `black` 這樣棋子翻開後上面的字就會是該顏色
``` css
.red {
    color: red;
}

.black {
    color: #000;
}
```


## 核心邏輯說明
### 切換玩家
先定義現在是誰的回合 , 接著定義 `togglePlayer` 即可
``` js
const currentPlayer = ref('black')

function togglePlayer() {
    if (currentPlayer.value === 'black') currentPlayer.value = 'red'
    else currentPlayer.value = 'black'
}
```

### 翻開棋子
如果該子尚未翻開設定他翻開 , 並且切換回合
``` js
function onCheesClick(event, chees) {
    console.log(event)
    console.log(chees)
    if (chees.isOpen === false) {
        chees.isOpen = true

        togglePlayer()
    }

}
```

### 移動到空白格
如果移動過去則回傳 true 反之 false , 如果該格上面沒子的話才會觸發 , 設定座標 & 棋子到這格上面
``` js
function moveToEmptyCell(dragCell, dropCell) {
    let isMove = false
    const dragChees = dragCell.chees

    //如果沒有棋子在上面的話則移動過去
    if (dropCell.chees === undefined) {
        //清空原來位置上的棋子
        console.log(dragCell)
        dragCell.chees = undefined

        //設定棋子位置
        dragChees.x = dropCell.x
        dragChees.y = dropCell.y
        dropCell.chees = dragChees

        isMove = true
    }

    return isMove
}
```


### 判斷該子是否陣亡
當吃子的動作觸發時便會呼叫這個函數
比較特別的是炮正常狀況不能吃子 , 需要跳躍後才能
小兵可以打掉將 , 將沒辦法打小兵
其他則比較等級大小即可
``` js
function checkIsDie(dragCell, dropCell) {

    //正常狀況炮是沒辦法攻擊所以 return false
    if (dragCell.chees.lv === 2) {
        return false
    }

    //小兵可以打掉將
    if (dragCell.chees.lv === 1 && dropCell.chees.lv === 7) {
        return true
    }

    //將不能打小兵
    if (dragCell.chees.lv === 7 && dropCell.chees.lv === 1) {
        return false
    }

    //正常情況
    if (dragCell.chees.lv >= dropCell.chees.lv) {
        return true
    }

    return false
}
```

### 攻擊棋子及移動的動作
要滿足以下條件才會執行
首先該格要有棋子
該子已經是翻開的狀態
drag & drop 花色要相異
另外攻擊棋子也隱含著移動的動作 , 所以當把棋子打掛之後 , 要移動過去
倘若該格沒子則是正常移動過去 , 所以把 `moveToEmptyCell` 寫在最後面
``` js
function attackChees(dragCell, dropCell) {
    //吃子的動作
    if (dropCell.chees !== undefined) {
        //棋子有被翻開才能攻擊
        //花色不同才能攻擊
        //棋子等級大於對方才能攻擊
        if (dragCell.chees.isOpen === true && dropCell.chees.isOpen === true) {
            if (dragCell.chees.suit !== dropCell.chees.suit) {
                if (checkIsDie(dragCell, dropCell)) {
                    dropCell.chees.isDie = true
                    dropCell.chees = undefined
                }
            }
        }
    }

    let isMove = moveToEmptyCell(dragCell, dropCell)
    return isMove
}
```

### 判斷棋子能否移動到該格
這裡設定正常可以移動的狀況 `isIllegalMove` 做為一個收攏函數
如果是非法移動則回傳 `true` 正常移動回傳 `false`
`isDistanceOutofRange` 用來判斷是否移動超過一格以上或是有人白目原地移動
另外白目的人也會斜著移動 , 很邪惡 XD
`isMoveTopLeft` 是否向左上移動
`isMoveTopRight` 是否向右上移動
`isMoveBottomRight` 是否向右下移動
`isMoveBottomLeft` 是否向左下移動
``` js
function isIllegalMove(dragCell, dropCell) {
    // if (dragCell.chees.lv === 2 && dragCell.y === dropCell.y) return false

    if (isDistanceOutofRange(dragCell, dropCell)) return true
    if (isMoveTopLeft(dragCell, dropCell)) return true
    if (isMoveTopRight(dragCell, dropCell)) return true
    if (isMoveBottomRight(dragCell, dropCell)) return true
    if (isMoveBottomLeft(dragCell, dropCell)) return true

    return false
}

function isDistanceOutofRange(dragCell, dropCell) {
    let distanceX = Math.abs(dragCell.x - dropCell.x)
    let distanceY = Math.abs(dragCell.y - dropCell.y)
    //超過範圍
    if (distanceX > 1 || distanceY > 1) return true

    //白目原地移動
    if (distanceX === 0 && distanceY === 0) return true

    return false
}

function isMoveTopLeft(dragCell, dropCell) {
    let moveX = dragCell.x - 1
    let moveY = dragCell.y - 1
    if (dropCell.x === moveX &&
        dropCell.y === moveY) {
        return true
    }

    return false
}

function isMoveTopRight(dragCell, dropCell) {
    let moveX = dragCell.x + 1
    let moveY = dragCell.y - 1
    if (dropCell.x === moveX &&
        dropCell.y === moveY) {
        return true
    }

    return false
}

function isMoveBottomRight(dragCell, dropCell) {
    let moveX = dragCell.x + 1
    let moveY = dragCell.y + 1
    if (dropCell.x === moveX &&
        dropCell.y === moveY) {
        return true
    }

    return false
}

function isMoveBottomLeft(dragCell, dropCell) {
    let moveX = dragCell.x - 1
    let moveY = dragCell.y + 1
    if (dropCell.x === moveX &&
        dropCell.y === moveY) {
        return true
    }

    return false
}
```

### 計算炮的移動中間有幾個子
當炮要移動或是吃子時有飛這個動作 , 簡單的說就是中間要相隔一顆子 , 這裡統計往上下左右移動時有幾顆子
這裡關鍵就是 `i` 由 `1` 開始 , 且 `小於 distance` 然後利用 `find` 函數去找到該格上的棋子進行統計
我本來是想用遞迴寫這個邏輯 , 不過後來想想只要計算兩個子之間有幾顆子即可 , 所以看到 `findLeftCell findRightCell findTopCell findBottomCell` 這幾個函數都不用理他們
不然應該也可以先用遞迴去找第一顆當砲台的子後 , 然後找第二顆子確認是攻擊目標
``` js
function calcLeftAtkRangeCount(dragCell, dropCell) {
    let distanceX = Math.abs(dragCell.x - dropCell.x)
    let result = 0
    for (let i = 1; i < distanceX; i++) {
        let isFind = cells.value.find(cell => cell.x == dragCell.x - i && cell.y == dragCell.y)
        if (isFind.chees) {
            result++
        }
    }
    return result
}

function calcTopAtkRangeCount(dragCell, dropCell) {
    let distanceY = Math.abs(dragCell.y - dropCell.y)
    let result = 0
    for (let i = 1; i < distanceY; i++) {
        let isFind = cells.value.find(cell => cell.y == dragCell.y - i && cell.x == dragCell.x)
        if (isFind.chees) {
            result++
        }
    }
    return result
}

function calcRightAtkRangeCount(dragCell, dropCell) {
    let distanceX = Math.abs(dragCell.x - dropCell.x)
    let result = 0
    for (let i = 1; i < distanceX; i++) {
        let isFind = cells.value.find(cell => cell.x == dragCell.x + i && cell.y == dragCell.y)
        if (isFind.chees) {
            result++
        }
    }
    return result
}


function calcBottomAtkRangeCount(dragCell, dropCell) {
    let distanceY = Math.abs(dragCell.y - dropCell.y)
    let result = 0
    for (let i = 1; i < distanceY; i++) {
        let isFind = cells.value.find(cell => cell.y == dragCell.y + i && cell.x == dragCell.x)
        if (isFind.chees) {
            result++
        }
    }
    return result
}
```

### Drag 棋子
先看看該格子上是否有棋子 , 有的話設定 `dataTransfer` 讓 `Drop` 時可以接收
``` js
function onDrag(event, cell) {
    let chees = cell.chees
    if (chees === undefined) return
    // if(chees.isOpen === false) return

    console.log('drag', event)
    console.log('drag', chees)
    console.log('drag', cell)

    event.dataTransfer.dropEffect = 'move'
    event.dataTransfer.effectAllowed = 'move'
    event.dataTransfer.setData('cheesId', chees.id)
    event.dataTransfer.setData('cellId', cell.id)
}
```


### Drop 棋子
這裡應該要重構下炮的移動不過太晚沒啥精力了
主要分為兩個狀況 , 如果是炮的話則使用 `if (dragCell.chees.lv === 2 && dropCell.chees?.suit != dragCell.chees?.suit)` 內的條件式 , 反之就是其他子

先講正常狀況 , 在正常狀況先判斷是否為非法移動 `if (isIllegalMove(dragCell, dropCell)) return`
接著判斷該格子是否為空 , 若為空直接呼叫 `moveToEmptyCell` 移動到該格
反之則呼叫 `attackChees`
最後如果有移動的話則切換回合

接著講炮的邏輯他有可能是橫向移動 `if (dragCell.y === dropCell.y && Math.abs(dragCell.x - dropCell.x) > 1)`
或是垂直移動 `else if (dragCell.x === dropCell.x && Math.abs(dragCell.y - dropCell.y) > 1)`
以橫向移動為例 , 首先判斷是往左打還是往右打 , 接著呼叫 `calcXXXAtkRangeCount` 系列函數得知有幾個子
如果中間是一個子的話則表示可以攻擊
``` js
if (dragCell.y === dropCell.y && Math.abs(dragCell.x - dropCell.x) > 1) {
	if (dropCell.chees === undefined) return
	//往左打
	if (dragCell.x > dropCell.x) {
		//先計算到攻擊位置之間共有幾個棋子
		let inAtkRangeCount = calcLeftAtkRangeCount(dragCell, dropCell)
		console.log('inAtkRangeCount', inAtkRangeCount)
		if (inAtkRangeCount === 1) {
			// let leftCell = cells.value.find(cell => cell.x == dragCell.x - 1 && cell.y == dragCell.y)
			//let leftCell = findLeftCell(dragCell, dropCell, 1)
			// console.log('leftCell', leftCell)
			//如果左邊這格有找到棋子表示可以攻擊不管有沒有翻開
			if (dropCell?.chees) {
				//接著再往左邊找如果是自己人或是還沒翻開的話就不能攻擊
				console.log('find')
				if (dropCell?.chees?.isOpen) {
					dropCell.isDie = true
					dropCell.chees = undefined
					moveToEmptyCell(dragCell, dropCell)
					togglePlayer()
					return
				}
			}
		}
	}

	//往右打
	if (dragCell.x < dropCell.x) {
		if (dropCell.chees === undefined) return
		//先計算到攻擊位置之間共有幾個棋子
		let inAtkRangeCount = calcRightAtkRangeCount(dragCell, dropCell)
		console.log('inAtkRangeCount', inAtkRangeCount)
		if (inAtkRangeCount === 1) {
			//let rightCell = findRightCell(dragCell, dropCell, 1)
			//如果左邊這格有找到棋子表示可以攻擊不管有沒有翻開
			if (dropCell?.chees) {
				//接著再往左邊找如果是自己人或是還沒翻開的話就不能攻擊
				console.log('find')
				if (dropCell?.chees?.isOpen) {
					dropCell.isDie = true
					dropCell.chees = undefined
					moveToEmptyCell(dragCell, dropCell)
					togglePlayer()
					return
				}
			}
		}
	}
} 
```

完整的 `onDrop`
``` js
function onDrop(event, dropCell) {
    console.log('drop', event)
    console.log('drop', dropCell)

    // const dragCheesId = parseInt(event.dataTransfer.getData('cheesId'))
    // const dragChees = cheesPool.value.find(x => x.id == dragCheesId)

    const dragCellId = parseInt(event.dataTransfer.getData('cellId'))
    const dragCell = cells.value.find(x => x.id == dragCellId)
    if (dragCell?.chees?.suit !== currentPlayer.value) return

    //判斷是否可以走
    if (dragCell.chees.lv === 2 && dropCell.chees?.suit != dragCell.chees?.suit) {

        //如果 y 相同的話才能攻擊橫向單位
        if (dragCell.y === dropCell.y && Math.abs(dragCell.x - dropCell.x) > 1) {
            if (dropCell.chees === undefined) return
            //往左打
            if (dragCell.x > dropCell.x) {
                //先計算到攻擊位置之間共有幾個棋子
                let inAtkRangeCount = calcLeftAtkRangeCount(dragCell, dropCell)
                console.log('inAtkRangeCount', inAtkRangeCount)
                if (inAtkRangeCount === 1) {
                    // let leftCell = cells.value.find(cell => cell.x == dragCell.x - 1 && cell.y == dragCell.y)
                    //let leftCell = findLeftCell(dragCell, dropCell, 1)
                    // console.log('leftCell', leftCell)
                    //如果左邊這格有找到棋子表示可以攻擊不管有沒有翻開
                    if (dropCell?.chees) {
                        //接著再往左邊找如果是自己人或是還沒翻開的話就不能攻擊
                        console.log('find')
                        if (dropCell?.chees?.isOpen) {
                            dropCell.isDie = true
                            dropCell.chees = undefined
                            moveToEmptyCell(dragCell, dropCell)
                            togglePlayer()
                            return
                        }
                    }
                }
            }

            //往右打
            if (dragCell.x < dropCell.x) {
                if (dropCell.chees === undefined) return
                //先計算到攻擊位置之間共有幾個棋子
                let inAtkRangeCount = calcRightAtkRangeCount(dragCell, dropCell)
                console.log('inAtkRangeCount', inAtkRangeCount)
                if (inAtkRangeCount === 1) {
                    //let rightCell = findRightCell(dragCell, dropCell, 1)
                    //如果左邊這格有找到棋子表示可以攻擊不管有沒有翻開
                    if (dropCell?.chees) {
                        //接著再往左邊找如果是自己人或是還沒翻開的話就不能攻擊
                        console.log('find')
                        if (dropCell?.chees?.isOpen) {
                            dropCell.isDie = true
                            dropCell.chees = undefined
                            moveToEmptyCell(dragCell, dropCell)
                            togglePlayer()
                            return
                        }
                    }
                }
            }
        } else if (dragCell.x === dropCell.x && Math.abs(dragCell.y - dropCell.y) > 1){
            if (dropCell.chees === undefined) return
            //往上打
            if (dragCell.y > dropCell.y) {
                //先計算到攻擊位置之間共有幾個棋子
                let inAtkRangeCount = calcTopAtkRangeCount(dragCell, dropCell)
                console.log('inAtkRangeCount', inAtkRangeCount)
                if (inAtkRangeCount === 1) {
                    // let leftCell = cells.value.find(cell => cell.x == dragCell.x - 1 && cell.y == dragCell.y)
                    //let topCell = findTopCell(dragCell, dropCell, 1)
                    // console.log('topCell', topCell)
                    //如果左邊這格有找到棋子表示可以攻擊不管有沒有翻開
                    if (dropCell?.chees) {
                        //接著再往左邊找如果是自己人或是還沒翻開的話就不能攻擊
                        console.log('find')
                        if (dropCell?.chees?.isOpen) {
                            dropCell.isDie = true
                            dropCell.chees = undefined
                            moveToEmptyCell(dragCell, dropCell)
                            togglePlayer()
                            return
                        }
                    }
                }
            }

            //往下打
            if (dragCell.y < dropCell.y) {
                if (dropCell.chees === undefined) return
                //先計算到攻擊位置之間共有幾個棋子
                let inAtkRangeCount = calcBottomAtkRangeCount(dragCell, dropCell)
                console.log('inAtkRangeCount', inAtkRangeCount)
                if (inAtkRangeCount === 1) {
                    //let bottomCell = findBottomCell(dragCell, dropCell, 1)
                    //如果左邊這格有找到棋子表示可以攻擊不管有沒有翻開
                    if (dropCell?.chees) {
                        //接著再往左邊找如果是自己人或是還沒翻開的話就不能攻擊
                        console.log('find')
                        if (dropCell?.chees?.isOpen) {
                            dropCell.isDie = true
                            dropCell.chees = undefined
                            moveToEmptyCell(dragCell, dropCell)
                            togglePlayer()
                            return
                        }
                    }
                }
            }

        }
        else {
            if (isIllegalMove(dragCell, dropCell)) return
        }


    } else {
        //炮以外的棋子正常走
        if (isIllegalMove(dragCell, dropCell)) return
    }




    //移動到空的格子
    //或是吃子
    let isMove = false
    if (dropCell.chees === undefined) {
        isMove = moveToEmptyCell(dragCell, dropCell)
    } else {
        isMove = attackChees(dragCell, dropCell)
    }

    if (isMove) togglePlayer()
}
```
