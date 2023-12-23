---
title: Vue3 前端分頁
date: 2023-08-12 01:25:53
tags: 
- vue3
- js
---
&nbsp;
<!-- more -->

<p class="codepen" data-height="389" data-default-tab="result" data-slug-hash="OJaeQoG" data-user="weber87na" style="height: 389px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/OJaeQoG">
  Vue3前端分頁</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

## 功能分析 & 實作
分頁應該是個每隔一兩年就會跑出來的問題 , 懶一點就用套件 , 不然自幹還是要想一陣子
剛好遇到之前修復 angularjs 滿滿 bug 的分頁 , 就順便整理下寫成 vue3
大概會需要以下幾個東西

`主要資料源` => 反正就某個地方的 `json` array
`閹割過的主要資料源` => 實際上看到 `table` or `list` 的應該是他
`每頁裡面顯示的資料筆數` => 通常就是 `5` or `10`
`總頁數` => `ceil(主要資料源的數量 / 每頁裡面顯示的資料筆數)`
`總頁碼的 array` => 大概長這樣 [1 , 2 , 3 , 4 , 5 , 6 , 7 , 8]
`顯示的頁碼 array` => 預期 `5` 頁的話大概長這樣 [1 , 2 , 3 , 4 , 5]
`目前選到的頁碼`
`跳任意頁`
`第一頁`
`上一頁`
`下一頁`
`最後一頁`

### html & css
我這裡有套 bootstrap 5 , 大致上分為兩個部分 , `table` 裡面擺閹割過的主要資料源顯示資料 , `nav` 裡則是分頁的頁碼
``` html
    <div id="app">
        <table class="table table-striped table-hover">
            <thead>
                <tr>
                    <th scope="col">id</th>
                    <th scope="col">name</th>
                    <th scope="col">color</th>
                </tr>
            </thead>
            <tbody>
                <tr v-for="flower in displayFlowers">
                    <td>{{ flower.id }}</td>
                    <td>{{ flower.name }}</td>
                    <td>{{ flower.color }}</td>
                </tr>
            </tbody>
        </table>

        <nav aria-label="...">
            <ul class="pagination">

                <li class="page-item"
                    @click="gotoFirstPage()">
                    <a class="page-link"
                        href="javascript:;">First</a>
                </li>

                <li class="page-item"
                    @click="gotoPrevPage()">
                    <a class="page-link"
                        href="javascript:;">Previous</a>
                </li>


                <li class="page-item"
                    :class="{active:isActive(page)}"
                    v-for="page in displayPageArray"
                    @click="gotoPage(page)">
                    <a class="page-link"
                        href="javascript:;"> {{ page }}</a>
                </li>

                <li class="page-item"
                    @click="gotoNextPage()">
                    <a class="page-link"
                        href="javascript:;">Next</a>
                </li>

                <li class="page-item"
                    @click="gotoLastPage()">
                    <a class="page-link"
                        href="javascript:;">Last</a>
                </li>

            </ul>
        </nav>
    </div>
```

css 我只擺個居中沒啥好講的
```
	body {
		display: flex;
		justify-content: center;
		align-items: center;

	}
```

### js
首先用 `ref` 定義一個 `flowers` 的主要資料源
``` js
let flowers = ref([
	{ id: 1, name: '玫瑰', color: 'red' },
	{ id: 2, name: '太陽花', color: 'yellow' },
	{ id: 3, name: '向日葵', color: 'yellow' },
	{ id: 4, name: '薰衣草', color: 'purple' },
	{ id: 5, name: '鬱金香', color: 'pink' },
	...
```


接著算出總頁數
``` js
let totalPageSize = Math.ceil(flowers.value.length / pageRows)
```

然後用 `slice` 函數 , 類似 `linq` 裡面的 `skip` + `take` 功能
假設有個資料源 `[1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 , 10]`
`slice(0 , 5)` => `[1 , 2 , 3 , 4 , 5]`
`slice(5 , 10)` => `[6 , 7 , 8 , 9 , 10]`

`pageRows` 表示 `每頁裡面顯示的資料筆數`
`currentPage` 目前選到第幾頁 , 起始為 `1`
要注意 `slice` 則由 `0` 開始計算

假設第一頁取 `5 * 1 - 5` 及 `5 * 1`
假設第二頁取 `5 * 2 - 5` 及 `5 * 2`

所以可以快速得出分頁結果
``` js
let displayFlowers = computed(
	() => {
		if (flowers.value.length > 5) {
			return normalSize();
		} else {
			return flowers.value
		}
	}
)
function normalSize() {
	return flowers.value.slice(
		pageRows * currentPage.value - pageRows,
		pageRows * currentPage.value
	)
}
```

接著定義出 `目前選到的頁碼` `跳任意頁` 等函數 , 另外還有個 `isActive` 這個是拿來套用目前選到頁碼樣式的
```
let currentPage = ref(1)
function gotoPage(page) {
	currentPage.value = page
}

function gotoLastPage() {
	currentPage.value = totalPageSize
}

function gotoFirstPage() {
	currentPage.value = 1
}

function gotoPrevPage() {
	if (currentPage.value > 1)
		currentPage.value = currentPage.value - 1
}

function gotoNextPage() {
	if (currentPage.value < totalPageSize)
		currentPage.value = currentPage.value + 1
}

function isActive(page) {
	return currentPage.value === page
}
```

接著就是最核心的地方 , 計算頁碼
先 loop 總頁碼然後 push 到 array 裡面
如果分頁數量小於 5 就直接 return , 因為算法失去意義

如果分頁數量大於 5 的話 , 先看看目前選到的頁碼是否小於 3 , 是的話直接傳 `[1, 2, 3, 4, 5]`
接著處理選到尾端的狀況 , 如果已經滑到尾部 , 則直接回傳由最末端的五個數值 `[4 , 5 , 6 , 7 , 8]`
其他則表示正常狀況 , 將目前選到的頁作為中心值依序增減直到符合預計的分頁大小即可
``` js
//取得顯示分頁的所有數字 1 - N
function getPages() {
	let result = []
	for (let i = 1; i <= totalPageSize; i++) {
		result.push(i)
	}
	return result
}


//預計要顯示的分頁數量
let displayPageSize = 5

//實際上計算頁碼的函數
function getDisplayPages() {
	let pages = getPages()

	let result = [];
	//如果顯示分頁數量小於等於 5 直接 return
	if (pages.length <= 5) {
		return pages
	}

	//如果顯示分頁數量大於 5 的話執行以下三個判斷
	//頭
	if (currentPage.value < 3) {
		result = [1, 2, 3, 4, 5]
		return result
	}

	//尾
	if (currentPage.value >= pages.length - 2) {
		result.push(pages.length - 4)
		result.push(pages.length - 3)
		result.push(pages.length - 2)
		result.push(pages.length - 1)
		result.push(pages.length)
		return result
	}

	//正常狀況
	if (currentPage.value >= 3) {
		result.push(currentPage.value - 2)
		result.push(currentPage.value - 1)
		result.push(currentPage.value)
		result.push(currentPage.value + 1)
		result.push(currentPage.value + 2)
		return result;
	}
}


```

## 貓毛 bug 修復
不過做到這裡如果遇到很 `貓毛` 的人會認為是 `bug` 有一點點不完美 , 因為我的算法讓 `active & focus` 有可能是不一致的情形
原本的動作假設是點第 4 頁的話 , 會 `active` 第 4 頁 , 但是會 `focus` 在第 5 頁
要完美的話可以用 `mousedown` `mouseup` `click` 這三個事件搭配
依靠事件的順序特性來解決 , 他們順序是這樣 `mouseDown` => `mouseUp` => `mouseClick` 不過在此 `mouseUp` 用不到

先宣告一個 `ref=pageItems` 特別注意因為是 `loop` 蓋出的 `element` 所以這裡會是一個 `array`
接著當呼叫 `mouseDown` 時先用 `event.preventDefault()` 消除 `focus` , 呼叫 `gotoPage(page)` 接著切換頁碼
然後呼叫 `mouseClick` 這時候取得 `ref array` 裡面的 `active element`
這時候拿到 `li` 粗暴的用 `querySelector('a')` 直接得到 `a` 並且 `focus`
如果把 `let activeEle = pageItems.value.find(x => x.classList.contains('active'))` 插在 `mouseClick` 的話
會拿到一開始點選的 `active` 元素

``` js
//https://stackoverflow.com/questions/71093658/how-to-get-refs-using-composition-api-in-vue3
//這裡會拿到 array , 然後他的數量會是顯示分頁的大小 所以是 5 筆
const pageItems = ref(null);

function mouseDown(page) {
	console.log('mouseDown')
	event.preventDefault()
	gotoPage(page)
}

function mouseUp(event) {
	console.log('mouseUp')
}

//https://stackoverflow.com/questions/71093658/how-to-get-refs-using-composition-api-in-vue3
//這裡會拿到 array , 然後他的數量會是顯示分頁的大小 所以是 5 筆
const pageItems = ref(null);

//這裡拿到的資訊是已經切換頁碼
function mouseClick(event, page) {
	//取得目前 active 的 li
	let activeEle = pageItems.value.find(x => x.classList.contains('active'))
	// console.log(activeEle.querySelector('a'))
	//因為拿到 li 直接用 querySelector 拿底下的 a 標籤
	let tag = activeEle.querySelector('a')
	tag.focus()
}

function gotoPage(page){
	currentPage.value = page
}
```

html 調整如下
``` html
	<li class="page-item"
		:class="{active:isActive(page)}"
		@mousedown="mouseDown(page)"
		@mouseup="mouseUp($event)"
		@click="mouseClick($event , page)"
		ref="pageItems"
		v-for="page in displayPageArray">
		<a class="page-link"
			href="javascript:;"> {{ page }}</a>
	</li>
```


## drag & drop
順便玩玩 drag & drop 功能 , 因為寫過 N 次了所以也不難 XD
這裡有個重點就是怎麼改變 drag & drop 的 index , 我的邏輯是可以交換兩個元素的位置
但是也有種把 drag 之後的元素往前推方法 , 可以參考[這裡](https://sortablejs.github.io/Vue.Draggable/#/simple)就是用這種方法

html
```
	<tr v-for="flower in displayFlowers"
		draggable="true"
		@dragstart="onDrag($event, flower)"
		@drop="onDrop($event, flower)"
		@dragover.prevent
		@dragenter.preven>
		<td>{{ flower.id }}</td>
		<td>{{ flower.name }}</td>
		<td>{{ flower.color }}</td>
	</tr>
```

js
```
	function onDrag(event, flower) {
		event.dataTransfer.dropEffect = 'move'
		event.dataTransfer.effectAllowed = 'move'
		event.dataTransfer.setData('id', flower.id)
	}

	// 交換式
	// function onDrop(event, flower) {
	//     let dragId = parseInt(event.dataTransfer.getData('id'))
	//     let dropId = flower.id
	//     let dragIndex = flowers.value.findIndex(x => x.id === dragId)
	//     let dropIndex = flowers.value.findIndex(x => x.id === dropId)
	//     let temp = flowers.value[dragIndex]
	//     flowers.value[dragIndex] = flowers.value[dropIndex]
	//     flowers.value[dropIndex] = temp
	// }

	//drag 之後的元素往前推
	function onDrop(event, flower) {
		let dragId = parseInt(event.dataTransfer.getData('id'))
		let dropId = flower.id
		let dragFlower = flowers.value.find(x => x.id === dragId)
		let dragIndex = flowers.value.findIndex(x => x.id === dragId)
		let dropIndex = flowers.value.findIndex(x => x.id === dropId)
		flowers.value.splice(dragIndex, 1);
		flowers.value.splice(dropIndex, 0, dragFlower);
	}
```
