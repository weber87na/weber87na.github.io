---
title: openlayers 7 helloworld
date: 2022-11-07 19:44:59
tags: 
- GIS
- openlayer
- typescript
---

&nbsp;
<!-- more -->

最近因為 angular 的關係 , 要練練 typescript 想說從以前的跑龍套的美食地圖下手
因為太久沒搞 openlayers 了 , 發現官方 example 換成 [vite](https://cn.vitejs.dev/guide/features.html#web-workers) 還好要蓋個 helloworld 算是簡單
```
npm create vite@latest
#Project name: » example
#? Select a framework: » - Use arrow-keys. Return to submit.
#>   Vanilla
#? Select a variant: » - Use arrow-keys. Return to submit.
#    JavaScript
#>   TypeScript

cd example
npm install
npm install ol
```

`package.json`
```
{
    "name": "test",
    "private": true,
    "version": "0.0.0",
    "type": "module",
    "scripts": {
        "dev": "vite",
        "build": "tsc && vite build",
        "preview": "vite preview"
    },
    "devDependencies": {
        "typescript": "^4.6.4",
        "vite": "^3.2.0"
    },
    "dependencies": {
        "ol": "^7.1.0"
    }
}
```

`tsconfig.json`
這裡有把 `noUnusedLocals` `noUnusedParameters` 設定為 `false` 防止 declare 錯誤
```
{
    "compilerOptions": {
        "target": "ESNext",
        "useDefineForClassFields": true,
        "module": "ESNext",
        "lib": [
            "ESNext",
            "DOM"
        ],
        "moduleResolution": "Node",
        "strict": true,
        "resolveJsonModule": true,
        "isolatedModules": true,
        "esModuleInterop": true,
        "noEmit": true,
        // "noUnusedLocals": true,
        // "noUnusedParameters": true,
        "noUnusedLocals": false,
        "noUnusedParameters": false,
        "noImplicitReturns": true,
        "skipLibCheck": true
    },
    "include": [
        "src"
    ]
}
```

`main.ts`
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

`style.css`
```
@import url('/node_modules/ol/ol.css');

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
    <!-- <link rel="stylesheet" href="node_modules/ol/ol.css"> -->
    <title>Using OpenLayers with Vite</title>
</head>

<body>
    <div id="map"></div>
    <script type="module"
        src="/src/main.ts"></script>
</body>

</html>
```


`vite.config.js`
加這個可以讓 ip 對外 , 詳細還沒研究
```
export default ({
    server: {
        host: '0.0.0.0'
    }
})
```


執行 , 另外如果要 Debug 的話 , 選擇 Debug URL 就可以進中斷點了
```
npm run dev
```

打包會在 `dist` 底下出現相對應的資料夾
```
npm run build
```


接著嘗試把我之前奇怪美食地圖的功能搬上來看看 , 先在 `public` 資料夾底下新增 `data` `img` 等資源
接著在 `src` 加入 `attractions.ts` 然後 export geojson 資源看看
```
export const attractions = {
    "type": "FeatureCollection",
	    "features": [
        {
            "type": "Feature",
            "properties": { "Name": "林老師卡好咖啡" },
            "geometry": { "type": "Point", "coordinates": [120.6817005, 22.9100108] }
        },
        {
            "type": "Feature",
            "properties": { "Name": "蛋黃酥冰" },
            "geometry": { "type": "Point", "coordinates": [120.4594596, 23.1247144] }
        },
        {
            "type": "Feature",
            "properties": { "Name": "台灣豬隊友" },
            "geometry": { "type": "Point", "coordinates": [120.3314311, 22.6418476] }
        },
		]
}
```

最後改 `main.ts` 就整個搞好了 , 低能兒也可以跟上前端 XD  , 不過搬起來還是跟 angular 有一點點差異
```
import './style.css';

import 'ol/ol.css';
import Map from 'ol/Map';
import View from 'ol/View';
import { OSM } from 'ol/source';
import TileLayer from 'ol/layer/Tile';
import GeoJSON from 'ol/format/GeoJSON';
import VectorSource from 'ol/source/Vector';
import { Fill, Icon, Stroke, Style, Text } from 'ol/style';
import { getBottomLeft, getHeight, getWidth } from 'ol/extent';
import { toContext } from 'ol/render';
import VectorLayer from 'ol/layer/Vector';
import XYZ from 'ol/source/XYZ'
import { Control, defaults as defaultControls } from 'ol/control';
import { Size } from 'ol/size';
import { Feature } from 'ol';
import { Geometry } from 'ol/geom';
import { FeatureLike } from 'ol/Feature';
import { attractions } from './attractions';


//定義基本底圖
let baseLayerUrl = 'https://wmts.nlsc.gov.tw/wmts/EMAP/default/GoogleMapsCompatible/{z}/{y}/{x}.png'

//osm
//baseLayerUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'
let baseLayer = new TileLayer({
    source: new XYZ({
        url: baseLayerUrl,
    })
});

//osm
let osmLayer = new TileLayer({
    source: new OSM(),
})

//樣式
let twLayerStyles: Array<Style> = []


//景點圖層
let attractionsLayer = new VectorLayer({
    source: new VectorSource({
        format: new GeoJSON(),
        features: new GeoJSON().readFeatures(attractions)
        //url: './data/attractions.geojson'
    }),

    style: feature => {
        return genStyle(feature)
    },
});

//地圖
const map = new Map({
    controls: defaultControls({
        attribution: false,
        zoom: false,
        rotate: false
    }).extend([

    ]),
    // layers: this.layers,
    layers: [
        baseLayer,
        attractionsLayer
    ],
    target: 'map',
    view: new View({
        projection: 'EPSG:4326',
        center: [120.4553, 22.873],
        zoom: 11,
        maxZoom: 18,
    }),
});


// 縮放 icon
function scaleAttractionsIcon(map: Map) {
    var zoom = map.getView().getZoom();

    if (zoom === undefined) return 1

    if (zoom == 9) {
        return 0.4;
    }

    if (zoom < 9) {
        return 0.2;
    }

    return 1;
}

// icon 圖片
function setIconSrc(feature: FeatureLike): string {
    var name = feature.getProperties()['Name'];
    console.log(name);
    return `img/attractions-min/${name}.jpg`;
    // return ''

}


//台灣
let twLayer = new VectorLayer({
    // renderMode: 'image',
    source: new VectorSource({
        format: new GeoJSON(),
        url: 'data/tw.geojson'
    }),
    style: feature => {
        let style: Style
        let countryName = feature.getProperties()['COUNTYNAME'];
        console.log(countryName)

        let isFind = twLayerStyles.some(x => x.getText().getText() === countryName)
        if (isFind) {
            style = twLayerStyles.filter(x => x.getText().getText() === countryName)[0];
            return style
        } else {

            let style = new Style({
                stroke: new Stroke({
                    color: 'rgba(0, 0, 0, 1)',
                    width: 1
                }),
                text: new Text({
                    text: countryName,
                    fill: new Fill({ color: '#000' }),
                    stroke: new Stroke({
                        color: '#FF8800',
                        width: 10
                    }),
                })
            })
            twLayerStyles.push(style)
            return style
        }

    },
});

function scaleAttractionsText(feature: FeatureLike): string | string[] {
    let name = feature.getProperties()['Name']
    return name
}

let styles: Array<Style> = []



function genStyle(feature: FeatureLike) {
    let style: Style;
    // 從 styles 的 cache 裡面找出資料
    let isFind = styles.some(x => {
        return x.getText().getText() === feature.get('Name')
    })
    console.log('isFind', isFind)
    if (isFind) {
        // 如果 styles 的 cache 裡面有資料的話 , 回傳該名稱的樣式
        style = styles.filter(x => {
            return x.getText().getText() === feature.get('Name')
        })[0]
        return style
    } else {
        // 如果沒找到的話新增 style 並且 push 到裡面去 , 最後回傳
        style = new Style({
            image: new Icon(({
                src: setIconSrc(feature),
                scale: scaleAttractionsIcon(map)
            })),
            text: new Text({
                text: scaleAttractionsText(feature),
                fill: new Fill({
                    color: '#000'
                }),
                stroke: new Stroke({
                    color: '#fff',
                    width: 2
                }),
                offsetY: 24
            })
        });
        styles.push(style)
        return style;
    }

}
```


移動
```
setInterval(function () {
    console.log('test')
    let prop = attractionsLayer.getProperties()
    let source = attractionsLayer.getSource();
    let features = source?.getFeatures()
    features?.forEach(feature => {
        let geom = feature.getGeometry() as Point
        let coord = geom.getFlatCoordinates()
        let newCoord = [
            coord[0] += 0.0005,
            coord[1] += 0.0005
        ]
        geom.setCoordinates(newCoord)

    })
    console.log(prop)
    console.log(source)
    console.log(features)
}, 2000)
```


點選
```
map.on('click', function (e) {
    map.forEachFeatureAtPixel(e.pixel, function (feature, layer) {
        //do something
        console.log(feature, layer)
        let prop = feature.getProperties()
        let name = prop['Name']
        console.log(prop)
        modalToggle()
        let img = document.getElementById('img') as HTMLImageElement
        img.src = `img\\${name}.png`

        let geom = feature.getGeometry() as Point
        let pos = document.getElementById('pos')
        let coord = geom.getFlatCoordinates()
        let x = coord[0].toFixed(6)
        let y = coord[0].toFixed(6)
        if(pos){
            pos.textContent = `lon:${x} lat:${y}` 
        }
    })
});
```


modal
```
function modalToggle(): void {
    let modal = document.querySelector('#modal')
    let isShow = modal?.classList.contains('show')
    if (isShow) {
        // modal?.classList.remove('show')
        // modal?.classList.add('hide')
    } else {
        modal?.classList.add('show')
        modal?.classList.remove('hide')
    }
}
```
