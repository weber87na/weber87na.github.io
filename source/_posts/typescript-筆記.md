---
title: typescript 筆記
date: 2022-11-08 18:57:38
tags: typescript
---

&nbsp;
<!-- more -->

### npm 起手
安裝
```
npm install -g typescript
npm install --save-dev tsc-watch
npm install --save-dev eslint

npm install --save ol
```


建立專案
```
npm init --yes
```

新增 `tsconfig.json`
```
{
	"compilerOptions" : {
        "target": "ES2020",
        "outDir": "./dist",
        "rootDir": "./src"
	}
}
```

新增 `dist` , `src` 資料夾
```
mkdir dist
mkdir src
```

在 `src` 底下新增 `index.ts`
```
console.log('hello world')
```

編譯
```
tsc
```

執行
```
node dist/index.js
```

自動監控 & 執行
```
npx tsc-watch --onsuccess "node dist/index.js"
```

`package.json`
```
    "scripts": {
        "test": "echo \"Error: no test specified\" && exit 1",
        "start": "tsc-watch --onsuccess \"node dist/index.js\""
    },
```

### parceljs 打包
打包是件痛苦的事 , 身為後端沒泡在前端裡面的話 , 沒隔半年前端又被更新了 , 等學完打包大概就換自己打包了
受夠了安裝環境就要搞半天的話 , 可以用看看這個 `無腦環境` [parceljs](https://parceljs.org/) , 難度會下降很多
一樣拿 openlayers 測試看看

這裡被雷個 <script `type="module"` 需要移除掉

`index.html`
```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8" />
    <link rel="icon"
        type="image/x-icon"
        href="https://openlayers.org/favicon.ico" />
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0" />
    <title>Using OpenLayers with Vite</title>
</head>

<body>
    <div id="map"></div>
    <script type="module"
        src="./index.ts"></script>
</body>

</html>
```

`style.css`
```
@import "./node_modules/ol/ol.css";

html,
body {
    margin: 0;
    height: 100%;
}

#map {
    position: absolute;
    top: 0;
    bottom: 0;
    width: 100%;
}
```


萬一中間有噴這個 error 的話 , 本來以為很無腦 , 最後還是噴 error , 煩阿 .. 天天都在打包的概念
```
> 1 | @import "node_modules/ol/ol.css";
    | ^
  2 |
  3 | html,
```

只需要把 `@import` 改下前面加個 `.` 就好
```
@import "./node_modules/ol/ol.css";
```

`index.ts`
```
import './style.css';
import { Map, View } from 'ol';
import TileLayer from 'ol/layer/Tile';
import OSM from 'ol/source/OSM';

const map = new Map({
    target: 'map',
    layers: [
        new TileLayer({
            source: new OSM()
        })
    ],
    view: new View({
        center: [0, 0],
        zoom: 2
    })
});
```

最後 run
```
parcel index.html
```
