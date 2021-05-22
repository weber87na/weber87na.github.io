---
title: '擷取 enum 的 description , name , value'
date: 2020-12-15 00:40:12
tags: csharp
---
&nbsp;
<!-- more -->

好像寫過這類 function 很多次了，沒一次記得怎麼寫的，隨手筆記一下
```
//轉換 Enum 為 Json
//https://www.toolbox.com/tech/programming/blogs/c-enum-to-json-011813/
//取得 Description 重要主要核心
//https://stackoverflow.com/questions/16886266/how-to-get-all-descriptions-of-enum-values-with-reflection/16887264
public JArray EnumToJson(Type e) {

	var result = new JArray();
	foreach (var val in Enum.GetValues(e)) {

		var name = Enum.GetName(e, val);
		var field = e.GetField(name);
		var desc = (DescriptionAttribute)field.GetCustomAttribute(typeof(DescriptionAttribute));
		var id = (int)val;
		var obj = new JObject();
		if (desc != null)
			obj["name"] = desc.Description;
		else
			obj["name"] = name;
		obj["id"] = id;

		result.Add( obj );
	}
	return result;

}
```

[enum 當地語系化](https://stackoverflow.com/questions/17380900/enum-localization)
