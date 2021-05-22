---
title: openlayers地雷
date: 2020-07-14 01:39:57
tags:
- openlayers
- ol
- gis
---
&nbsp;
<!-- more -->
#### 樣式地雷
最好在首次執行時對樣式進行 cache , 如果不這樣寫由於 openlayers 的機制會在每次進行繪製時 new 出一堆物件 , 造成地圖畫面閃爍
``` javascript
//樣式
function pointStyle(feature) {

    var name = feature.get('name');
    var id = feature.get('id');

    var icon = new ol.style.Style({
        image: new ol.style.Icon(({
            src: 'point.png'
        })),
        text: new ol.style.Text({
            text: name,
            fill: new ol.style.Fill({
                color: '#000'
            }),
            stroke: new ol.style.Stroke({
                color: '#fff',
                width: 2
            }),
            offsetY: 24
        })
    });

    return icon;
}

//這邊已經讀了某些後端送來的資料
features.forEach(function (feature) {
	
    var name = feature.get('name');
    var id = feature.get('id');
    var cache = {
        name: name,
        id: id,
        style: pointStyle(feature)
    };
    styleCaches.push(cache);
});

var layer = new ol.layer.Vector({
	renderMode: 'image',
	source: new ol.source.Vector({
	    format: new ol.format.GeoJSON(),
	}),
	style: function (feature) {
		var name = feature.get('name');
		var id = feature.get('id');
		var style;
		for (var i = 0; i < styleCaches.length; i++) {
			var ele = styleCaches[i];
			if (ele.id == id && ele.name == name) {
				style = ele.style;
				break;
			}
		}
		return style;
	}	
});
```
#### loader 地雷
工作上跟別人搭配遇到的地雷! 以前很喜歡直接使用 loader ,  時需要注意如果地圖在初始化時為 visible 為 false 或是 hidden 的情況 , 會造成 loader 失效 , 要切換到地圖讓地圖顯示才會生效 ..
``` javascript
var layer = new ol.layer.Vector({
	renderMode: 'image',
	source: new ol.source.Vector({
	    format: new ol.format.GeoJSON(),
	    loader: function () {
	        // todo
	    }
	})
});
```
