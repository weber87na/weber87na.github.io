---
title: jsdoc 筆記
date: 2023-10-28 06:25:57
tags: js
---
&nbsp;
<!-- more -->

工作上因為維護 asp.net mvc 的關係 , 前後分離大概只做了一半 , visual studio 對 js 的支援也不是特優
所以有一狗票 angularjs 的 function 大約 70 個左右 , 但是又無法文件化來說明 , 每次看完 code 也就忘得差不多
苦無解決方法 , 這次剛好有空就加減處理看看

### jsdoc
首先安裝 jsdoc 
用法大致如下
 一次也支援多個 js
```
npm install -g jsdoc
mkdir jsdoc-test
cd jsdoc-test
jsdoc "D:\helloworld.js"
jsdoc "D:\helloworld.js" "D:\helloworld2.js"
```

### jsdoc 寫法範例
因為我是維護古蹟 angularjs 就拿他當範例
首先找到 controller 定義為類別
接著定義 property 設定 @link 即可跳到你的 function or property 上
這裡如果你的 function or property 很多的話 , 開頭會很長
```
/**
 * @name OXController
 * @class OXController
 * @property {number} status {@link OXController#status}
 * @property {function} findOX {@link OXController#findOX}
 * @description OX 的 controller
 */
app.controller('OXController', ['$window', "$scope"]
    function ($window, $scope) {
        //內部程式碼
    }
)
```

接著找到想要補文件的 function 如下加上 jsdoc 定義即可 , 產生完後他會出現在 Mehods 分類裡
```
/**
* @function OXController#findOX
* @description 找到 OX 元素
* @param {HTMLElement} el 某個 tab 底下的 element
* @returns {null|HTMLElement} 找到的 OX 元素
*/
function findOX(el) {
    while (el.parentElement) {
        el = el.parentElement;
        if (el.dataset.ox !== undefined)
            return el.dataset.ox;
    }
    return null;
}

```

若要設定 `property` 定義方法則如下所示, 產生完後他會出現在 `Members` 分類裡
``` js
/**
* @name OXController#status
* @type {number}
* @description 篩選 OX 的狀態 <br/>
* 0 => O <br/>
* 1 => X <br/>
* 2 => 其他
*/
$scope.status = 0;
```


### jsdoc-to-markdown
後來發現一個好物可以直接變成 markdown , 這樣整合到內部的 gitlab 就很方便
首先安裝 [jsdoc-to-markdown](https://www.npmjs.com/package/jsdoc-to-markdown) 這裡就直接安裝成全域的
```
npm i -g jsdoc-to-markdown
```

接著可以用 powershell 印看看效果
``` powershell
jsdoc2md "D:\Scripts\helloworld.js"
```

然後想要輸出到其他檔案時 , 悲劇就發生啦 , 中文內容變成亂碼
```
jsdoc2md "D:\Scripts\helloworld.js" > helloworld.md
```

折磨了很久以後發現這篇[解法](https://www.thinkinmd.com/post/2020/02/21/command-prompt-and-windows-powershell-default-use-utf-8/)
我自己試起來只要先設定下面幾個變數為 UTF8 就會正常
```
$OutputEncoding = [console]::InputEncoding = [console]::OutputEncoding = [Text.UTF8Encoding]::UTF8
jsdoc2md "D:\Scripts\helloworld.js" > helloworld.md
```
