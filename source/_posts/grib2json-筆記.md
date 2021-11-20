---
title: grib2json 筆記
date: 2021-11-16 01:17:23
tags: GIS
---
&nbsp;
<!-- more -->

下載 [`maven`](https://maven.apache.org/) 解壓縮至 `C槽` 底下
新增環境變數 `M2_HOME`

變數名稱 `M2_HOME`
變數值 `C:\apache-maven-3.5.2`

在 `path` 底下加入
```
C:\apache-maven-3.5.2\bin
```

在 cmd 底下測試 maven
```
mvn -ver

Apache Maven 3.5.2 (138edd61fd100ec658bfa2d307c43b76940a5d7d; 2017-10-18T15:58:13+08:00)
Maven home: C:\apache-maven-3.5.2\bin\..
Java version: 1.8.0_151, vendor: Oracle Corporation
Java home: C:\Program Files\Java\jdk1.8.0_151\jre
```

下載 [grib2json](https://github.com/cambecc/grib2json)
```
git clone https://github.com/cambecc/grib2json.git
mvn package
```
編譯好會生出 `grib2json-0.8.0-SNAPSHOT.tar.gz` 可以複製到任何路徑並且解壓縮
進入其 `bin` 目錄在 `cmd` 底下執行 `grib2json.cmd` 即可

