---
title: js 俄羅斯方塊
date: 2024-02-29 22:41:10
tags: js
---
&nbsp;
<!-- more -->


<p class="codepen" data-height="630" data-default-tab="result" data-slug-hash="gOEyyrz" data-user="weber87na" style="height: 630px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/gOEyyrz">
  俄羅斯方塊 Tetris</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

剛剛開工偏偏還在過年時段 , 士氣還很低迷 , 就寫寫俄羅斯方塊玩看看 , 本來只是跑龍套 , 沒想到還真搞出來 XD , 順手筆記下怕會忘記
整個開發也是依照以下順序進行實作 , 最難的點應該就是 `消除方塊` `旋轉方塊` `掉落方塊`

### 基本定義
首先定義三種狀態 `Empty` 表示空 , `Fill` 表示目前可移動的方塊佔據的範圍 , `Fixed` 表示固定了的方塊
```
const CellStatus = {
    Empty: 'Empty',
    Fill: 'Fill',
    Fixed: 'Fixed'
}
```

俄羅斯方塊可以變換上下左右旋轉的方向 , 預設都是朝上 `Up` 也就是躺平的狀態
```
const Direction = {
    Up: 'Up',
    Right: 'Right',
    Down: 'Down',
    Left: 'Left',
};
let currentRotation = Direction.Up
```

俄羅斯方塊由長 20 寬 10 的格子組成 , 所以一開始就把他塞成空白 , 這裡直覺用一個 2D Array 來寫比較方便 , 跟以前寫象棋 or 暗棋那種物件式定義座標位置寫法也略有不同
```
function fillBoard() {
    for (let y = 0; y < baseHeight; y++) {
        board.push([])
        for (let x = 0; x < baseWidth; x++) {
            board[y][x] = {
                status: CellStatus.Empty
            }
        }
    }
}
fillBoard()
```

接著要定義各式各樣的方塊一共七總 , 因為我也沒玩過原版的俄羅斯方塊實在不曉得到底是否這樣定義正確 , 整能從其他人的實作來觀察
定義方塊時最好由上至下由左到右定義 , 方便旋轉時好計算
```
const TetrisType = {
    1: 'I',
    2: 'J',
    3: 'L',
    4: 'O',
    5: 'S',
    6: 'T',
    7: 'Z',
}
//目前方塊的類型
let currentTetrisType = 1;

function genNewTetris() {
    let cells = []
    let num = randomNumber(1, 7)
    // let num = randomNumber(2, 3)


    currentRotation = Direction.Up
    //設定目前方塊的類型
    currentTetrisType = num

    //產生新方塊時預設會是躺平
    if (num === 1) {
        //I
        cells.push({ x: 3, y: 0, status: CellStatus.Fill })
        cells.push({ x: 4, y: 0, status: CellStatus.Fill })
        cells.push({ x: 5, y: 0, status: CellStatus.Fill })
        cells.push({ x: 6, y: 0, status: CellStatus.Fill })
    } else if (num === 2) {
        //J
        cells.push({ x: 3, y: 0, status: CellStatus.Fill })
        cells.push({ x: 3, y: 1, status: CellStatus.Fill })
        cells.push({ x: 4, y: 1, status: CellStatus.Fill })
        cells.push({ x: 5, y: 1, status: CellStatus.Fill })
    } else if (num === 3) {
        //L
        cells.push({ x: 5, y: 0, status: CellStatus.Fill })
        cells.push({ x: 3, y: 1, status: CellStatus.Fill })
        cells.push({ x: 4, y: 1, status: CellStatus.Fill })
        cells.push({ x: 5, y: 1, status: CellStatus.Fill })
    } else if (num === 4) {
        //O
        cells.push({ x: 4, y: 0, status: CellStatus.Fill })
        cells.push({ x: 5, y: 0, status: CellStatus.Fill })
        cells.push({ x: 4, y: 1, status: CellStatus.Fill })
        cells.push({ x: 5, y: 1, status: CellStatus.Fill })
    } else if (num === 5) {
        //S
        cells.push({ x: 5, y: 0, status: CellStatus.Fill })
        cells.push({ x: 6, y: 0, status: CellStatus.Fill })
        cells.push({ x: 4, y: 1, status: CellStatus.Fill })
        cells.push({ x: 5, y: 1, status: CellStatus.Fill })
    } else if (num === 6) {
        //T
        cells.push({ x: 4, y: 0, status: CellStatus.Fill })
        cells.push({ x: 3, y: 1, status: CellStatus.Fill })
        cells.push({ x: 4, y: 1, status: CellStatus.Fill })
        cells.push({ x: 5, y: 1, status: CellStatus.Fill })
    } else {
        //Z
        cells.push({ x: 4, y: 0, status: CellStatus.Fill })
        cells.push({ x: 5, y: 0, status: CellStatus.Fill })
        cells.push({ x: 5, y: 1, status: CellStatus.Fill })
        cells.push({ x: 6, y: 1, status: CellStatus.Fill })
    }

    for (let cell of cells) {
        let x = cell.x
        let y = cell.y
        board[y][x] = { status: cell.status }
    }

    return cells
}
current = genNewTetris()
```

### Game Loop 與繪製

繪製就是層層疊上去 , 所以先畫背景 , 接著畫格子即可 , 1000 為 1 秒 , 看你想要多快就除多少 , 這裡還會多個動作就是讓方塊往下掉落
```
function drawBackground() {
    //黑色底色
    ctx.fillStyle = 'black'
    ctx.fillRect(0, 0, width, height)
}

function drawCells() {
    // ctx.strokeStyle = 'white'
    for (let y = 0; y < baseHeight; y += 1) {
        for (let x = 0; x < baseWidth; x += 1) {
            if (board[y][x].status === CellStatus.Fill) {
                ctx.fillStyle = 'blue'
                ctx.fillRect(
                    x * cellSize,
                    y * cellSize,
                    cellSize, cellSize
                )
            }

            if (board[y][x].status === CellStatus.Fixed) {
                ctx.fillStyle = 'gray'
                ctx.fillRect(
                    x * cellSize,
                    y * cellSize,
                    cellSize, cellSize
                )
            }
        }
    }
}

//game loop
setInterval(() => {
    drawBackground()
    down()
    drawCells()
}, 1000 / 5)
```


### 左右移動方塊

移動方塊主要就是怕跑出左右邊界 , 這裡定義防禦函數 , 當超過寬度時則判定不能移動
另外每次移動都是以 `一格` 作為單位 , 所以要判斷目前格子 +1 or -1 是否為 `Fixed`

確定可以移動後要先呼叫清空目前方塊的動作 , 然後迴圈讓目前的方塊 x +1 or -1 塞入 `Fill` 即可
最後要呼叫繪圖函數 `drawBackground` `drawCells` 讓 canvas 馬上更新才不會感覺有 lag
```
function outOfRangeRight(tetris) {
    for (let cell of tetris) {
        let x = cell.x
        if (x >= baseWidth - 1) return true

        if (board[cell.y][x + 1].status === CellStatus.Fixed)
            return true
    }

    return false
}

function outOfRangeLeft(tetris) {
    for (let cell of tetris) {
        let x = cell.x
        if (x <= 0) return true

        if (board[cell.y][x - 1].status === CellStatus.Fixed)
            return true
    }

    return false
}

function right() {
    if (outOfRangeRight(current) === false) {
        //先清空格子
        for (let cell of current) {
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: CellStatus.Empty }
        }
        //然後才塞
        for (let cell of current) {
            cell.x += 1
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: cell.status }
        }

        drawBackground()
        drawCells()
    }
}

function left() {
    if (outOfRangeLeft(current) === false) {
        //先清空格子
        for (let cell of current) {
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: CellStatus.Empty }
        }
        //然後才塞
        for (let cell of current) {
            cell.x -= 1
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: cell.status }
        }
        drawBackground()
        drawCells()
    }
}
```

### 消除方塊
接著就是比較重要的函數清除線 , 他邏輯大概就是由下往上開始掃描整條橫的 , 這裡用 `every` 去判斷是否狀態都是 `Fixed`
如果是的話則取得該 row , 並且設定格子為 `Empty`
然後呼叫 `splice` 取得目前那條 row 然後用 `unshift` 把空白行插在最頂端 , 讓長寬依舊保持 20 x 10
(注意 `splice` 回傳的會是 `Array` 要多加上 `[0]` 所以 code 比較醜)
因為有可能消除很多行 , 最後呼叫自己進入遞迴重複這個消除方塊的動作
```
function clearLine() {
    //從底下往上掃描看哪一行目前非空白
    let lastIndex = undefined
    for (let y = baseHeight - 1; y >= 0; y--) {
        let row = board[y]
        let isFixed = row.every(c => c.status === CellStatus.Fixed)
        if (isFixed) {
            if (y === 0) lastIndex = 0
            else lastIndex = y
            break
        }
    }
    if (lastIndex) {
        let row = board[lastIndex]
        //設定格子被清空
        for (let cell of row) {
            cell.status = CellStatus.Empty
        }

        //取得那一行
        //注意這裡用 splice 回傳的會是 Array 要多加上 [0] 所以 code 比較醜
        let currentRow = board.splice(lastIndex, 1)[0]
        // console.log('currentRow', currentRow)
        // console.log('splice', board)

        //把現在這個改變成 Empty 的 row 插到最前端
        board.unshift(currentRow)
        // console.log('unshift', board)

        //如果有找到的話還需要跑遞迴逐行消除
        clearLine()
    }
}
```


### 往下移動方塊
如同左右移動 , 也要先定義防禦函數 , 防止超出 y 的邊界 , 並看看往下落那格是否為 `Fixed`
當目前方塊沒超越 `y 邊界` 的話 一樣先清空格子 , 然後迴圈跑目前方塊讓 `y 遞增 1` , 並且塞入 `Fill` 狀態
接著不一樣的關鍵則是需要呼叫清除線 `clearLine` 函數來設定是否需要消除方塊

最後因為方塊每隔 N 秒會自動往下移動 , 便會觸發 else 的區塊 , 此時就要讓方塊變成 `Fixed` 固定的狀態 , 固定完後一樣要呼叫 `clearLine` 判定是否需要清除方塊
然後別忘了呼叫 gg 的判定 , 看看是否需要重開新局
```
function outOfRangeY(tetris) {

    for (let cell of tetris) {
        let y = cell.y
        if (y < 0) return true
        if (y >= baseHeight - 1) return true

        //這裡的 1 表示下面那格
        if (board[y + 1][cell.x].status === CellStatus.Fixed)
            return true
    }

    return false
}

function down() {
    if (outOfRangeY(current) === false) {
        //先清空格子
        for (let cell of current) {
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: CellStatus.Empty }
        }
        //然後才塞
        for (let cell of current) {
            cell.y += 1
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: cell.status }
        }

        //清除線
        clearLine()


    } else {

        //固定方塊的動作
        for (let cell of current) {
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: CellStatus.Fixed }
        }

        //清除線
        clearLine()

        //判斷是否已經 gg
        //沒 gg 的話才會產生新的方塊
        if (isGoodGame() === false) {

            //產生新的方塊
            current = genNewTetris()
        }

    }

}
```

### 快速往下掉落
本來我是想寫優一點的解法 , 礙於太晚腦細胞死光 , 就用簡單粗暴的方法達成
這個函數基本上與原先的掉落幾乎相同 , 唯一關鍵就是他改用 while 迴圈來執行來達成目前方塊不斷往下移動的效果 , 其他 code 都一模一樣
```
function spaceDown() {
    while (outOfRangeY(current) === false) {
        //先清空格子
        for (let cell of current) {
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: CellStatus.Empty }
        }
        //然後才塞
        for (let cell of current) {
            cell.y += 1
            let x = cell.x
            let y = cell.y
            board[y][x] = { status: cell.status }
        }

        //清除線
        clearLine()
    }

    //超過範圍了

    //固定方塊的動作
    for (let cell of current) {
        let x = cell.x
        let y = cell.y
        board[y][x] = { status: CellStatus.Fixed }
    }

    //清除線
    clearLine()

    //判斷是否已經 gg
    //沒 gg 的話才會產生新的方塊
    if (isGoodGame() === false) {

        //產生新的方塊
        current = genNewTetris()
    }
}
```



### GG 判定
GG 判定比較簡單 , 只要取得最上面的 row 看看是否有 `Fixed` 即可

```
function isGoodGame() {
    //取得最上面那條的是否固定了
    let result = board[0].some(c => c.status === CellStatus.Fixed)
    return result
}

```

### 旋轉方塊

這裡首先定義一個防止超出 20 x 10 範圍的函數 , 在方塊旋轉時會去呼叫他 , 防止出界
他第一個邏輯就是防止超出邊界 , 第二個則是防止方塊旋轉時的位置為 `Fixed`
```
function rotateTetrisOutOfRange(cells) {
    for (cell of cells) {
        if (cell.y < 0 || cell.x < 0) return true
        if (cell.y > baseHeight - 1 || cell.x > baseWidth - 1) return true

        let x = cell.x
        let y = cell.y
        if (board[y][x].status === CellStatus.Fixed) return true
    }
    return false
}
```

接著就要定義真正用來旋轉的函數 , 這裡以 `L` 這個方塊為例 , 其實說白也沒什麼 
首先先用 `JSON.parse(JSON.stringify(current))` 去複製一個克隆體 , 對著克隆體 `順時針` (也有人逆時針轉) 的把目前方塊的各個小格子 x , y 加減 1 or 2 移動到對的位置即可
然後呼叫剛剛準備好的 `rotateTetrisOutOfRange` 函數判定看看克隆體有無出界去送死 , 沒陣亡的話就讓本體方塊的位置 , 調整成跟克隆方塊一樣的位置
最後記得設定 `currentRotation` 的轉向就大功告成
```
function rotateTetrisL() {
    let cloneCurrent = JSON.parse(JSON.stringify(current))

    let cell1 = cloneCurrent[0]
    let cell2 = cloneCurrent[1]
    let cell3 = cloneCurrent[2]
    let cell4 = cloneCurrent[3]

    clearCurrentBoardPos()

    switch (currentRotation) {
        case Direction.Up:
            cell1.y += 1
            cell2.x += 1
            cell2.y -= 2
            cell3.y -= 1
            cell4.x -= 1

            if (rotateTetrisOutOfRange(cloneCurrent)) return

            mappingCells(cell1, cell2, cell3, cell4)
            currentRotation = Direction.Right
            break;
        case Direction.Right:
            cell1.x -= 2
            cell1.y -= 1
            cell2.x += 1
            cell3.y -= 1
            cell4.x -= 1
            cell4.y -= 2


            if (rotateTetrisOutOfRange(cloneCurrent)) return

            mappingCells(cell1, cell2, cell3, cell4)
            currentRotation = Direction.Down
            break;

        case Direction.Down:
            cell1.x += 1
            cell1.y -= 1
            cell2.y += 2
            cell3.x += 1
            cell3.y += 1
            cell4.x += 2

            if (rotateTetrisOutOfRange(cloneCurrent)) return

            mappingCells(cell1, cell2, cell3, cell4)
            currentRotation = Direction.Left
            break;
        case Direction.Left:
            cell1.x += 1
            cell1.y += 1
            cell2.x -= 2
            cell3.x -= 1
            cell3.y += 1
            cell4.y += 2

            if (rotateTetrisOutOfRange(cloneCurrent)) return

            mappingCells(cell1, cell2, cell3, cell4)
            currentRotation = Direction.Up
            break;
    }

    setCurrentBoardPos()
    drawBackground()
    drawCells()
}
```
