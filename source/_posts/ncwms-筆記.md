---
title: ncwms 筆記
date: 2021-11-16 21:34:19
tags: GIS
---
&nbsp;
<!-- more -->

### 安裝
這篇也是超級考古文 , 反正很冷門最後也沒用到剛好看到就整理整理 , 礙於歷史因素都是以前用過的版本
記得這個作者有包 docker 礙於當時比較 low 搞不太懂 docker 怎麼用 , 所以主要以放在 tomcat 上面為主
另外他的 `standalone` 跟 `tomcat` 在設定上好像還是有點細微差異
記得以前測試的時候有撐到 `10GB` 以上的 netcdf 單檔應該沒問題 , 不過他自帶的 gui 有時候好像有點 bug
他畫出來的圖還是挺不賴的 , 不過缺點是 contour line 會稜稜角角 , 而且這個作者堅持不改 , 可以接受才用

設定 `JAVA_HOME` 與 `JRE_HOME` 兩個系統環境變數於該環境相對應的電腦
`JAVA_HOME` = `C:\Program Files\Java\jre1.8.0_131`
`JRE_HOME` = `C:\Program Files\Java\jre1.8.0_141`

至 tomcat 官網[下載](http://tomcat.apache.org/download-90.cgi) 32bit/64bit 的 tomcat
至 github 下載 [ncwms](https://github.com/Reading-eScience-Centre/ncwms/releases/tag/ncwms-2.2.8)
ncwms [相關文件](https://reading-escience-centre.gitbooks.io/ncwms-user-guide/content/)

將解壓縮以後的檔案放到 `c:\` 底下
切換到 `cd C:\apache-tomcat-9.0.0.M22\bin` 目錄
執行 `startup.bat` 即可開啟 `tomcat` 建議使用 cmd 開啟方便 debug
將 `ncWMS2.war` 丟到 `C:\apache-tomcat-9.0.0.M22\webapps`
開瀏覽器執行 http://localhost:8080/ncWMS2/
注意網址區分大小寫 , 另外如果先前有執行過 `standalone` 版本的話其資訊會保留
設定 `tomcat` 密碼 `C:\apache-tomcat-9.0.0.M22\conf\tomcat-users.xml`
將此片段直接刪除
```
<!--
<role rolename="tomcat"/>
<role rolename="role1"/>
<user username="tomcat" password="<must-be-changed>" roles="tomcat"/>
<user username="both" password="<must-be-changed>" roles="tomcat,role1"/>
<user username="role1" password="<must-be-changed>" roles="role1"/>
-->
```

加入下列片段
```
<role rolename="admin-gui"/>
<role rolename="admin-script"/>
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="manager-jmx"/>
<role rolename="manager-status"/>

<!-- 加入這段 -->
<role rolename="ncWMS-admin" />
<user username="admin" password="ncWMS-password" roles="ncWMS-admin"/>

<user username="tomcat" password="tomcat" roles="manager-gui,manager-script,manager-jmx,manager-status,admin-script,admin-gui"/>
```
username 跟 password 可以隨意修改 , 這裡就用他預設的
登入 tomcat 開啟 `http://localhost:8080`
點選 `Manager App` 帳號密碼請都輸入 tomcat

### 繪製流向及風標
用 ncwms 繪製的話需要在變數上加上 `standard_name` 參考 [`cfconventions`](http://cfconventions.org/standard-names.html)

如果檔案不是很多 , 可以用 java netcdf 檢視工具 toolsUI-4.6.10 檢視之結果 並未添加 `standard_name` 之屬性(attribute)
[下載網址](https://www.unidata.ucar.edu/downloads/netcdf/netcdf-java-4/index.jsp)

另外還有一個工具很好用 [panoply](https://www.giss.nasa.gov/tools/panoply/) 印象中只能看圖 
如果有一堆檔案的話可以用下面這個方法搞定 , 以前是用 `python2.7` , 現在改怎樣不曉得
可以參考這些有用的連結 [github](https://github.com/Unidata/netcdf4-python) [官網文件](http://unidata.github.io/netcdf4-python/) [pip](https://pypi.org/project/netCDF4/)
```
from netCDF4 import Dataset
model = Dataset("D:\model.nc", "r+", format="NETCDF4")
model.variables["WATER_V"].standard_name = "northward_sea_water_velocity"
model.variables["WATER_U"].standard_name = "eastward_sea_water_velocity"
model.close()
```
