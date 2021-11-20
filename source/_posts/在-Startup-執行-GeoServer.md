---
title: 在 Startup 執行 GeoServer
date: 2021-11-16 01:01:16
tags: GIS
---
&nbsp;
<!-- more -->

這篇也是考古文了 , 把以前有做過 geoserver 的經驗筆記下 , 礙於年代關係不見得正確
這篇主要參考[官方](https://docs.geoserver.org/stable/en/user/production/linuxscript.html)及[這篇](https://www.linuxandubuntu.com/home/how-to-run-tomcat-server-at-startup-on-ubuntu-server)

首先建立 `geoserver` 的文件在 `/etc/init.d` 底下
```
cd /etc/init.d
sudo touch geoserver
sudo vim geoserver
```

修改重點 (如果 `startup.sh` 內已經有 `JAVA_HOME` 跟 `JAVA_OPTS` 及 `GEOSERVER_HOME` 可能就不用加)
`JAVA_HOME` 對應到該機器的 `JAVA_HOME`
`JAVA_OPTS` 看要加什麼額外的 `JAVA` 參數 [像是這篇](https://docs.geotools.org/stable/userguide/library/coverage/multidim.html) 及 [這篇](https://gis.stackexchange.com/questions/299311/geoserver-netcdf-loader-ignores-the-scaling-factor-how-to-fix)
`GEOSERVER_HOME` 對應到該機器的 `GEOSERVER_HOME`
修改重點(必加)
`Start` 函數內要執行的 `startup.sh` 路徑
`Stop` 函數內要執行的 `shutdown.sh` 路徑

`geoserver`
```
#! /bin/sh
### BEGIN INIT INFO
# Provides:          geoserver
# Required-Start:    $local_fs $remote_fs
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      S 0 1 6
# Short-Description: GeoServer OGC server
### END INIT INFO
# Define Java home
JAVA_HOME=/usr/lib/jvm/default-java; export JAVA_HOME

#set netcdf parameter
#JAVA_OPTS="-Dorg.geotools.coverage.io.netcdf.enhance.ScaleMissing=true"; export JAVA_OPTS

# Force proper GeoServer home
GEOSERVER_HOME=/usr/local/lib/geoserver-2.12.3; export GEOSERVER_HOME
PATH=/sbin:/bin:/usr/sbin:/usr/bin
start() {
sh /usr/local/lib/geoserver-2.12.3/bin/startup.sh
}
stop() {
sh /usr/local/lib/geoserver-2.12.3/bin/shutdown.sh
}
case $1 in
start|stop) $1;;
restart) stop; start;;
*) echo "Run as $0 "; exit 1;;
esac
:

```

修改權限並且註冊到電腦開啟時執行
```
chmod 755 /etc/init.d/geoserver
update-rc.d geoserver defaults
```

重新啟動電腦
```
reboot
```

此時即可執行以下三組命令
```
service geoserver start
service geoserver stop
service geoserver restart
```
