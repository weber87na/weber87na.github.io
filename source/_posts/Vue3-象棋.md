---
title: Vue3 象棋
date: 2023-08-01 18:37:18
tags:
- vue3
- js
---
![image](https://raw.githubusercontent.com/weber87na/flowers/master/%E9%9B%BB%E9%BE%9C5.png)
<!-- more -->

<p class="codepen" data-height="700" data-slug-hash="VwVXboY" data-user="weber87na" style="height: 700px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/VwVXboY">
  龜小象棋</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

有了暗棋當然也要有象棋 , 算是致敬當年勸退的事件 , 不然感覺有點遜 XD 
我另外也有做 [angular 版本](https://stackblitz.com/edit/chinese-chees?file=src%2Fmain.ts)
象棋用 angular 來做就複雜多了 , 有些 ts 的地雷要採 , 如果這包直接搬過去的話會狂噴 `is not defined function`

## 資料結構
### 棋子
首先定義棋子的部分
`id` => 區分每個子的唯一識別編號
`name` => 顯示該棋子是 兵 炮 或其他兵種使用
`suit` => 紅色或黑色
`lv` => 棋子的等級 , 由此判斷他能吃什麼子 , 或他的移動行為
`x` => 目前的 x 座標
`y` => 目前的 y 座標
`move` => 移動的函數 , 不過後來改寫成 angular 發現這個方式不太好 , 應該建立移動的類別去處理 , 這裡就暫時這樣
```
{ id: 1, name: '俥', suit: 'red', lv: 4, x: 0, y: 0, move: moveCar },
```
依序塞入 cheesPool 的 array 內即可

### 棋盤
棋盤其實就是由一堆格子構成 , 它的結構比較簡單
`id` => 區分每格的唯一識別編號 , 象棋竟然有 90 格編到心累
`x` => 該格的 x 座標
`y` => 該格的 y 座標
`chees` => 這格上面的棋子

```
{ id: 1, x: 0, y: 0, chees: cheesPool.value[0] },
```
依序將每格放入 cells 的 array , 並且設定棋子的位置

## UI 設計
### html
象棋的棋盤跟暗棋不太一樣 , 他是走在線上 , 所以運用兩個 `div` 設定 `grid` , 分別設定紅方及黑方的黑線格子的視覺外觀
這裡比較特別的是使用 `v-for="index in 32"` 來 `loop`

接著定義每個格子 , 如同暗棋
先用 `v-for` 對整個棋盤進行 `loop` 每個格子 `cell`
`@drop` 需要設定 `onDrop` 讓棋子可以被拖拉到格子上
`@dragover & @dragover` 都要設定 `prevent`

然後在格子內塞個 `div` 設定 `v-if` 去判斷這格是否有棋子 , 如果有的話則顯示該子 , 並讓他的事件 & 樣式可以觸發套用
`:class` 內設定這個棋子是否被翻開及套用它的花色
`:draggable` 這裡永遠是 `true`
`@dragstart` 裡面放 `onDrag` 這個事件
最後 div 內擺上該子是啥兵種即可

``` html
<div id="app">
	<div class="board">
		<div class="inner-board inner-board-top">
			<div class="inner-cell"
				v-for="index in 32"></div>
		</div>

		<div class="inner-board inner-board-bottom">
			<div class="inner-cell"
				v-for="index in 32"></div>
		</div>
		<div class="cell"
			v-for="cell in cells"
			@drop="onDrop($event, cell)"
			@dragover.prevent
			@dragenter.prevent>
			<div v-if="cell.chees">
				<div class="chees"
					:class="cell.chees.suit"
					@dragstart="onDrag($event, cell)"
					:draggable="true">
					{{cell.chees.name}}
				</div>
			</div>
		</div>
	</div>
</div>
```

### css
先把 `board` 設定為 `grid` 定義出棋盤上的格子共 `90` 格
``` css
.board {
	display: grid;
	grid-template-columns: repeat(9, 1fr);
	grid-template-rows: repeat(10, 1fr);
	grid-column-gap: 0px;
	grid-row-gap: 0px;

	width: calc(90px * var(--size));
	height: calc(100px * var(--size));

	position: relative;
}
```

然後在 `cell` 的部分設定 `outline` 為紅色虛線方便 debug
實際上棋子是走在紅線的格子內 , 非眼睛看到的黑線上面
``` css
.cell {
	background-color: #ffd664;
	outline: 1px dashed #f00;
	display: flex;
	justify-content: center;
	align-items: center;
}
```

最後分別設定紅方及黑方的行走區塊 , 他是一個 `8 * 4` 的 `grid` 結構 , 然後用絕對定位去定位他們
這裡還有個重點 , 要把 `user-select` & `pointer-events` 都設定為 `none` 防止前端 `drag drop` 出現 `bug`
``` css
.inner-board {
	display: grid;
	grid-template-columns: repeat(8, 1fr);
	grid-template-rows: repeat(4, 1fr);
	grid-column-gap: 0px;
	grid-row-gap: 0px;

	width: 480px;
	height: 240px;
	position: absolute;
	outline: 2px solid #000;
	user-select: none;
	pointer-events: none;
}
```

## 核心邏輯說明
因為不太會下象棋 , 所以規則可以參考[這裡](https://www.cccs.org.tw/Message/MessageView?mid=32&itemid=57)
這把我就懶得去做切換 `user` 的回合 , 還有王將飛越這兩個部分 , 但是其他都實作完成
### Drag 棋子
先看看該格子上是否有棋子 , 有的話設定 `dataTransfer` 讓 `Drop` 時可以接收
``` js
function onDrag(event, cell) {
	let chees = cell.chees
	if (chees === undefined) return

	// console.log('drag', event)
	// console.log('drag', chees)
	// console.log('drag', cell)

	event.dataTransfer.dropEffect = 'move'
	event.dataTransfer.effectAllowed = 'move'
	event.dataTransfer.setData('cheesId', chees.id)
	event.dataTransfer.setData('cellId', cell.id)
}
```

### Drop 棋子
這裡因為利用物件的 `move` 方法去處理移動的邏輯 , 所以比較簡單 , 只要得到 `dragChees` 然後呼叫 `move` 即可 , 各子會依照其對應的真正移動方法進行移動
``` js
function onDrop(event, dropCell) {
	// console.log(dropCell)
	const dragCellId = parseInt(event.dataTransfer.getData('cellId'))
	const dragCell = cells.value.find(x => x.id == dragCellId)

	const dragChees = dragCell.chees
	dragChees.move(dragCell, dropCell)
}
```


### 移動及吃子
首先判斷該格是否有棋子 , 沒有子的話移動過去 , 反之則吃子
這個函數是算是最後一步 , 其他所有函數移動時都會有個防禦式的函數去設定 `canMove` 來判斷是否可以移動
當 `canMove` 得到 `true` 則呼叫 `move` 函數進行吃子或是移動 , 後續的函數也都利用類似的作法去實作

> `特別注意` 這個 `move` 方法 `並非` 棋子物件內的 `move` 方法

``` js
function move(dragCell, dropCell) {
	const dragChees = dragCell.chees

	//如果沒有棋子在上面的話則移動過去
	if (dropCell.chees === undefined) {
		//清空原來位置上的棋子
		// console.log(dragCell)
		dragCell.chees = undefined

		//設定棋子位置
		dragChees.x = dropCell.x
		dragChees.y = dropCell.y
		dropCell.chees = dragChees

	} else {
		//表示有棋子
		//判斷花色不同的
		if (dropCell.chees.suit !== dragChees.suit) {
			dragCell.chees = undefined

			//幹掉棋子
			dropCell.chees = undefined

			//設定棋子位置
			dragChees.x = dropCell.x
			dragChees.y = dropCell.y
			dropCell.chees = dragChees

		}
	}
}
```

### 移動兵卒
首先兵卒的規則是只能前進沒法後退 , 一次只能移動一格 , 並且過了河之後可以橫向移動
對於黑方來說河的邊界在 `y <= 4` 紅方則是 `y >= 5` 如果超過這個範圍兵卒就可以橫向移動
``` js
//移動兵卒
function moveSoldier(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees
	if (dragChees.suit === 'black') {
		canMove = moveBlackSoldier(dragCell, dropCell)
	} else {
		canMove = moveRedSoldier(dragCell, dropCell)
	}

	if (canMove) move(dragCell, dropCell)
}


function moveBlackSoldier(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	//有進無退
	if (dropCell.y > dragChees.y) {
		canMove = false
		return canMove
	}

	//當 x 相等時表示正常前進
	if (dragChees.x === dropCell.x) {
		//如果 y - 1 的話表示正常前進
		if (dragChees.y - 1 === dropCell.y) {
			canMove = true
			return canMove
		}
	}

	//想要橫向移動
	if (dragChees.x !== dropCell.x && dragChees.y === dropCell.y) {
		//判斷是否過河
		if (dragChees.y <= 4) {
			//計算距離是否為 1 格
			let distanceX = Math.abs(dropCell.x - dragChees.x)
			if (distanceX === 1) {
				canMove = true
				return canMove
			}
		}
	}

	return canMove
}


function moveRedSoldier(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	//有進無退
	if (dropCell.y < dragChees.y) {
		canMove = false
		return canMove
	}

	//當 x 相等時表示正常前進
	if (dragChees.x === dropCell.x) {
		//如果 y + 1 的話表示正常前進
		if (dragChees.y + 1 === dropCell.y) {
			canMove = true
			return canMove
		}
	}

	//想要橫向移動
	if (dragChees.x !== dropCell.x && dragChees.y === dropCell.y) {
		//判斷是否過河
		if (dragChees.y >= 5) {
			//計算距離是否為 1 格
			let distanceX = Math.abs(dropCell.x - dragChees.x)
			if (distanceX === 1) {
				canMove = true
				return canMove
			}
		}
	}

	return canMove
}
```


### 將帥移動
將帥移動的邏輯也相對容易 , 需要限定它們在各自的 `3 * 3` 範圍之內 , 並且一次也只能移動一格
所以他們的 `x` 被限定在 `dropCell.x >= 3 && dropCell.x <= 5` 以內
`y` 的移動範圍若為紅方則限定在 `3` 以內 , 黑方則為 `7` 以內
``` js
function moveGeneral(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees
	if (dragChees.suit === 'black') {
		canMove = moveBlackGeneral(dragCell, dropCell)
	} else {
		canMove = moveRedGeneral(dragCell, dropCell)
	}

	if (canMove) move(dragCell, dropCell)
}

function moveRedGeneral(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees
	//左右移動
	if (Math.abs(dragChees.x - dropCell.x) === 1 &&
		dragChees.y === dropCell.y &&
		dropCell.y <= 2 &&
		dropCell.x >= 3 && dropCell.x <= 5
	) {
		canMove = true
	}

	//上下移動
	if (Math.abs(dragChees.y - dropCell.y) === 1 &&
		dragChees.x === dropCell.x &&
		dropCell.y <= 2 &&
		dropCell.x >= 3 && dropCell.x <= 5
	) {
		canMove = true
	}

	return canMove
}


function moveBlackGeneral(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees
	//左右移動
	if (Math.abs(dragChees.x - dropCell.x) === 1 &&
		dragChees.y === dropCell.y &&
		dropCell.y >= 7 &&
		dropCell.x >= 3 && dropCell.x <= 5
	) {
		canMove = true
	}

	//上下移動
	if (Math.abs(dragChees.y - dropCell.y) === 1 &&
		dragChees.x === dropCell.x &&
		dropCell.y >= 7 &&
		dropCell.x >= 3 && dropCell.x <= 5
	) {
		canMove = true
	}

	return canMove

}
```

### 士的移動
士跟將一樣只能在限定的 `3 * 3` 小圈圈內打轉
不過是走斜的 , 所以表示每次移動時 `x & y` 兩者都必須 `+1 or -1`
這裡用 `Math.abs` 去計算這兩者是否都有增加或是減少
`Math.abs(dragChees.x - dropCell.x) === 1 && Math.abs(dragChees.y - dropCell.y) === 1`
``` js
function moveOfficer(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees
	if (dragChees.suit === 'black') {
		canMove = moveBlackOfficer(dragCell, dropCell)
	} else {
		canMove = moveRedOfficer(dragCell, dropCell)
	}

	if (canMove) move(dragCell, dropCell)
}


function moveRedOfficer(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	if (Math.abs(dragChees.x - dropCell.x) === 1 &&
		Math.abs(dragChees.y - dropCell.y) === 1 &&
		dropCell.y <= 2 &&
		dropCell.x >= 3 && dropCell.x <= 5
	) {
		canMove = true
	}
	return canMove
}


function moveBlackOfficer(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	if (Math.abs(dragChees.x - dropCell.x) === 1 &&
		Math.abs(dragChees.y - dropCell.y) === 1 &&
		dropCell.y >= 7 &&
		dropCell.x >= 3 && dropCell.x <= 5
	) {
		canMove = true
	}
	return canMove
}
```


### 象的移動
象只能走田字 , 如果中心點有其他子的話 , 則會被拐象腳 , 另外象也不能過河
所以他的移動邏輯可以說就是士的放大版 , 一樣用 `Math.abs` 去處理他的行走方法只不過這次 `x & y` 都要是 `2`
並且限定在自己的國界內 , 黑方為 `y >= 5` 紅方為 `y <= 4`
最後判斷是否有拐象腳 , 判斷其四方的中心點是否有子 , 如果為 `undefined` 才回傳 `true`
``` js
function moveElephant(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees
	if (dragChees.suit === 'black') {
		canMove = moveBlackElephant(dragCell, dropCell)
	} else {
		canMove = moveRedElephant(dragCell, dropCell)
	}

	if (canMove) move(dragCell, dropCell)
}

function moveBlackElephant(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	if (Math.abs(dragChees.x - dropCell.x) === 2 &&
		Math.abs(dragChees.y - dropCell.y) === 2 &&
		dropCell.y >= 5
	) {
		//左上移動
		if (dropCell.x < dragChees.x && dropCell.y < dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y - 1 && cell.x == dragChees.x - 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}

		//右下移動
		if (dropCell.x > dragChees.x && dropCell.y > dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y + 1 && cell.x == dragChees.x + 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}

		//右上移動
		if (dropCell.x > dragChees.x && dropCell.y < dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y - 1 && cell.x == dragChees.x + 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}

		//左下移動
		if (dropCell.x < dragChees.x && dropCell.y > dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y + 1 && cell.x == dragChees.x - 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}
	}

	return canMove
}

function moveRedElephant(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	if (Math.abs(dragChees.x - dropCell.x) === 2 &&
		Math.abs(dragChees.y - dropCell.y) === 2 &&
		dropCell.y <= 4
	) {
		//左上移動
		if (dropCell.x < dragChees.x && dropCell.y < dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y - 1 && cell.x == dragChees.x - 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}

		//右下移動
		if (dropCell.x > dragChees.x && dropCell.y > dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y + 1 && cell.x == dragChees.x + 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}

		//右上移動
		if (dropCell.x > dragChees.x && dropCell.y < dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y - 1 && cell.x == dragChees.x + 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}

		//左下移動
		if (dropCell.x < dragChees.x && dropCell.y > dragChees.y) {
			let find = cells.value.find(cell => cell.y == dragChees.y + 1 && cell.x == dragChees.x - 1)
			if (find.chees === undefined) {
				canMove = true
				return canMove
			}
		}
	}

	return canMove
}
```


### 馬的移動
馬的移動 XD 好像在講髒話
馬比較複雜 , 他是走日 , 總共有八個方位可以移動
並且還有拐馬腳的規則 , 如果其他子在他的上下左右四方 , 他就會遭到受限  , 可以參考下圖會更清楚
另外眼睛的視線專注在紅色虛線框出來的格子裡 , 這樣寫才清晰直覺
![image](https://storage.potatomedia.co/articles/potato_dbb1fbf1-e77e-4952-adba-8f549590248d_2b2a57799cbd03b71e0b07f6557e93a67863597e.png)

我這裡用跟 `css border` 一樣的規則由左上開始順時針計算 , 共八個方位
所以由左上的直向日開始 , 接著右上直向日 , 接著右上橫日依序下去
如果移動直向日的話則 `x` 需 `+1 or -1` 而 y 則 `+2 or -2`
如果移動橫向日的話則 `x` 需 `+2 or -2` 而 y 則 `+1 or -1`
若有棋子在上下的話 , 則無法移動該子對應方位的直向日
若有棋子在左右的話 , 則無法移動該子對應方位的橫向日
所以用 `find` 函數去找對應的上下左右是否有子 , 若有的話則在該邏輯式判斷為拐馬腳
``` js
function moveHorse(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees
	canMove = canMoveHorse(dragCell, dropCell)
	if (canMove) move(dragCell, dropCell)
}

function canMoveHorse(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	//1
	if (dragChees.x === dropCell.x + 1 && dragChees.y === dropCell.y + 2) {
		//判斷上邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x && cell.y == dragChees.y - 1
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	//2
	if (dragChees.x === dropCell.x - 1 && dragChees.y === dropCell.y + 2) {
		//判斷上邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x && cell.y == dragChees.y - 1
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	//3
	if (dragChees.x === dropCell.x - 2 && dragChees.y === dropCell.y + 1) {
		//判斷右邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x + 1 && cell.y == dragChees.y
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	//4
	if (dragChees.x === dropCell.x - 2 && dragChees.y === dropCell.y - 1) {
		//判斷右邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x + 1 && cell.y == dragChees.y
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	//5
	if (dragChees.x === dropCell.x - 1 && dragChees.y === dropCell.y - 2) {
		//判斷上邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x && cell.y == dragChees.y + 1
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	//6
	if (dragChees.x === dropCell.x + 1 && dragChees.y === dropCell.y - 2) {
		//判斷上邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x && cell.y == dragChees.y + 1
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	//7
	if (dragChees.x === dropCell.x + 2 && dragChees.y === dropCell.y - 1) {
		//判斷左邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x - 1 && cell.y == dragChees.y
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	//8
	if (dragChees.x === dropCell.x + 2 && dragChees.y === dropCell.y + 1) {
		//判斷左邊有無拐馬腳
		let find = cells.value.find(cell =>
			cell.x == dragChees.x - 1 && cell.y == dragChees.y
		)
		if (find.chees) {
			canMove = false
			return canMove
		}
		canMove = true
		return canMove
	}

	return canMove
}
```

### 車的移動
車的移動跟炮類似 , 他可以很霸道的走直線或橫線 , 這裡比較特別的是用了 `c# 委派的概念` , 也就是將函數作為參數傳遞進去 `canMoveCar` 裡
`calcMoveCarXXX` 系列函數定義了 `x & y` 軸往左右移動統計棋子的邏輯 , 這系列函數炮也一樣會用到
另外我邏輯條件為 `x <= distance` 所以跟暗棋有細微的不同
如果統計起來為 `1` 並且是花色相異的子表示吃子
若為 `0` 則表示可以移動過去
``` js
function moveCar(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	//直向向上移動
	if (dragChees.x === dropCell.x && dropCell.y < dragCell.y) {
		canMove = canMoveCar(dragCell, dropCell, calcMoveCarTop)
		if (canMove) move(dragCell, dropCell)
		return
	}

	//直向向下移動
	if (dragChees.x === dropCell.x && dropCell.y > dragCell.y) {
		canMove = canMoveCar(dragCell, dropCell, calcMoveCarBottom)
		if (canMove) move(dragCell, dropCell)
		return
	}

	//橫向向左
	if (dragChees.y === dropCell.y && dropCell.x < dragCell.x) {
		canMove = canMoveCar(dragCell, dropCell, calcMoveCarLeft)
		if (canMove) move(dragCell, dropCell)
		return
	}

	//橫向向右
	if (dragChees.y === dropCell.y && dropCell.x > dragCell.x) {
		canMove = canMoveCar(dragCell, dropCell, calcMoveCarRight)
		if (canMove) move(dragCell, dropCell)
		return
	}

}


function canMoveCar(dragCell, dropCell, fn) {
	let canMove = false
	let counter = 0;
	counter = fn(dragCell, dropCell)
	if (counter === 1 &&
		dropCell.chees !== undefined &&
		dropCell.chees.suit !== dragCell.chees.suit) {
		canMove = true
	}
	if (counter === 0 && dropCell.chees === undefined) {
		canMove = true
	}
	return canMove
}


function calcMoveCarBottom(dragCell, dropCell) {
	const dragChees = dragCell.chees
	let counter = 0;
	//計算 Y 軸上的棋子數量
	let distanceY = Math.abs(dragChees.y - dropCell.y)
	//向上移動
	for (let i = 1; i <= distanceY; i++) {
		let isFind = cells.value.find(cell => cell.y == dragCell.y + i && cell.x == dragCell.x)
		if (isFind.chees) {
			counter++
		}
	}
	return counter
}


function calcMoveCarTop(dragCell, dropCell) {
	const dragChees = dragCell.chees
	let counter = 0;
	//計算 Y 軸上的棋子數量
	let distanceY = Math.abs(dragChees.y - dropCell.y)
	//向上移動
	for (let i = 1; i <= distanceY; i++) {
		let isFind = cells.value.find(cell => cell.y == dragCell.y - i && cell.x == dragCell.x)
		console.log(dragCell)
		console.log('i', i)
		console.log('isFind', isFind)
		if (isFind.chees) {
			counter++
		}
	}
	return counter
}

function calcMoveCarLeft(dragCell, dropCell) {
	const dragChees = dragCell.chees
	let counter = 0;
	//計算 X 軸上的棋子數量
	let distanceX = Math.abs(dragChees.x - dropCell.x)
	//向左移動
	for (let i = 1; i <= distanceX; i++) {
		let isFind = cells.value.find(cell => cell.x == dragCell.x - i && cell.y == dragCell.y)
		console.log(dragCell)
		console.log('i', i)
		console.log('isFind', isFind)
		if (isFind.chees) {
			counter++
		}
	}
	return counter
}

function calcMoveCarRight(dragCell, dropCell) {
	const dragChees = dragCell.chees
	let counter = 0;
	//計算 X 軸上的棋子數量
	let distanceX = Math.abs(dragChees.x - dropCell.x)
	//向右移動
	for (let i = 1; i <= distanceX; i++) {
		let isFind = cells.value.find(cell => cell.x == dragCell.x + i && cell.y == dragCell.y)
		if (isFind.chees) {
			counter++
		}
	}
	return counter
}
```

### 炮的移動
炮的移動基本上跟車幾乎一樣 , 所以沿用車的 `calcMoveCarXXX` 系列函數
不過他吃子的方式不同 , 當統計為 `2` 子並且花色相異才可以用飛躍的方式吃子移動

若為 0 則表示可以移動過去
```
function canMoveArtillery(dragCell, dropCell, fn) {
	let canMove = false
	let counter = 0;
	counter = fn(dragCell, dropCell)
	if (counter === 2 &&
		dropCell.chees !== undefined &&
		dropCell.chees.suit !== dragCell.chees.suit) {
		canMove = true
	}
	if (counter === 0 && dropCell.chees === undefined) {
		canMove = true
	}
	return canMove

}

function moveArtillery(dragCell, dropCell) {
	let canMove = false
	const dragChees = dragCell.chees

	//直向向上移動
	if (dragChees.x === dropCell.x && dropCell.y < dragCell.y) {
		canMove = canMoveArtillery(dragCell, dropCell, calcMoveCarTop)
		if (canMove) move(dragCell, dropCell)
		return
	}

	//直向向下移動
	if (dragChees.x === dropCell.x && dropCell.y > dragCell.y) {
		canMove = canMoveArtillery(dragCell, dropCell, calcMoveCarBottom)
		if (canMove) move(dragCell, dropCell)
		return
	}

	//橫向向左
	if (dragChees.y === dropCell.y && dropCell.x < dragCell.x) {
		canMove = canMoveArtillery(dragCell, dropCell, calcMoveCarLeft)
		if (canMove) move(dragCell, dropCell)
		return
	}

	//橫向向右
	if (dragChees.y === dropCell.y && dropCell.x > dragCell.x) {
		canMove = canMoveArtillery(dragCell, dropCell, calcMoveCarRight)
		if (canMove) move(dragCell, dropCell)
		return
	}
}
```
