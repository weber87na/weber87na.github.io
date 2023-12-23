---
title: 折疊 swagger 上面 remarks 補充資訊
date: 2023-02-15 18:56:56
tags: csharp
---
&nbsp;
<!-- more -->

工作上遇到的問題 , 我有一個 api , 裡面有個 post 方法
這個方法接收惡夢的 `JObject` , 然後依照不同型別參數去呼叫內部的實作
本來想說看看能否用 [Swashbuckle.Examples](https://github.com/mattfrear/Swashbuckle.Examples/tree/master/Swashbuckle.Examples) 去解 , 不過研究一陣子發現暫時無解
後來我發現可以用 [remarks](https://stackoverflow.com/questions/59280942/how-to-define-multiple-request-example-for-one-request-object-in-swagger-in-c) 去寫註解豐富範例
因為我有 `6 x 6` 36 個類型要寫範例 , 如果全部插在 api 上面只能說讀起來噁心 , 所以研究看看怎麼折疊 `remarks`

首先在 `EnableSwaggerUi` 找到 `InjectJavaScript` 開啟註解
```
c.InjectJavaScript(thisAssembly, "yourjs.js");
```
接著在 `Script` 資料夾加入 `yourjs.js` 記得要設定 `Embedded Resource` 不然吃不到

然後學在 api method 老外打上註解
```
///<remarks>
/// First Schema:
///
///     GET /Todo
///     {
///         "flatId": "62a05ac8-f131-44c1-8e48-f23744289e55",
///         "name": "Name",
///         "surname": "Surname",
///         "personalCode": "12345",
///         "dateOfBirth": "2020-03-30T00:00:00",
///         "phoneNumber": "+37122345678",
///         "email": "email@mail.com"
///     }
///
/// Second Schema:
///
///     GET /Todo
///     {
///         "name": "Name",
///         "surname": "Surname",
///         "personalCode": "12345",
///         "dateOfBirth": "2020-03-30T00:00:00",
///         "phoneNumber": "+37122345678",
///         "email": "email@mail.com"
///     }
///
/// </remarks>
```

實際上解析出來會長這樣的結構
```
<div class="markdown">
	<pSecond Schema</p>
	<pre>
		<code>xxxxxxxx</code>
	</pre>
</div>
```


接著開始補 js , 這樣一來就可以摺疊了 , api 看起來也比較整潔 , 其他細部怎麼設定產 xml 網路上有一堆我就爛得寫啦 XD
```
//取得 markdown 裡面的 p (asus jaguar 等說明 title)
var titles = document.querySelectorAll('.markdown p')
titles.forEach(function (title) {
    console.log(title)
    title.addEventListener('click', function () {
        //取得下個子項目
        var pre = title.nextElementSibling
        if (pre.getAttribute('style') === null || pre.getAttribute('style') === 'display: none')
            pre.setAttribute('style', 'display: block');
        else {
            pre.setAttribute('style', 'display: none');
        }

    })
})
```

後來懶得每次都手動複製很累 , 所以補個偽元素按鈕想說可以吃 click event 沒想到不行
看老外先把主體的 `pointer-events` 關了 , 然後開啟 `before or after` 的 `pointer-events` 就可以模擬這個效果
``` css
/*
    他先關掉父元素的事件 , 這樣就可以模擬偽元素被 click 才觸發這個 event 本例拿來複製 json 測試碼
    https://stackoverflow.com/questions/9395858/event-listener-on-a-css-pseudo-element-such-as-after-and-before
*/
.markdown pre code { pointer-events: none; }
.markdown pre code::before { pointer-events: all; }

/* 定位基準要開相對 */
.markdown code {
    position: relative;
}
/* 設定複製假按鈕 */
.markdown pre code::before {
    width: 40px;
    height: 40px;
    content: '📋';
    position: absolute;
    top: 10px;
    right: 10px;
    font-size: 30px;
    line-height: 40px;
    cursor: pointer;
}
/* 設定 click 打勾 */
.markdown pre code:active::before{
    content: '✔️';
}

```

`js`
``` js
//建立複製事件
var codes = document.querySelectorAll('.markdown pre code')
codes.forEach(function(code) {
	code.addEventListener('click', function () {
		var testJson = code.innerText;
		console.log(testJson);
        navigator.clipboard.writeText(testJson);
	});
});
```
