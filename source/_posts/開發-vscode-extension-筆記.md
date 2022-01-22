---
title: 開發 vscode extension 筆記
date: 2022-01-22 02:02:09
tags: vscode
---
&nbsp;
<!-- more -->

這篇算是我第一個 vscode extension [假的](https://marketplace.visualstudio.com/items?itemName=weber87na.tw-fake-data-gen) 開發筆記 , [github在此](https://github.com/weber87na/tw-fake-data-gen)
![假的](https://raw.githubusercontent.com/weber87na/tw-fake-data-gen/main/images/fake128x128.jpg)
因為自己常常需要搞些假資料 , 雖然網路上生成方式百百種 , 但多半是符合老外習慣 , 用起來也不太方便
所以研究看看有無可能像是 `emmet` 那樣快速產生一些指令 , 解決這個萬年不變的常見問題

### hello world
首先看這篇去做 [hello world](https://code.visualstudio.com/api/get-started/your-first-extension) , 基本上沒啥困難 , 他會幫你蓋好手腳架 , 按 `f5` 就可以 debug 了
另外官方有提供這個很有用的 [sample code 大全](https://github.com/microsoft/vscode-extension-samples) 想做啥就靠這包

```
npm install -g yo generator-code
```

### 進入點的坑
`hello world` 預設會讓你是要啟動那個 `command` 才會 `trigger` 命令 , 一定要改成自己需要的觸發點 , 我是製作 `completions` , 所以調整成類似以下這樣就可以正常觸發
`package.json`
```
"activationEvents": [
	"onLanguage:typescript",
	"onLanguage:javascript",
	"onLanguage:html"
],
```

### 多語言的坑
起初我以為會在所有語言去觸發動作 , 雷了一陣子後發現要手動定義想要啥語言 , 注意每個語言要分開做 , 官方範例是 `plaintext` , 我這邊自己定義想要的語言為 `html` , `javascript` , `typescript`
```
export function activate(context: vscode.ExtensionContext) {

    const langs = ['html', 'javascript', 'typescript']
    langs.forEach(lang => {

        const provider = vscode.languages.registerCompletionItemProvider(lang , {

                provideCompletionItems(document: vscode.TextDocument, position: vscode.Position, token: vscode.CancellationToken, context: vscode.CompletionContext) {

					const chineseNameCompletion = genChineseName('fcname');

                    // return all completion items as array
                    return [
                        chineseNameCompletion
                    ];
                }
            });

        context.subscriptions.push(provider);
    })

```

### turfjs 的坑
以前在用 postgresql 我常常會用空間查詢去生出台灣亂數點位 , 這個問題在其他程式語言上則變成一件麻煩事 , 所以我找到了 [turfjs](https://turfjs.org/) 來解這個問題
本來以為這個 lib 可以直接從 geojson 生出亂數點位 , 沒想到還要加工一翻
所以我先亂數讀取台灣隨機縣市的 geojson , 接著取得 bbox , 再用他現成從 bbox 生出亂數點位的函數 `turf.randomPoint` 撈出結果
最後用 `turf.booleanContains` 這個好像有順序性 point 要放後面的樣子 , 研判這個點位是否有跳海 , 沒的話才 return

```
function randomPoint() {
    try {
        //亂數取得某個縣市
        let randomFeature = taiwan.features[Math.floor(Math.random() * taiwan.features.length)];

        //取得該縣市的 bbox , 不曉得為啥直接呼叫 bbox 產出來是錯的
        var bbox = turf.bbox(randomFeature);

        //產生一個亂數點
        var positions = turf.randomPoint(1, { bbox: bbox })

        //判斷該點是否在亂數縣市的 geomerty 範圍裡面
        let flag = turf.booleanContains(randomFeature, positions.features[0]);

        if (flag) {
            return positions.features[0].geometry.coordinates;
        }

        //萬一點跳海的話遞迴重新執行一次
        // randomPoint();

        //改成直接回傳已經 cache 的點
        return randomPoints[Math.floor(Math.random() * randomPoints.length)];

    } catch (error) {
        console.log(error);
    }
}
```

### 發佈
主要參考[這篇教學](https://itnext.io/creating-and-publishing-vs-code-extensions-912b5b8b529)
首先安裝 `vsce`
```
npm install -g vsce
```

打包執行以下命令 , 印象中要把 `readme` 的 template 改成你的內容 , 不然會跳錯誤 , 另外想要有 icon 的話好像要 128x128 大小
```
vsce package
```

最後是 `nodejs` 的坑 , 因為我有引用 `turfjs`, 本來以為有在 `devDependencies` 或 `dependencies` 設定相依就好了
雷了半天才發現原來開發期間要設定 `devDependencies` , 打包給人用要設定 `dependencies` , 所以兩個都要設定 XD
ps:如果從 git clone 下來別人的 extension 話要記得執行 `npm install`
```
    "devDependencies": {
        "@turf/turf": "^6.5.0",
        "@types/geojson": "^7946.0.8",
        "@types/glob": "^7.2.0",
        "@types/mocha": "^9.0.0",
        "@types/node": "14.x",
        "@types/vscode": "^1.63.0",
        "@typescript-eslint/eslint-plugin": "^5.9.1",
        "@typescript-eslint/parser": "^5.9.1",
        "@vscode/test-electron": "^2.0.3",
        "eslint": "^8.6.0",
        "glob": "^7.2.0",
        "mocha": "^9.1.3",
        "typescript": "^4.5.4"
    },
    "dependencies": {
        "@turf/turf": "^6.5.0"
    },
```

當以上坑都走過一次就會送你一個類似這樣的檔案 `你外掛名稱-0.0.3.vsix` 然後到 vscode 按下 `ctrl + shift + p` 呼叫指令 VSIX 就可以成功安裝
剩下就是些 `package.json` 的詳細設定 , 可以參考以下
```
    "name": "你的名稱必須是英文",
    "displayName": "當你用 vscode 搜尋 extension 時的名稱",
    "description": "你的 extension 描述",
    "version": "0.0.5",
    "publisher": "你的名稱",
    "homepage": "https://github.com/yourname/extension-repository",
    "repository": {
        "type": "git",
        "url": "https://github.com/yourname/extension-repository"
    },
    "bugs": {
        "url": "https://github.com/yourname/extension-repository/issues"
    },
    "engines": {
		//相依的 vscode 版本
        "vscode": "^1.63.0"
    },
    "license": "MIT",
    "categories": [
        "Other"
    ],
```

如果想要發佈到 `visualstudio marketplace` 可以點[這裡](https://marketplace.visualstudio.com/) 接著點 `Publish extensions` , 他會要你登入 marketplace , 連結你的帳號跟 github 即可
接著點 `New Extension` 選擇剛剛的 extension `你外掛名稱-0.0.3.vsix` , 驗證一陣子即可上架成功!
