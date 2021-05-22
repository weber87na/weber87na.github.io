---
title: webp 在圖磚上的應用
date: 2020-08-28 20:28:33
tags:
- imagemagick
- webp
- gis
---
&nbsp;
<!-- more -->
上課剛好學到 webp 格式之前都想不到有啥運用，這次硬擠出一篇將 webp 用在圖磚上
webp html 使用可以參考[這篇](https://medium.com/@mingjunlu/image-optimization-using-webp-72d5641213c9)

萬一在 wsl 上面使用 imagemagick 批次轉換 webp 時發生以下錯誤
```
convert-im6.q16: delegate failed `'cwebp' -quiet %Q '%i' -o '%o'' @ error/delegate.c/InvokeDelegate/1919.
```

只需要安裝 webp 就即可解決
```
sudo apt-get install webp
convert author.jpg author.webp
```

詳細可以參考老外說明
[https://askubuntu.com/questions/251950/imagemagick-convert-cant-convert-to-webp](https://askubuntu.com/questions/251950/imagemagick-convert-cant-convert-to-webp)
[https://imagemagick.org/script/webp.php](https://imagemagick.org/script/webp.php)


國土測繪中心圖磚 open data [下載](https://maps.nlsc.gov.tw/MbIndex_qryPage.action?fun=8#)
安裝 mapbox mbutil [下載位置](https://github.com/mapbox/mbutil)
注意需要 python >= 2.6
```
sudo apt-get install -y python-setuptools
sudo python setup.py install
```

將 mbtiles 匯出到 TaiwanEMap6 資料夾
```
mb-util TaiwanEMap6.mbtiles TaiwanEMap6
```

bash 呼叫 imagemagick 遞迴轉換圖磚為 webp 格式，注意這個會執行很久要測試的話放個六層大概就差不多了，而且會從 0 => 1 => 11 => 12 這樣的順序跑，每次都忘了被這個雷
``` bash
#!/bin/bash
shopt -s globstar
shopt -s nullglob
for file in TaiwanEMap6/**/*.png
do
	# echo  "$file" "${file/%.png}.webp"
	convert  "$file" "${file/%.png}.webp"
done
```

測試 webp 格式地圖在 openlayers 上，應該可以減少不少流量，幸運女神眷顧好運成功!
```
<!doctype html>
<html lang="en">
	<head>
		<link rel="stylesheet" href="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.4.3/css/ol.css" type="text/css">
		<style>
.map {
	height: 100vh;
	width: 100%;
}
		</style>
		<script src="https://cdn.jsdelivr.net/gh/openlayers/openlayers.github.io@master/en/v6.4.3/build/ol.js"></script>
		<title>webp example</title>
	</head>
	<body>
		<h2>webp</h2>
		<div id="map" class="map"></div>
		<script type="text/javascript">
			var map = new ol.Map({
				target: 'map',
				layers: [
					new ol.layer.Tile({
						source: new ol.source.XYZ({
							//url: './TaiwanEMap6/{z}/{x}/{y}.png',
							url: './TaiwanEMap6/{z}/{x}/{y}.webp',
							//crossOrigin : 'anonymous'
						})
					})
				],
				view: new ol.View({
					center: ol.proj.fromLonLat([121.5, 22]),
					zoom: 6
				})
			});
		</script>
	</body>
</html>
```
