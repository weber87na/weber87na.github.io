---
title: FineReport 使用 sql server localdb
date: 2023-04-09 03:26:10
tags:
- finereport
- sql server
- jdbc
- localdb
---
![finereport](https://www.finereport.com/jp/wp-content/themes/newsite/banner-try4.png)
<!-- more -->

因為自己懶得安裝暴肥的 sql server 在本機上 , 偏偏 finereport 預設沒支援 localdb
只好研究看看有無連線 localdb 的方法 , 即使現在都 2023 了微軟的 jdbc 還是沒支援 localdb 真是無言
關於 localdb 請參考[這篇](https://stackoverflow.com/questions/11345746/connecting-to-sql-server-localdb-using-jdbc) 及 [這篇](https://tonesandtones.github.io/sql-server-express-localdb-jdbc/)

### 取得 localdb 資訊
首先入指令 SqlLocalDb info
```
SqlLocalDb info
MSSQLLocalDB
```

接著輸入指令 `SqlLocalDb info MSSQLLocalDb`
```
SqlLocalDb info MSSQLLocalDb
名稱:               mssqllocaldb
版本:               15.0.4153.1
共用名稱:
擁有者:             XXX
自動建立:        是
狀態:              執行中
上一次啟動時間:    2023/4/9 上午 01:04:11
執行個體管道名稱: np:\\.\pipe\LOCALDB#6F749DQQ\tsql\query
```

所以可以得到以下 jdbc 連線字串
```
jdbc:jtds:sqlserver://./YourDatabaseName;instance=LOCALDB#6F749DQQ;namedPipe=true
```


### jTDS jdbc 下載及設定
[jTDS 1.3.2 載點](https://github.com/milesibastos/jTDS/releases/download/v1.3.2/jtds-1.3.2-dist.zip)
下載後解壓然後找到 `jtds-1.3.2.jar` 接著也解壓 `META-INF\services\java.sql.Driver` 找到這個文件用 notepad 開啟
把裡面的 Driver 名稱抄下來 `net.sourceforge.jtds.jdbc.Driver`

接著要把 `jtds-1.3.2-dist\x64\SSO\ntlmauth.dll` 這個丟到 finereport java home 裡面 , 位置在此 `C:\FineReport_11.0\jre\bin`
可以看到他的 java 是用 redhat 的 openjdk
```
Picked up JAVA_TOOL_OPTIONS: -Dfile.encoding=UTF-8
openjdk version "1.8.0_191-1-redhat"
OpenJDK Runtime Environment (build 1.8.0_191-1-redhat-b12)
OpenJDK 64-Bit Server VM (build 25.191-b12, mixed mode)
```

這步驟沒做的話會噴這樣
```
java.sql.SQLException: I/O Error: SSO Failed: Native SSPI library not loaded. Check the java.library.path system property.
	at net.sourceforge.jtds.jdbc.TdsCore.login(TdsCore.java:654)
	at net.sourceforge.jtds.jdbc.JtdsConnection.<init>(JtdsConnection.java:371)
	at net.sourceforge.jtds.jdbc.Driver.connect(Driver.java:184)
	at com.fr.third.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1666)
	at com.fr.third.alibaba.druid.pool.DruidAbstractDataSource.createPhysicalConnection(DruidAbstractDataSource.java:1732)
	at com.fr.third.alibaba.druid.pool.DruidDataSource$CreateConnectionThread.run(DruidDataSource.java:2907)
Caused by: java.io.IOException: SSO Failed: Native SSPI library not loaded. Check the java.library.path system property.
	at net.sourceforge.jtds.jdbc.TdsCore.sendMSLoginPkt(TdsCore.java:1963)
	at net.sourceforge.jtds.jdbc.TdsCore.login(TdsCore.java:617)
	... 5 more
```
這個 dll 丟完以後記得重新啟動 finereport , 不然會沒 load 進去

### finereport 驅動設定
參考 finereport 的 [驅動管理](https://help.fanruan.com/finereport/doc-view-4165.html)
這裡要先修改 `FineDB` 裡面的設定 , 可以直接下載他提供的模板 [finedb字段修改.cpt](https://help.fanruan.com/finereport/doc-download-/finereport/uploads/file/20221118/finedb%E5%AD%97%E6%AE%B5%E4%BF%AE%E6%94%B9[point]cpt)
然後填入 `SystemConfig.driverUpload` `true` 即可
另外他這個模板的 `FineDB` 大小寫要注意下 , 我自己的環境是都小寫 , 記得要修改跟他一致
這個步驟做完後就可以在 `驅動器` 看到 `自訂` 這個選項 , 不然本來只有 `預設`

然後進入到管理後台 `http://localhost:8075/webroot/decision`
`資料連結` => `資料連結管理` => `驅動管理` => `新建驅動` => `localdb` => `上傳檔案` => `jtds-1.3.2.jar` => `驅動那欄填入 net.sourceforge.jtds.jdbc.Driver`

`新建資料連結` => `其他` => `其他 JDBC`
`資料連結名稱` => `localdb`
`驅動` => `自訂` => `net.sourceforge.jtds.jdbc.Driver (localdb)`
`資料連結URL` => `jdbc:jtds:sqlserver://./YourDatabaseName;instance=LOCALDB#6F749DQQ;namedPipe=true`

最後測試連線 , 然後神奇的事發生啦 , 連線成功! 到此就整個搞定
