---
title: 開發 chrome extension 筆記
date: 2022-12-28 19:09:44
tags:
- chrome
- js
---
&nbsp;
<!-- more -->
因為長期很火大一個功能 , 每次 pdf 開起來都是 400x400 , 偏偏又很常用 , 所以寫看看 extension
整個過程還算無腦 , 筆記下 , 如果懶得寫 extension 可以直接用[書籤](https://www.blog.lasai.com.tw/2020/11/21/chrome-%E5%BB%BA%E7%AB%8B%E6%9C%89-js-%E7%9A%84%E6%9B%B8%E7%B1%A4/)的方式 , 不過每次都還要多點一下書籤還是滿麻煩
```
mkdir portal-killer
cd portal-killer
npm init --yes
npm install --save @types/chrome
mkdir scripts
touch scripts/content.js
touch manifest.json
```

加入以下內容 `manifest.json` , 特別注意 `matches` 的網址請帶星號讓整個網站生效
``` json
{
    "manifest_version": 2,
    "name": "Portal Killer",
    "description": "賭爛每次 PDF 都是 400x400 大小",
    "version": "1.0",
    "content_scripts": [
        {
            "js": [
                "scripts/content.js"
            ],
            "matches": [
                "http://ladisai.xxx.gy/portal/*"
            ]
        }
    ]
}
```

接著寫 code , 這裡搞了一陣子本來以為可以直接拿到這個網站的 function
沒想到好像沒辦法 , 可能我沒找到 , 所以用插入 script 的方式去達成
先撈出 function , 接著 `toString` , 得到程式碼 , 最後 replace 複寫要修改的的方
最後用 eval 讓程式碼生效即可
``` js
console.log('Portal Killer is work');
(function () {
    var element = document.createElement('script');
    element.type = "text/javascript";
    element.innerText = `
        console.log(document.scripts);
        OPENFILE.toString();
        var text = OPENFILE.toString();
        var fullSizeOPENFILE = text.replace(',"Scrollbars=1,resizable=1,width=400,height=440"', ' ');
        eval(fullSizeOPENFILE);
        console.log('PDF Size is fix');
    `
    document.body.appendChild(element);
}());
```

最後開啟 chrome 打入以下網址 `chrome://extensions/`
`開啟開發人員模式` => `載入未封裝項目` => 選擇資料夾 `portal-killer` 即可搞定
