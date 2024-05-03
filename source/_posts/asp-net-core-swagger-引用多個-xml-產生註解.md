---
title: asp.net core swagger 引用多個 xml 產生註解
date: 2024-03-06 21:19:20
tags: .net core
---
&nbsp;
<!-- more -->

工作上遇到的問題 , 今天發現明明建了一堆 DTO & Model & ViewModel , 可是只有 controller 上面的 xml 註解在 api 上面有生效
一開始以為是 NewtonsoftJson 的問題 , 後來看老外文章跟自己做實驗才發現 , 如果有分層去切專案的話應該要引用多個 xml 檔案讓 swagger 吃到才對
方法可以看[這篇](https://github.com/domaindrivendev/Swashbuckle.WebApi/issues/1387)
這個問題應該在不管 .net framework or .net core 都有
記得要在每個引用的專案都設定 `Properties` => `Build` => `Output` => `Documentation file 打勾`
```
builder.Services.AddSwaggerGen(x =>
{
	//這裡跑個迴圈讓參考其他 project 的 xml 也吃到
    List<string> xmlFiles = Directory.GetFiles(AppContext.BaseDirectory, "*.xml", SearchOption.TopDirectoryOnly).ToList();
    xmlFiles.ForEach(xmlFile => x.IncludeXmlComments(xmlFile));

	//原本這樣寫只會吃到一個 xml
    //var xmlFile = $"{Assembly.GetExecutingAssembly().GetName().Name}.xml";
    //x.IncludeXmlComments(Path.Combine(System.AppContext.BaseDirectory, xmlFile));
	
	//笨方法手動多加
	//var libxml = "ClassLibrary1.xml";
    //x.IncludeXmlComments(Path.Combine(System.AppContext.BaseDirectory, libxml));

});

```
