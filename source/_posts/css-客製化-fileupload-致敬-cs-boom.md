---
title: css 客製化 fileupload 致敬 cs boom
date: 2024-06-26 23:29:50
tags: css
---

<p class="codepen" data-height="300" data-default-tab="result" data-slug-hash="pomLqEG" data-pen-title="cs boom file upload" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/pomLqEG">
  cs boom file upload</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://public.codepenassets.com/embed/index.js"></script>

<!-- more -->

最近接個 `fileupload` 的需求, 需要上傳 json, 印象中好像搞過 3 ~ 4 次這個功能, 也沒個留紀錄, 趁假日順手自己搞個玩玩
常常看網路上很多酷炫的 `fileupload` 研究下發現他精隨沒兩句

首先定義 input 及 label
這裡精隨就是要把 `label` 設定 `for` 讓他點下去可以觸發 `input`

```html
<label for="uploadboom" id="btn-uploadboom" class="screen">7355608</label>

<!-- 其他 code -->
<input type="file" id="uploadboom" name="uploadboom">
```

接著寫 css 的障眼法, 直接把本來的 `input` 隱藏起來即可, 其他就看自己創意啦 ~

```css
#uploadboom {
	position: absolute;
	top: 0;
	display: none;
}
```

至於 js 上傳大概又可以分兩種模式使用 `form` 或直接丟 json 上去
我這裡因為偷懶想要與先前 asp.net core 的 api 保持一致性, 所以先在前端 `input` 發生 `change` 事件直接把檔案讀出來, 然後當觸發 `reader.onload` 事件時則丟上去
可以參考 stackoverflow [這個做法](https://stackoverflow.com/questions/38763995/javascript-handling-image-loading-event-target-result-is-empty)

```js
let fileIput = document.querySelector('#file');

fileIput.addEventListener('change', (event) => {
	let reader = new FileReader();
	reader.onload = onReaderLoad;
	reader.readAsText(event.target.files[0]);
});

async function onReaderLoad(event) {
	let text = event.target.result;
}
```

最後發現 `change` 事件會有個問題, 如果 user 又點選相同檔案的話, 事件就不會觸發了, 所以可以用以下方法來重置

```
fileIput.value = ''
```
