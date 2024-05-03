---
title: c# 泛型方法實務
date: 2024-01-19 20:13:13
tags: c#
---

&nbsp;
<!-- more -->

工作上遇到的問題 , 假設有一堆 `Station` 的資料表 , 他們都繼承自 `IBaseStation`
他們有共通基底的屬性 , 但是每個紀錄的參數不同
```csharp
public abstract class IBaseStation{
	public int Id {get;set;}
	public string Name {get;set;}
}

public class class OOXXStation : IBaseStation{
	public double Temp {get;set;}
	public double Current {get;set;}
}
```

這時候有個 `Output<T>` 泛型方法會去呼叫 , 但是如果用 Output<IBaseStation> 在 ef core 就會噴 error
如果直接呼叫 `Output` 則會沒辦法轉成正常型別噴 `RuntimeBinderException`

```
public bool Output<T>(
StationDto station, 
int mode, 
IBaseStation stationTable, 
out string errorMessage) where T : class{
	//logic
}
```

一開始想了個笨方法大概這樣 , 有大概數十個站別所以很蠢
```csharp
bool isOk = false;
Type t = ((object)stationTable).GetType();
if(t == typeof(OOXXStation)){
isOk = ((StationService)_stationService)
	.Output<OOXXStation>(stationDto, 2, stationTable, out string errorMessage);
	return isOk;
}

//一堆其他站別的型別比對
```

後來想到應該可以用反射來呼叫 , 大概三個步驟搞定

* 首先先取得 table 的型別
* 接著呼叫泛型方法把型別塞進去
* 丟入參數

比較特別的是原本 function `errorMessage` 是用 `out` 去丟出來的
所以給參數的時候要放 `null` 去接就可以了

```csharp
//取得型別
Type t = ((object)stationTable).GetType();

//動態呼叫泛型方法
MethodInfo outputMethod = typeof(StationService)
	.GetMethod("Output")
	.MakeGenericMethod(t);

//傳遞參數 , 因為 errorMessage 是用 out 丟出來 , 所以最後一個參數給 null
object[] parameters = new object[] { stationDto, 2, stationTable, null };

string errorMessage = "";
var isOk = outputMethod.Invoke((StationService)_stationService, parameters);
if (isOk != null)
{
	if(parameters[3] != null) errorMessage = (string)parameters[3];
}
```
