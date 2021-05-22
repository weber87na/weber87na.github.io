---
title: asp.net mvc 翻修多語系筆記
date: 2021-03-03 18:41:54
tags:
- asp.net mvc
---
&nbsp;
<!-- more -->

### 內文
最近遇到要把整個 website 改為多語系 , 在 .net 裡面多語系是使用 .resx 當做字典檔進行編輯 , 如果用手動的話大概會編到昏倒
用 grep 查詢符合 span 內的文字將他 copy 起來進行額外處理 , 注意引號的 escape 是反協線
``` bash
grep -E "<span class=\"input-group-text w-100\">.*</span>"  _YourPage.cshtml
or
grep ng-model _YourPage.html
```
ps: 如果需要將繁體中文翻譯成簡體中文可以用這個 [OpenCC-NET](https://github.com/saviorxzero98/OpenCC-NET) 基本上打開他附贈的 example 再加點工讀取 resx 檔案就可以了

將處理過的文字以 js 的製作出多語系的 template , 接著手動新增 value 內的內容就搞定了 , 如果運氣好有跟 span 成對的話也可以直接塞 span , 注意直接編輯 .resx visual studio 是不會直接更新內容的 , 可以隨變新增個 A 然後再刪除 , visual studio 就會觸發 .resx format 的動作
``` javascript
for(var i = 0; i < keys.length; i++){
	var k = keys[i];
	var template = 
	`<data name="${k}" xml:space="preserve">
		<value></value>
	</data>`;
	result.push(template);
	console.log(template);
}
copy(result)
```

由於我這邊剛好是重構老舊架構用的是 angularjs 因此可以用 vim 錄製巨集以下是我的 html 片段
``` html
<div class="input-group mb-3">
	<div class="input-group-prepend w-40">
		<span class="input-group-text w-100">test</span>
	</div>
	<input type="number"
		name="gg"
		class="form-control"
		ng-model="gg.gg"
		/>
</div>
```

vim 移動步驟大概如下片段
```
搜尋 ng-model
/ng-model

搜尋最後一個雙引號
f";

到退複製一個單字
bviwy

往上找span
?span<C-R>

貼上剛剛複製的屬性 , 並加上 @MULTILANG 的 c# 語法
vitpbi@MULTILANG.<ESC>

結束錄製
0q

播放其他類似的 html 片段
@q
```

完成後的樣子
``` html
<div class="input-group mb-3">
	<div class="input-group-prepend w-40">
		<span class="input-group-text w-100">@MULTILANG.gg</span>
	</div>
	<input type="number"
		name="gg"
		class="form-control"
		ng-model="gg.gg"
		/>
</div>
```

順帶一提可以在 vscode 設定 settings.json 讓 html attribute 換行 , 順手重構老系統
```
"html.format.wrapAttributes": "force",
```

後來翻修還遇到兩個問題一個就是 bootstrap 討人厭的 href 錨點會讓網址很醜 , 可以用 data-target 重構
before
```
<a class="nav-link" data-toggle="tab" href="#ooxx" >ooxx</a>
```
after
```
<a class="nav-link" data-toggle="tab" data-target="ooxx" href="javascript:;" >
```

另外前端遇到 angularjs 載入靜態頁面可以這樣寫 , 讓後端去從真正的 server 路徑取得檔案位置 , 並且幫忙加時間防止 cached
```
<ng-include src="'@Url.Content("~/Static/YourPage.html?v=" + DateTime.Now.ToFileTimeUtc())'"></ng-include>
```
後來發現老系統一個雷坑 , 理論上 label 裡面包 checkbox 會可以點到才對 , 結果寫成下面這樣爆炸了 , 多了一個 `for=""`
```
<label for="">
	<input type="checkbox" ng-model="dataValue">
		Set the Data Value
</label>
```
應該寫這樣
```
<label>
	<input type="checkbox" ng-model="dataValue">
		Set the Data Value
</label>
```

或是用 id 跟 for 建立關連
```
<input type="checkbox" name="travel" id="japan">
<label for="japan">日本</label>
```

img 跟 a 標籤常見的包法
```
<a href="www.google.com.tw">
	<img src="sakura.jpg" alt="">
</a>
```

防止 css 中文亂碼
```
@charset 'UTF-8';
```

因為常常前端寫完來不及給後端 , 畫面三不五時就 cache , 參考[老外](https://wpreset.com/force-reload-cached-css/)可以用以下片段讓 js , css 用前端暴力法不被 cached
```
//強制讓 css 不進行 cache
(function () {
	 var h, a, f;
	 a = document.getElementsByTagName('link');
	 for (h = 0; h < a.length; h++) {
		 f = a[h];
		 if (f.rel.toLowerCase().match(/stylesheet/) && f.href) {
			 var g = f.href.replace(/(&|\?)rnd=\d+/, '');
			 f.href = g + (g.match(/\?/) ? '&' : '?');
			 f.href += 'rnd=' + (new Date().valueOf());
		 }
	 } // for
 })();

//強制讓 js 不進行 cache
(function () {
	 var h, a, f;
	 a = document.getElementsByTagName('script');
	 for (h = 0; h < a.length; h++) {
		 f = a[h];
		 //console.log(f);
		 if (f.src) {
			 var g = f.src.replace(/(&|\?)rnd=\d+/, '');
			 f.src = g + (g.match(/\?/) ? '&' : '?');
			 f.src += 'rnd=' + (new Date().valueOf());
		 }
	 } // for
 })();

```
