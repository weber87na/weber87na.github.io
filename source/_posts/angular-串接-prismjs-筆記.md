---
title: angular 串接 prismjs 筆記
date: 2024-11-07 12:27:20
tags: angular
---
&nbsp;
<!-- more -->

工作上遇到的問題, 因為有好幾個雷, 算是一個複合問題, 可能都遇過, 但一次全來還有點不知所云, 就獨立一篇記錄下

首先無腦安裝

```
npm install prismjs
```

設定 `angular.json` 這裡要把有使用到的 plugin 也加進去, 不然不會動

```
"styles": [
  "@angular/material/prebuilt-themes/indigo-pink.css",
  "node_modules/ngx-toastr/toastr.css",
  "node_modules/ngx-spinner/animations/ball-spin.css",
  "node_modules/ztree/css/zTreeStyle/zTreeStyle.css",
  "node_modules/prismjs/themes/prism.css",
  "node_modules/prismjs/plugins/line-numbers/prism-line-numbers.css",
  "node_modules/prismjs/plugins/toolbar/prism-toolbar.css",
  "src/styles.css"
],
"scripts": [
  "node_modules/jquery/dist/jquery.min.js",
  "node_modules/jquery-ui/dist/jquery-ui.js",
  "node_modules/ztree/js/jquery.ztree.all.js",
  "node_modules/ztree/js/jquery.ztree.exhide.js",
  "node_modules/prismjs/prism.js",
  "node_modules/prismjs/plugins/copy-to-clipboard/prism-copy-to-clipboard.js",
  "node_modules/prismjs/plugins/line-numbers/prism-line-numbers.js",
  "node_modules/prismjs/plugins/toolbar/prism-toolbar.js"
]
```

`componnet` 這邊一樣要引用有使用到的 plugin, 接著宣告 Prism 變數 `declare const Prism: any` 就能動了

```
import 'prismjs';

import 'prismjs/plugins/toolbar/prism-toolbar';

import 'prismjs/plugins/copy-to-clipboard/prism-copy-to-clipboard';
import 'prismjs/plugins/line-numbers/prism-line-numbers';
import 'prismjs/plugins/show-language/prism-show-language';

import 'prismjs/components/prism-json';

declare const Prism: any;
```

我自己因為要上傳 `json` 檔案, html 大概長這樣
同時設定 `id` 還有範本參考變數 `#fileInput #code` 方便後續操作

```
<input
	#fileInput
	id="file"
	type="file"
	name="formFile"
	accept=".json,.txt"
	(change)="fileChange($event)"
/>

<pre><code #code id="code" class="language-json line-numbers">[]</code></pre>
```


接著看到 `fileChange` 當觸發 `change` 事件時他便會讀取檔案
若為原生 js 只需在 `FileReader onload` 寫上要觸發的 function 就可以了
但 angular 是包成類別導致 scope 涵義不同, 所以要用 `bind(this)` 這樣才能正確觸發事件

```
fileChange(event: any) {
	console.log('fileChange', event);
	let reader = new FileReader();
	//重點
	reader.onload = this.onReaderLoad.bind(this);
	reader.readAsText(event.target.files[0]);
}

//用 prismjs 讓樣式變好看
onReaderLoad(event: any){
	let text = event.target.result;
	//參考自此
	//https://stackoverflow.com/questions/59508413/static-html-generation-with-prismjs-how-to-enable-line-numbers
	var NEW_LINE_EXP = /\n(?!$)/g;
	var lineNumbersWrapper;

	Prism.hooks.add('after-tokenize', function (env: any) {
		var match = env.code.match(NEW_LINE_EXP);
		var linesNum = match ? match.length + 1 : 1;
		var lines = new Array(linesNum + 1).join('<span></span>');

		lineNumbersWrapper = `<span aria-hidden="true" class="line-numbers-rows">${lines}</span>`;
	});

	const html = Prism.highlight(text, Prism.languages.json, 'json');

	this.code.innerHTML = html + lineNumbersWrapper;
}
```

最後一個重點則是拿 element 時要記得 `implements AfterViewInit` 然後寫在 `ngAfterViewInit` 裡面

```
export class JsonUploadComponent implements OnInit, AfterViewInit {
	@ViewChild('fileInput') fileInputRef!: ElementRef;
	fileInput!: HTMLInputElement;
	@ViewChild('code') codeRef!: ElementRef;
	code!: HTMLElement;  

	ngAfterViewInit(): void {
		this.fileInput = this.fileInputRef.nativeElement;
		this.code = this.codeRef.nativeElement;
		//其他咚咚
	}
```
