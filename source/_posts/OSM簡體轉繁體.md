---
title: OSM簡體轉繁體
date: 2020-07-05 13:11:25
tags:
- opencc
- osm
- gis
---
&nbsp;
<!-- more -->
某個台灣客戶非常討厭看到簡體字 , 希望地圖上一律呈現繁體 , 幾經波折下找到了[這篇文章](https://blog.darkthread.net/blog/opencc-notes-1)試著[下載](https://bintray.com/byvoid/opencc/OpenCC#files)[OpenCC](https://github.com/BYVoid/OpenCC) 果真立竿見影 , 只不過 [OSM](https://download.geofabrik.de/) 資料量太大只能慢慢轉換

```
使用範例
d:\opencc-1.0.1-win64\opencc -i map.osm -o tw_map.osm -c s2tw.json
亞洲
d:\opencc-1.0.1-win64\opencc -i asia-latest.osm -o tw_asia-latest.osm -c d:\opencc-1.0.1-win64\s2tw.json
中國
d:\opencc-1.0.1-win64\opencc -i china-latest.osm -o tw_china-latest.osm -c d:\opencc-1.0.1-win64\s2tw.json
```
