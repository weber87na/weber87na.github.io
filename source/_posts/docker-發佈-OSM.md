---
title: docker 發佈 OSM
date: 2021-08-24 00:04:01
tags: docker
---

&nbsp;
<!-- more -->

### 起手 OSM
先搞個[switch2osm](https://switch2osm.org/serving-tiles/using-a-docker-container/)來玩看看 , 以前一堆工 , 有 docker 差好多
```
sudo mkdir /data
cd /data
sudo wget https://download.geofabrik.de/asia/taiwan-latest.osm.pbf
docker volume create openstreetmap-data
time docker run -v /data/taiwan-latest.osm.pbf:/data.osm.pbf -v openstreetmap-data:/var/lib/postgresql/12/main overv/openstreetmap-tile-server:1.3.10 import
docker run -p 80:80 -v openstreetmap-data:/var/lib/postgresql/12/main -d overv/openstreetmap-tile-server:1.3.10 run

#先撈個世界
sudo curl -o test.png 192.168.137.219/tile/0/0/0.png

#接著撈高雄圖書館
sudo curl -o library.png http://192.168.137.219/tile/17/109336/57081.png

#接著可以跳進去 container 看看 cache 的圖在哪
#https://stackoverflow.com/questions/12284707/how-to-clear-all-osm-tiles-cache-on-my-own-server
docker exec -it 7629 /bin/bash
ls /var/lib/mod_tile/ajt
#0  13  17  9
```

### 安裝 docker-compose
參考自[官方](https://docs.docker.com/compose/install/)
```
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```
