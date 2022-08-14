---
title: angularjs 1.8 串接 Prismjs & jsPanel
date: 2022-04-02 11:29:44
tags: angularjs
---
&nbsp;
<!-- more -->

### prismjs
這套好像是 wordpress 在用的 , 除了這套以外還有 [highlightjs](https://highlightjs.org/) 可以玩看看
因為希望可以看到異動過後的屬性 , 並且可以快速複製 , 比較下這套 prismjs 功能好像更強
所以選了這幾個 plugin `Show Language` , `Line Numbers` , `Toolbar` , `Copy to Clipboard Button` plugin
```
https://prismjs.com/download.html#themes=prism&languages=markup+css+clike+javascript+json&plugins=line-numbers+show-language+toolbar+copy-to-clipboard
```

由於是老案子 , 所以手動安裝
```
<script src="@Url.Content("~/Scripts/prism/prism.js")"></script>
<link href="@Url.Content("~/Scripts/prism/prism.css")" rel="stylesheet" />
```

然後可以自己試看看有無辦法動起來
`html`
```
<pre lang="zh-Hans-Tw"
	data-prismjs-copy="複製"
	data-prismjs-copy-error="按Ctrl+C複製"
	data-prismjs-copy-success="文字已複製"><code id="test" class="language-json"></code>
</pre>
```

另外這個 html 有個雷要注意下 , 如果你把 `<code id="test" class="language-json"></code>` 這個片段換行的話 , 會觸發經典問題幽靈空白節點
這裡會讓 format 跑掉 , 需要多加留意
```
<pre lang="zh-Hans-Tw"
	data-prismjs-copy="複製"
	data-prismjs-copy-error="按Ctrl+C複製"
	data-prismjs-copy-success="文字已複製">
	<code id="test" class="language-json"></code>
</pre>
```

`js`
```
// The code snippet you want to highlight, as a string
const code = { name : 'haha' , age : 18};


// Returns a highlighted HTML string
const html = Prism.highlight( JSON.stringify(code, null, '\t') , Prism.languages.json, 'json');

var test = document.getElementById('test');
test.innerHTML = html;
```


礙於 `angularjs` 沒辦法直接解析 html , 所以需要在 filter 加上這些 code
```
var app = angular.module('app', ['ngRoute']);
app.filter('safeHtml', function ($sce) {
	return function (val) {
		return $sce.trustAsHtml(val);
	};
});

```

### jsPanel
這套 [jsPanel](https://jspanel.de/) 已經不知不覺來到 v4 , 而且現在用純 js 去實作 , 所以使用上也滿方便
首先定義 `showCode` 這個 function 等等用來回傳 code

```
function showCode(){
	var code = { name : 'haha' , age : 18};
	// Returns a highlighted HTML string
	var html = Prism.highlight( JSON.stringify(code, null, '\t') , Prism.languages.json, 'json');
	return html;
}

```

接著這裡要串 angularjs 可以參考這個[印度人](https://stackoverflow.com/questions/51647839/how-to-use-jspanel4-with-angular-1-x/51695330#51695330)
我因為是在 controller 裡面 , 所以狀況不太一樣
另外要解析 html 可以參考[這篇](https://stackoverflow.com/questions/19415394/with-ng-bind-html-unsafe-removed-how-do-i-inject-html)
設定好以後就可以在 `content` 裡面用 binding 或是 bind-html , 先前在 prismjs 那個部分已經設定 filter , 他可以幫忙解析成 html , 所以可以類似這樣寫 `ng-bind-html="showCode() | safeHtml"`
```
app.controller('ParentController', ['$window', "$scope", "$timeout", 'yourService', '$compile',
    function ($window, $scope, $timeout, yourService, $compile, $rootScope) {


        var thePanel = jsPanel.create({

            id: 'code-panel',

            headerControls: {
                //minimize: 'disable',
                //smallify: 'remove',
                close: 'remove'
            },
            theme: 'primary',
            headerTitle: 'code',
            setStatus: 'minimized',
            content:
`
    <pre lang="zh-Hans-Tw"
        data-prismjs-copy="複製"
        data-prismjs-copy-error="按Ctrl+C附註"
        data-prismjs-copy-success="文字已複製"><code id="test" class="language-json" ng-bind-html="showCode() | safeHtml"></code>
    </pre>
`,

            callback: panelCalback
        });
        console.log(thePanel)

        function panelCalback() {
            //1- convert to angular element
            var element = angular.element(this.content);

            // 2- compile the element
            var link = $compile(element);

            // 3- create panel controller
            var wbFloat = {
                hide: function (response) {
                    panel.close();
                    deferred.resolve(response);
                },
                cancel: function (response) {
                    panel.close();
                    deferred.reject(response);
                }
            };

            //4- load controller
            var childScope = $scope.$new(false, $scope);
            console.log(childScope);

            app.controller('yourController', {
                $scope: childScope,
                $element: element,
                $wbFloat: wbFloat
            })
            link(childScope);
        }
	
	
}
```
