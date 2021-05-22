---
title: kotlin 的低能兒筆記
date: 2021-03-21 21:33:35
tags: 
- kotlin
- android
---
&nbsp;
<!-- more -->

### activity 沒有 intelli sense
`在 Gradle Scripts` => `build.gradle (Module: XXX)` 貼上 `id 'kotlin-android-extensions'`
```
plugins {
	id 'com.android.application'
	id 'kotlin-android'
	id 'kotlin-android-extensions'
}
```
在 `MainActivity.kt` import 下面這句
```
import kotlinx.android.synthetic.main.activity_main.*
```
### SharedPreferences 的路徑
開啟 => `DeviceFileExplorer` => `data` => `data` => `com.xxx.yourappname` => `shared_prefs`

### 基本低能知識
常數 => `val` 在 c# 裡面應該是 `const`
變數 => `var` 跟 c# 一樣
有明確資料型態的變數 => `var x: Int = 1` `var x: Float = 10f` `var x:String = "xxx"`
註解 => `//` or `/* xxx */`
template string => `println("$x")` 有夠懶
資料型別轉換 `toInt()` `toString()` `toFloat()` `toDouble()` 相比 c# 還要 Convert.ToInt(xxx) 實在是超懶
`when` 像是 c# 的 switch 這語法倒是滿不適應的
```
when(x){
	1 -> print(1)
	2 -> print(2)
	else -> {
		print("gg")
	}
}
```
更噁心的是他可以 return value
```
val x = when(y){
	"O" -> "OK"
	"X" -> "NO"
}
```
集合 `listof("xxx" , "ooo")` 在 c# 內是 List<String>{"xxx" , "ooo"}; kotlin 真是噁心
```
for(x in listof("xxx" , "ooo"){
	println(x)
}

listOf<String>("xxx","ooo").forEach{
	println(it)
}
```
range 這個有夠噁心 , 像是 python 的語法 , 最經典應該還是 99 乘法
```
val r = 1..9
for(x in r)
	for(y in r)
		println("x * y = ${x*y}")
```
function 這種 data type 放在後面有點不太習慣
```
fun add : Int(a : Int = 0 , b : Int = 0){
	return a + b;
}
```
liline function
```
fun  x(a : Int = 0 ,  b : Int = 0) = a + b
```
匿名函式 這個有 js IIFE 立即函式的感覺
```
var result : Int = {
	var x = 10;
	var y = 20;
	x + y
}()

```
建構子 constructor 這個萬萬沒想到竟然有兩個步驟先是執行 `init` 才執行 `constructor` 簡直顛覆三觀

操作 json 也是 , 撈回來的 JSONArray 竟然沒法直接 forEach 要這樣寫
```
for(i in 0 until features.length()){
	var properties = features.getJSONObject(i).getString("properties")
	var property = JSONObject(properties)
	var name = property.getString("name")
	sb.append(name + "\n")
}
```
還好老外有講以下這種方法感覺稍微直覺點
```
(0 until features.length()).forEach({
	var properties = features.getJSONObject(it).getString("properties")
	var property = JSONObject(properties)
	var name = property.getString("name")
	sb.append(name + "\n")
})
```
kotlin 噁爛語法 apply 記得以前學 vb.net 有 with 跟 apply 一樣的等價語法 , c# 9 (.net 5) 好像也可以直接使用 with
```
c#
box with { color = "RED" , name = "aaa" }

kt
box.apply{
	color = "RED" ,
	name = "aaa"
}
```

### 類別
c# 類別基本上只要記得 `get` , `set` ,  `value` 這個些個關鍵字
```
class Person
{
	private string name = "ooxx";
	public string Name
	{
		get{ return name;}
		set{ name = value;}
	}
}
```
kotlin 基本上抄 c# 又保有 java 那種怪怪的特性硬要加個 `field` 反而不好記
如果不自己手動寫 `getter` 跟 `setter` 的話只要直接寫 `var name = "ooxx"` kotlin 就會直接幫你自動生出來超無腦
```
class Person{
	var name = "ooxx"
	get() = field
	set(value){
		field = value
	}
}
```
kotlin 的建構子非常變態 , 有分主父 , 顛覆三觀
老派比較能接受的寫法 , 不過命名超怪
```
class Person(_isGoodGame : Boolean){
	var name = "ooxx"
	get() = field
	set(value){
		field = value
	}
	var isGoodGame = _isGoodGame
}
```
還可以直接定義屬性在建構子上面 , 奇耙
```
class Person(var isGoodGame : Boolean){
	var name = "ooxx"
	get() = field
	set(value){
		field = value
	}
}
```
接著會進入次要建構子 `constructor` 老實說這樣的語法實在記不太起來
```
class Player(
		_name : String,
		var isGoodGame: Boolean
		){
	var name = ""
		get() = field.capitalize()
		private set(value){
			field = value.trim()
		}

	constructor(name : String) : this( name , isGoodGame = false){
	}
}
```
更變態的是還有個 `init` 這鬼東西感覺以前寫讀取 config 的區段現在只要寫在此就可以避開一堆軌問題

### kotlin linq
詳細可以看這篇[佛心老外](https://github.com/mythz/kotlin-linq-examples)做的 linq 101 sample 的 kotlin 版本
linq where 在 kotlin 裡面是用 filter 比較不習慣的是 kotlin 的箭頭符號是用 `->` c# 是用 `=>` 滿討厭的
```
c#
lists.Where( x => x.Name == "aaa");

kt
lists.filter{ it.Name = "aaa" };
```
在某書中看到函數式的 select 真正名稱是 map , kotlin 也用 map 好像更純一點
```
c#
lists.Select(x=> x.Name);

kt
lists.map{ x -> x.Name };
```


### debug
```
Log.d("TAG" , "Message")
println("xxxxx")
```
或是直接用 `F5` , `F10` , `F11` 設定中斷點來看

### 安裝 3rd lib
在 .net 裡面通常都用 nuget 來安裝 3rd lib
在 kotlin 裡面跟智障一樣連 lib 都不會裝原來要在 `Gradle Scripts` => `Module` => `dependencies` 裡面加上 3rd lib => 接著點 `Sync Now`
至於要去哪邊找 3rd lib 呢? 原來是在 [MVNRepository](https://mvnrepository.com/)
```
dependencies {
	implementation group: 'com.squareup.okhttp3', name: 'okhttp', version: '4.9.1'
}
```

### 開放 android 權限給 user
在 `AndroidManifest.xml` 裡面加上以下片段即可給 user 網路權限
注意要貼在 `manifest` 標籤下方 `application` 標籤的上方
```
<uses-permission android:name="android.permission.INTERNET" />
```

### 跨執行緒更新 UI
記得以前寫 winform 有 Control.BeginInvoke 這鬼東西 , 以前完全無法理解這莫名其妙的機制 , 反直覺
沒想到 android 上面只要寫上 `runOnUiThread` 就搞定了 , 真是無腦

### viewbinding
在 `Gradle Scripts` => `build.gradle` => `Module` => `kotlinOptions下方` 底下加入 
```
buildFeatures{
	viewBinding true
}
```

### json 操作
跟在 .net 上面幾乎差不多 , kotlin 有 data class 這種鬼東西跟一般類別不太一樣的是用逗號把屬性分開
```
data class Geometry (
	val type: String,
	val coordinates: List<Double>
)
```
可以裝[JSON To Kotlin](https://plugins.jetbrains.com/plugin/9960-json-to-kotlin-class-jsontokotlinclass-)
或是以前常用的[quicktype](https://app.quicktype.io/)也是可以產
看網路上一狗票人都用 [GSON](https://github.com/google/gson)
```
dependencies {
	  implementation 'com.google.code.gson:gson:2.8.6'
}
```

用起來跟 Json.Net 差不太多
這是 Json.Net
```
var xxx = JsonConvert.DeserializeObject<XXX>(data)
```

這是 Gson 你抄我我抄你 , 嘴個兩句好像 Json.Net 更簡單用 , 那串 `XXX:class.java` 看起來有夠詭異
```
var xxx = Gson().fromJson<XXX>(data, XXX::class.java)
```
