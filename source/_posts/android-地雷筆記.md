---
title: android 地雷筆記
date: 2022-01-03 02:45:09
tags: kotlin
---
&nbsp;
<!-- more -->

最近被抓來寫 android 程式 , 順便筆記下遇到的問題 , 不然久了又忘了

### 解決訪問 web api 用 http 時噴 permitted by network security policy
參考這[老外](https://stackoverflow.com/questions/68263659/android-9-0-cleartext-communication-to-ipaddress-not-permitted-by-network-secu)
在 `res` 資料夾底下新增 `network_security_config.xml`
```
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="true">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
</network-security-config>
```

接著 `AndroidMainfest.xml` 的 `application` 標籤加入這段就搞定 , 記得網路權限也要開 , android 拿權限真是麻煩的概念
```
<!--使用網路權限-->
<uses-permission android:name="android.permission.INTERNET" />

<application
	android:networkSecurityConfig="@xml/network_security_config"
	android:usesCleartextTraffic="true"

	<!-- 略... -->
</application>
```

### exposed 筆記
參考這篇大神[教學](https://ithelp.ithome.com.tw/articles/10261343)
因為是用 sql server , 本來想說可以用 localdb 不過微軟自己好像不支援 , 需要用 localdb 可以看看[這篇](https://tonesandtones.github.io/sql-server-express-localdb-jdbc/)
`gradle.kts`
```
val exposedVersion: String by project
dependencies {
    testImplementation(kotlin("test-junit"))

    implementation("org.jetbrains.exposed:exposed-core:$exposedVersion")
    implementation("org.jetbrains.exposed:exposed-dao:$exposedVersion")
    implementation("org.jetbrains.exposed:exposed-jdbc:$exposedVersion")


    // https://mvnrepository.com/artifact/com.microsoft.sqlserver/mssql-jdbc
    implementation("com.microsoft.sqlserver:mssql-jdbc:9.4.1.jre8")

    implementation("org.slf4j:slf4j-api:1.7.32")
    implementation("org.slf4j:slf4j-log4j12:1.7.32")
}
```

接著這邊跟 entity framework code first 差不多 , 都要先定義 mapping 的物件
設定資料表 `XY` => 資料表名稱 , 因為是用 `bigint` 所以用 `LongIdTable`
`primary key` => `XYID`
```
object XYTable : LongIdTable("XY", "XYID") {
    var x = decimal("X", 11, 8)
    var y = decimal("Y" , 11 , 8)
}
```

定義 `DAO` 類別 , 這裡有個雷半天的地方 , 用 `by` 不能用 `=` 等號
```
class XY(id: EntityID<Long>) : LongEntity(id) {
    companion object : LongEntityClass<XY>(XYTable)

    var xyId by XYTable.id
    var x by XYTable.x
    var y by XYTable.y
}
```

### 撈 web api 筆記
在 `build.gradle` 先安裝套件 `okhttp` 跟 `GSON`
```
//ok http
implementation("com.squareup.okhttp3:okhttp:4.9.0")

//GSON
implementation 'com.google.code.gson:gson:2.8.6'
```

先打網址看看回啥格式 , 然後建立 `data class` , 這邊跟 c# 的 `JsonPropertyName` 類似 , 不過叫做 `SerializedName` 來設定 `json` 的欄位名稱
```
data class XY(
	@SerializedName("XYID")
	val XYID: Long,

	@SerializedName("X")
	val X:Double,

	@SerializedName("Y")
	val Y:Double
```


因為是撈 `web api` 的資料 , 時間格式會像這樣 `2018-12-26T11:21:13` 需要在 `gson` 設定 format , 沒設定的話會噴 `No time zone indicator` 要特別注意
```
val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss").create()
```

整個 `function` 會長這樣 , 另外要直接在 android 上面用的話 , 一定要用非同步的 `enqueue` , 不然也會噴 error
```
private fun getData() {
	val url = "http://yourip/api/xy/123"
	val client = OkHttpClient().newBuilder().build();
	val request = Request.Builder().url(url).get().build()
	val call = client.newCall(request)
	call.enqueue(object : Callback {
		override fun onFailure(call: Call, e: IOException) {
			Log.e("MSG", "onFailure $e")
		}

		override fun onResponse(call: Call, response: Response) {
			val json = response.body?.string()

			//這句沒設定的話會噴 No time zone indicator 特別注意
			val gson = GsonBuilder().setDateFormat("yyyy-MM-dd'T'HH:mm:ss").create()
			val listType = object : TypeToken<List<XY>>() {}.type
			val xyList = gson.fromJson<List<XY>>(json, listType)
			for (xy in xyList) {
				Log.d("MSG", "lon: ${xy.X} lat: ${xy.Y}")
			}

		}
	})
}
```

接著塞資料看看 , 因為對 android 沒啥經驗 , 他這個 Log.d 的第一個參數 `tag` 滿有趣的 , 可以在 `Logcat` 幫你用來篩選想看的資訊
```
private fun postData() {
	val url = http://yourip/api/xy/add"
	val client = OkHttpClient().newBuilder().build();

	//val now = Calendar.getInstance().time
	val xy = XY(
			XYID = 0,
			x = 123,
			y = 45
	)

	val point = Gson().toJson(xy)

	val body = point.toRequestBody("application/json".toMediaTypeOrNull());
	val request = Request.Builder()
			.url(url)
			.post(body)
			.build();

	val call = client.newCall(request);
	call.enqueue(object : Callback {
		override fun onFailure(call: Call, e: IOException) {
			Log.e("your tag", "onFailure $e")
		}

		override fun onResponse(call: Call, response: Response) {
			val resp = response.body?.string()
			Log.d("your tag", "onResponse $resp")
		}
	})

}
```

### GPS 定時取得經緯度
這個比想像中還不直覺 , 因為對 android 比較不熟 , 一開始以為用 background service 可以抓資料
後來搞了半天是要用 `foreground service` 可以參考這個老外的[文章](https://thakkarkomal009.medium.com/update-location-in-background-using-foreground-service-android-7aee9de1a6d6)
source code [下載](https://github.com/thakkarkomal009/Android-Samples/tree/master/GetLocationBackground)
google 官方 java 的[example](https://github.com/android/location-samples/tree/master/LocationUpdatesForegroundService)
中文資料可以參考[這篇](https://jefflin1982.medium.com/android-%E9%97%9C%E6%96%BCbackground-location%E7%9A%84%E4%B8%80%E4%BA%9B%E4%BA%8B%E6%83%85-6d896f33053)

