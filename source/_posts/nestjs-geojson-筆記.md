---
title: nestjs geojson 筆記
date: 2023-11-16 18:58:34
tags:
- js
- nestjs
- gis
---
&nbsp;
<!-- more -->

今天測試 `nestjs` 這個潮潮的 `framework` , 然後就被 `geojson` 潮到淹死了 XD
起先我安裝 [geojson](https://www.npmjs.com/package/geojson) 試圖解析 string 為 geojson
然後想說用 `typescript` 怎麼能不用型別呢 , 於是乎安裝[定義檔](https://www.npmjs.com/package/@types/geojson)
結果這兩個 lib 竟然撞名 , 導致一堆 error , 後來查下可以在安裝的時候用 alias
```
# 往生
# npm i geojson

# 改用 alias 安裝
npm install geojson-parser@npm:geojson
npm i --save-dev @types/geojson
```

然後 import 時需要記得將 `GeoJSON` 改個名 , 我這裡用 `GeoJSONParser` , 就搞定惹 ~
另外要注意他這個 `parser` 的 `Point` 順序不能寫反 , 而且他是用討厭的 `lat lng` 這個順序

最後就是他接受比較沒這麼嚴謹的 geojson 驗證 , 所以可以安裝 `geojson-validation` 來自己驗看看或是其他 lib 也可

``` js
import  * as GeoJSONParser from 'geojson-parser';
import { Feature, FeatureCollection, GeoJSON } from 'geojson';
import { GeoService } from './geo.service';
import { Controller, Get } from '@nestjs/common';


@Controller('geo')
export class GeoController {
    constructor(
        private readonly geoService: GeoService
    ) {}

    @Get('points2')
    getPoints2(): FeatureCollection {
        var data = [
            { name: 'Location A', category: 'Store', street: 'Market', lat: 39.984, lon: 121.343 },
            { name: 'Location B', category: 'House', street: 'Broad', lat: 39.284, lon: 121.833 },
            { name: 'Location C', category: 'Office', street: 'South', lat: 39.123, lon: 121.534 }
        ];

        let result = GeoJSONParser.parse(data, { Point: ['lat', 'lon'] }) as FeatureCollection
        return result
    }

    @Get('points')
    getPoints(): FeatureCollection {

        let p: Point = {
            type: 'Point',
            coordinates: [121, 22]
        }

        let f: Feature = {
            type: 'Feature',
            geometry: p,
            properties: {
                name: 'Location A',
                category: 'Store',
                street: 'Market'
            }
        }

        let result: FeatureCollection = {
            type: 'FeatureCollection',
            features: [f]
        }

        return result
    }

    @Get('parse')
    parse() {
        let str =
            `{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "geometry": {
        "type": "Point",
        "coordinates": [
          121,
          25
        ]
      },
      "properties": {}
    }
  ]
}`

        let reulst = JSON.parse(str) as FeatureCollection
        return reulst
    }
}
```


後來發現其實可以用 `turfjs` 來建 geojson 也是滿方便低
```
npm install @turf/turf
```

import
```
import * as turf from '@turf/turf'
```

``` ts
@Get('getGeoByTurf')
getGeoByTurf() : FeatureCollection{

	let locationA = turf.point([-75.343, 39.984], { name: 'Location A' }) as Feature
	let locationB = turf.point([-75.833, 39.284], { name: 'Location B' }) as Feature
	let locationC = turf.point([-75.534, 39.123], { name: 'Location C' }) as Feature

	var collection = turf.featureCollection([
		locationA,
		locationB,
		locationC
	]) as FeatureCollection

	return collection
}
```


其他要設定 cors & swagger 大概就這樣用
```
npm install @nestjs/swagger
npm install swagger-ui-express
```


```
async function bootstrap() {
    const app = await NestFactory.create(AppModule);
    app.enableCors()
    setupSwagger(app)

    const builder = new DocumentBuilder();
    const config = builder
    .setTitle('geo api')
    .setDescription('geo api')
    .setVersion('1.0')
    .build()

    const document = SwaggerModule.createDocument(app , config)
    SwaggerModule.setup('swagger' , app , document)	

    await app.listen(3000);
}


bootstrap();
```
