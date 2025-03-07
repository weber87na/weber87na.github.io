---
title: js 踩地雷
date: 2024-07-18 01:08:51
tags: js
---

<p class="codepen" data-height="500" data-default-tab="result" data-slug-hash="yLdeYKj" data-pen-title="Minesweeper" data-user="weber87na" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/yLdeYKj">
  Minesweeper</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>

<!-- more -->

最近又沒啥手感, 哪天有手感的 XD 發燒龜家裡就寫個踩地雷看看
踩地雷最簡單就是 9 * 9 的格子, 推理起來應該是用以下 json 來存放即可
應該也可以加上旗子屬性, 我自己則是分開放

`isHidden` => 格子翻開了沒
`isBoom` => 是否為地雷
`hint` => 周圍有幾顆地雷的提示數字
`pos` => 可以當作編號來看從 1 - 81 , 方便拿格子用
`x` => x 座標
`y` => y 座標

```json
{
	isHidden: true,
	isBoom: false,
	hint: 3,
	pos: 10,
	x: 0,
	y: 5,
}
```

## 初始格子及地雷設定

初始空格子 `initCells` 這個函數比較簡單
先用一個迴圈塞入高度的空白 array , 做成一個 2d array

接著用兩個迴圈去塞 2d array 裡面一開始提到的 json 結構, 就完成所有格子初始化

```js
//初始空格子
function initCells(cells, len) {
    //產生 2d 格子
    for (let i = 0; i < len; i++) cells.push([])

    //初始化格子內容
    let counter = 1;
    for (let y = 0; y < len; y++) {
        for (let x = 0; x < len; x++) {
            let cell = {
                isHidden: true,
                isBoom: false,
                hint: 0,
                pos: counter,
                x: x,
                y: y,
            }
            cells[y][x] = cell
            counter++
        }
    }
    return cells
}
```

接著撰寫地雷系列的函數, 先用個寫到爛掉的 1 到 N 之間的 `getRandomNumber` 函數

```js
//產生亂數
function getRandomNumber(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
```

用迴圈跑 `10 次` 搭配 `getRandomNumber` 函數來產生 1 - 81 之間的亂數, 總共產 10 個地雷
為了防止重複的數字產生, 當發現 `booms` 這個 array 內已經有該數的話, 則重新產生一次亂數

```js
//亂數產生炸彈
function genRandomBooms() {
    //塞進 10 顆炸彈
    for (let i = 0; i < 10; i++) {
        let num = getRandomNumber(1, 81)

        //如果 array 已經有炸彈則重新產生, 防止重複
        do {
            if (booms.includes(num) === false) {
                booms.push(num)
                break
            } else {
                num = getRandomNumber(1, 81)
            }
        } while (true)
    }
}
```

最後設定格子上面的地雷, 這裡用一個有趣的函數 `flat` 來把 2d array 轉為 1d array
接著用 `filter` 搭配 `includes` 來達成類似 sql 的 where in 效果, 把這些格子的 `isBoom` 設定為 `true` 即可

```js
//設定格子上面的炸彈
function plantBooms() {
    let flatCells = cells.flat()
    let boomCells = flatCells.filter(c => booms.includes(c.pos))
    for (let cell of boomCells) cell.isBoom = true

}
```

## 提示周圍地雷數量
這系列函數說白就是把目前格子的 `上` `下` `左` `右` `左上` `右上` `右下` `左下` 為地雷的找出來
如果有找到地雷的話分數則給 `1`, 反之為 `0` , 將這八個數值加總就可以算出來

這裡一樣呼叫 `flat` 函數讓 2d array 躺平, 接著使用 `{ ...cell }` 展開運算子複製格子物件
最後針對 `x` `y` 座標進行加減即可

因為是電腦座標, 這裡的 `y` 上下很容易會搞反, 需要小心
```js
//上
function hintUp(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}
//下
function hintBottom(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}
//左
function hintLeft(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.x = condition.x - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}
//右
function hintRight(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.x = condition.x + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}
//左上
function hintTopLeft(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y - 1
    condition.x = condition.x - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}
//右上
function hintTopRight(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y - 1
    condition.x = condition.x + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}
//左下
function hintBottomLeft(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y + 1
    condition.x = condition.x - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}
//右下
function hintBottomRight(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y + 1
    condition.x = condition.x + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.isBoom) return 1
    return 0
}

//設定提示有幾個炸彈
function numOfBooms() {
    for (let y = 0; y < cells.length; y++) {
        for (let x = 0; x < cells.length; x++) {
            let cell = cells[y][x]
            if (cell.isBoom === false) {
                let hint = 0
                hint += hintUp(cell)
                hint += hintBottom(cell)
                hint += hintLeft(cell)
                hint += hintRight(cell)
                hint += hintTopLeft(cell)
                hint += hintTopRight(cell)
                hint += hintBottomLeft(cell)
                hint += hintBottomRight(cell)
                cell.hint = hint
            }
        }
    }
}
```

## 找空地
觀察踩地雷的話會發現, 當我們點選到空地時, 他會把周圍八格都給打開
如果旁邊 `上` `下` `左` `右` 也是空地的話, 則會把相鄰的周圍也打開

這邊大概需要定義兩個系列的函數, 這裡先列出只找空地的
他的條件是要 `有該格物件` `提示炸彈數量等於零` 且 `格子尚未打開`
即為 `findCell && findCell.hint === 0 && findCell.isHidden`

```js
//上
function scanZeroUp(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint === 0 && findCell.isHidden) return findCell

}
//下
function scanZeroBottom(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint === 0 && findCell.isHidden) return findCell

}
//左
function scanZeroLeft(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.x = condition.x - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint === 0 && findCell.isHidden) return findCell

}
//右
function scanZeroRight(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.x = condition.x + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint === 0 && findCell.isHidden) return findCell

}

//找空白的格子
function scanZero(cell) {
    let result = []
    let cellUp = scanZeroUp(cell)
    if (cellUp) result.push(cellUp)

    let cellBottom = scanZeroBottom(cell)
    if (cellBottom) result.push(cellBottom)

    let cellLeft = scanZeroLeft(cell)
    if (cellLeft) result.push(cellLeft)

    let cellRight = scanZeroRight(cell)
    if (cellRight) result.push(cellRight)

    return result
}
```

## 找空地周圍
呈上的找空地, 這裡要找空地周圍, 因為是周圍, 所以要包含 `左上` `右上` `右下` `左下`
他的條件是要 `有該格物件` `提示炸彈數量大於零` 且 `格子尚未打開` 即為 `findCell && findCell.hint > 0 && findCell.isHidden`
另外這裡因為要配合 UI 的點選動作, 所以還要把自己這格也算進去, 不然點下去的時候會缺少自己

```js
//找空白的格子周圍 上
function scanZeroAroundUp(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}

//找空白的格子周圍  下
function scanZeroAroundBottom(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}

//找空白的格子周圍 左
function scanZeroAroundLeft(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.x = condition.x - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}

//找空白的格子周圍 右
function scanZeroAroundRight(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.x = condition.x + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}
//找空白的格子周圍 左上
function scanZeroAroundTopLeft(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y - 1
    condition.x = condition.x - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}
//找空白的格子周圍 右上
function scanZeroAroundTopRight(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y - 1
    condition.x = condition.x + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}
//找空白的格子周圍 左下
function scanZeroAroundBottomLeft(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y + 1
    condition.x = condition.x - 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}
//找空白的格子周圍 右下
function scanZeroAroundBottomRight(cell) {
    let flatCells = cells.flat()
    let condition = { ...cell }
    condition.y = condition.y + 1
    condition.x = condition.x + 1
    let findCell = flatCells.find(c => c.x === condition.x && c.y === condition.y)
    if (findCell && findCell.hint > 0 && findCell.isHidden) return findCell

}

//找空白的格子周圍 四面八方(包含自己)
function scanZeroAround(cell) {
    let result = []
    let cellUp = scanZeroAroundUp(cell)
    if (cellUp) result.push(cellUp)

    let cellBottom = scanZeroAroundBottom(cell)
    if (cellBottom) result.push(cellBottom)

    let cellLeft = scanZeroAroundLeft(cell)
    if (cellLeft) result.push(cellLeft)

    let cellRight = scanZeroAroundRight(cell)
    if (cellRight) result.push(cellRight)

    let cellTopLeft = scanZeroAroundTopLeft(cell)
    if (cellTopLeft) result.push(cellTopLeft)

    let cellTopRight = scanZeroAroundTopRight(cell)
    if (cellTopRight) result.push(cellTopRight)

    let cellBottomLeft = scanZeroAroundBottomLeft(cell)
    if (cellBottomLeft) result.push(cellBottomLeft)

    let cellBottomRight = scanZeroAroundBottomRight(cell)
    if (cellBottomRight) result.push(cellBottomRight)

    //這句是關鍵需要包含自己
    result.push(cell)

    return result
}
```

## 初始化 dom
因為我們的格子都是用動態去產生的, 所以將 2d array 先轉為 1d (躺平啦)
然後跑個迴圈把所有格子的自訂屬性都給串上去, 最後用 `insertAdjacentHTML` 塞到 `game` 這個 div 裡面即可
也可以把其他 `isBoom` 屬性設定上去, 不過考慮到設定這樣可以作弊的原因, 就不放了 XD

```js
//初始化 dom
function initDom() {
    let game = document.querySelector('.game')
    let flatCells = cells.flat()
    for (let cell of flatCells) {
        let template =
            `<div class="cell" data-pos="${cell.pos}" data-x="${cell.x}" data-y="${cell.y}"></div>`
        game.insertAdjacentHTML('beforeend', template)
    }
}
```

## 插旗幟及是否贏了系列函數
初始化旗幟比較簡單, 只要塞入 10 個旗幟, 並且加上座標, 還有是否使用即可

```js
//初始化旗幟
function initFlags() {
    for (let i = 0; i < 10; i++) {
        flags.push({ isUse: false, pos: -1, x: -1, y: -1 })
    }
}
```

判斷勝負則是先從所有的格子中以 `filter` 配合 `map` 找到地雷的 `pos` 屬性
接著用 `sort` 排序以後, 與旗幟的 `pos` 進行 `JSON.stringify` 比對, 就可以得到答案

```js
function isWin() {
    let flatCells = cells.flat()
    let booms = flatCells.filter(x => x.isBoom).map(x => x.pos).sort()
    let flagsPos = flags.filter(x => x.isUse).map(x => x.pos).sort()
    let result = JSON.stringify(booms) === JSON.stringify(flagsPos)
    return result
}
```

多半踩地雷插旗都會用 `右鍵` 這算個特別動作, 需要讓 dom 監聽 `contextmenu`, 搭配 `event.preventDefault` 方可達成
這裡取得 `domCell` 以後可以使用 `domCell.dataset.pos` 得到我們自訂的屬性 `pos`
這裡需要注意, 拿到的 `pos` 需要用 `parseInt(pos)` 轉為數字, 不然呼叫 `findCell` 會得不到格子
```js
game.addEventListener('contextmenu', (event) => {
    event.preventDefault();
    let domCell = event.target;
    let pos = domCell.dataset.pos
    let cell = findCell(parseInt(pos))
    rightClickCell(cell)
})

//以 pos 找格子
function findCell(pos) {
    let flatCells = cells.flat()
    let cell = flatCells.find(x => x.pos === pos)
    return cell
}
```

最後看到 `rightClickCell` 先用 `querySelector` 取得 dom 物件
接著找旗幟 `flags array` 裡面是否有這格被標記
沒找到的話則使用 `flags.every(f => f.isUse === true)` 來看看是否已經把全部的 flag 使用完
如果還有旗幟可以使用則設定該 flag 標記的屬性

萬一這格的旗子已經被標記的化, 則設定 `flag.isUse = false` 等屬性, 讓旗幟處於沒標記的狀況

```js
function rightClickCell(cell) {
    if (cell.isHidden === false) return

    let domCell = document.querySelector(`[data-pos="${cell.pos}"]`);

    let flag = flags.find(f => f.x === cell.x && f.y === cell.y)
    if (!flag) {
        let noFlags = flags.every(f => f.isUse === true)
        if (noFlags) return

        flag = flags.find(f => f.isUse === false)
        flag.x = cell.x
        flag.y = cell.y
        flag.pos = cell.pos
        flag.isUse = true
        domCell.textContent = '🚩'

        if (isWin()) alert('You Win ~')
    } else {
        flag.x = -1
        flag.y = -1
        flag.pos = -1
        flag.isUse = false
        domCell.textContent = ''
    }
}
```

## 打開格子 aka 踩地雷
這應該是這個程式最讓人登出也最困難的地方, 因為會用到遞迴, 這個寫法可能並不完美, 應該是可以把邏輯調整更好, 不過考量到夜已深, 就放棄 XD
首先用 `querySelectorAll` 撈出所有格子, 然後加入 `click` 監聽事件
接著看到 `clickCell`
當是炸彈的話, 就直接給 `game over`

反之先判斷是否為空地, 如果非空地的話, 直接設定 `textContent` 把附近有幾個地雷塞進去即可
最後則是看到最難點 `遞迴`, 有兩個主要動作組成

* 首先使用 `scanZeroAround` 把自己周圍 `八格` `非空地` 的格子蒐集起來, 然後逐一打開
* 使用 `scanZero` 掃出 `上下左右` 格子為 `空地` 的, 接著一樣使用 `scanZeroAround` 把非空地的打開

```js
let domCells = document.querySelectorAll('[class^="cell"]')
domCells.forEach(domCell => {
    domCell.addEventListener('click', function () {
        let pos = domCell.dataset.pos
        let cell = findCell(parseInt(pos))
        //這裡一定要寫這樣生命週期才會正確
        //不然拿不到 querySelector 的 dom
        clickCell(cell)
    })
})

function clickCell(cell) {
    if (cell.isHidden === false) return

    cell.isHidden = false
    let domCell = document.querySelector(`[data-pos="${cell.pos}"]`);
    if (cell.isBoom) {
        domCell.textContent = '🍑'
        alert('Game Over!')
    } else {
        //如果是空格需要遞迴掃描
        if (cell.hint === 0) {
            domCell.textContent = cell.hint

            //自己周圍要先點
            let selfAroundCells = scanZeroAround(cell)
            for (let selfAroundCell of selfAroundCells) {
                clickCell(selfAroundCell)
            }

            //其他 0 相鄰的
            let scanCells = scanZero(cell)
            for (let zeroCell of scanCells) {
                let aroundCells = scanZeroAround(zeroCell)
                for (let aroundCell of aroundCells) {
                    clickCell(aroundCell)
                }
            }

        } else {
            domCell.textContent = cell.hint
        }
    }
}
```
