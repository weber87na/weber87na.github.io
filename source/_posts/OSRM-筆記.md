---
title: OSRM 筆記
date: 2022-05-03 20:10:58
tags:
---
&nbsp;
<!-- more -->

以前有耳聞可以讓 GPS 蒐集回來的點位貼在路上 , 不會歪歪扭扭低 ~
於是找看看解決方法 , 主要參考這篇[文章](https://spatialthoughts.com/2020/02/22/snap-to-roads-qgis-and-osrm/)

原來是用了 [osrm](http://project-osrm.org/) 這個 open source 的 project , 文件可以看[這裡](http://project-osrm.org/docs/v5.24.0/api/?language=cURL#match-service)
[其他方案](https://github.com/graphhopper/graphhopper) 可以看看這個

因為現在都流行 docker 可以看到他的 [docker hub](https://hub.docker.com/r/osrm/osrm-backend/) , 用起來還算是簡單
```
docker pull osrm/osrm-backend
```

先到[這裡](http://download.geofabrik.de/asia/taiwan.html)下載台灣圖資
如果用 windows 10 的話 , 其實現在內建就有 curl 可以參考我這篇[筆記](https://weber87na.github.io/2021/12/01/%E6%88%91%E7%9A%84-powershell-%E8%A8%AD%E5%AE%9A/) 去把預設 powershell 的假 curl 移除
接著就快樂用 curl 來抓台灣資料
```
mkdir osrmlab
cd osrmlab
curl http://download.geofabrik.de/asia/taiwan-latest.osm.pbf -O taiwan-latest.osm.pbf
```

執行 docker 等他跑一陣子 , 最後會出現下面的訊息
```
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-extract -p /opt/car.lua /data/taiwan-latest.osm.pbf

[info] Processed 3573744 edges
[info] Expansion: 100100 nodes/sec and 55427 edges/sec
[info] To prepare the data for routing, run: ./osrm-contract "/data/taiwan-latest.osrm"
[info] RAM: peak bytes used: 1061433344
```

這步不曉得裡面偷算啥 , 乖乖執行
```
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-partition /data/taiwan-latest.osrm
docker run -t -v "${PWD}:/data" osrm/osrm-backend osrm-customize /data/taiwan-latest.osrm
```

後來我在 aws 開個免費的 ubuntu 好像記憶體太低會噴這個錯 , 最好要有 4GB 的記憶體才正常
[老外也有遇到] (https://github.com/Project-OSRM/osrm-backend/issues/5679)
```
[error] Input file "/data/taiwan-latest.osrm.ebg" not found!
```


最後就是跑起他整個服務即可 , 老外有多加上 `--max-matching-size 5000` 這個應該是用來限制多少 point
```
docker run -t -i -p 5000:5000 -v "${PWD}:/data" osrm/osrm-backend osrm-routed --algorithm mld --max-matching-size 5000 /data/taiwan-latest.osrm
```

最後特別要注意下 `;` 符號結尾萬一加了會噴 `error`
```
{"message":"Query string malformed close to position 1824","code":"InvalidQuery"}
```

其他常用參數
`geometries` = `polyline` or `geojson` or `polyline6`
`steps` = `true` or `false` 不想要這麼多資訊無腦的話用 `false`
```
curl "http://127.0.0.1:5000/match/v1/car/120.43882360,22.59893000;120.43360530,22.60508150;120.43364010,22.60482600;120.43389470,22.60363140;120.43362430,22.59772020;120.43522910,22.59698420;120.43528030,22.59665970;120.43581210,22.59320460;120.43568300,22.59298700;120.43594310,22.59316370;120.43588360,22.59309300;120.43591660,22.59313220;120.43138970,22.59400020;120.43157110,22.59202400;120.43063940,22.59219700;120.43014450,22.59217010;120.42913480,22.59215090;120.42640910,22.59218270;120.42491190,22.59217880;120.42389130,22.59207070;120.42264670,22.59156340;120.42128700,22.59054580;120.42058400,22.58984770;120.41992160,22.58904880;120.41823970,22.58750420;120.41577290,22.58654150;120.41327330,22.58646710;120.41082080,22.58649450;120.40818620,22.58655680;120.40550610,22.58659170;120.40404830,22.58659170;120.40282080,22.58672880;120.40016970,22.58727780;120.39765960,22.58782140;120.39557860,22.58827500;120.39381550,22.58866560;120.39169080,22.58913490;120.38944890,22.58941860;120.38696980,22.58939790;120.38467380,22.58932380;120.38283550,22.58929130;120.38100070,22.58928860;120.37910450,22.58925630;120.37715600,22.58925080;120.37484080,22.58930450;120.37247030,22.58935540;120.37125060,22.58937700;120.36965960,22.58949190;120.36766100,22.59004470;120.36553000,22.59004360?steps=true&geometries=polyline"
```

google map 繪製 polyline , 這串亂七八糟的 `w`~hC}da~Up@GnFo@po@mHdA....` 就是 `polyline` , 想 decode 可以看[這個](https://www.npmjs.com/package/google-polyline)
```
var poly = new google.maps.Polyline({
	path: google.maps.geometry.encoding.decodePath('w`~hC}da~Up@GnFo@po@mHdA|UoKk@{@qIWiG~De@~@KxTkCJAE@aPfBdA|UnHb@tHNf@bPcByf@fBz]FhED~ODhHRjEtA|FrEfGlCfCvCpCtHjI|DlNJrNEhNElOEvOGbHYrFiBrOqBrN{A~KkA~IyAhLm@`M@nNDjMBlJBnJBxJ@dKCnMExMGrFs@vHgAvKIfL'),
	geodesic: true,
	strokeColor: "#00AAFF",
	strokeOpacity: 1.0,
	strokeWeight: 2,
});
poly.setMap(map);
```

### aws

後來在 AWS EC2 上面玩看看 , 順手筆記下

如果想要用帳號密碼登入 AWS EC2 上的 ubuntu 預設是關閉的 , 需要將 `PasswordAuthentication no` 改為 `PasswordAuthentication yes` 可以[參考這裡](https://www.cyberciti.biz/faq/how-do-i-restart-sshd-daemon-on-linux-or-unix/)
另外靈異的是預設竟然有裝 vim 到底是 ubuntu22 預設有還是 AWS EC2 有就不得而知啦
```
ubuntu@54.123.45.246: Permission denied (publickey).

sudo vim /etc/ssh/sshd_config
sudo systemctl restart ssh.service
```

因為好像要 4GB 的 memory 才可以正常計算 , 所以一開始先選擇 `t2.medium` 的 instance
先跑完該執行的指令讓他計算後 , 再降回 `t2.micro` 的免費仔 instance
接著設定 `elastic ip` 關聯到自己的 instance , 接著可以直接用這個 ip 進行連線 , 另外如果把 instance 刪掉的話 , 這個最好也跟著刪掉 , 不然好像要交保護費
```
ssh -i "qq.pem" ubuntu@123.45.67.89
```

開放 80 or 443 port
找到左側的 `Network & Security` => `Security Groups` => `Inbound rules` => `Edit inbound rules` 然後加你要的 port 即可
接著可以搞個 docker 打下 api 測試看看
```
curl "http://123.45.67.89:5000/match/v1/car/120.43882360,22.59893000;120.43360530,22.60508150;120.43364010,22.60482600?steps=true&geometries=polyline"
```


最後我又裝個 nginx 去轉 , 可以看到跑一個 osrm 的 container 及 nginx 服務就快塞滿了 , 時不時就在當機
實際上還是需要調高記憶體效果才會較優 , 免得記憶體塞滿整個當機
```
free

               total        used        free      shared  buff/cache   available
Mem:          991064      846812       70520        1032       73732       28736
```


