---
title: asp.net core iis sub-application
date: 2020-07-05 21:02:52
tags:
- asp.net core
- iis
---
&nbsp;
<!-- more -->
工作上又遇到這個萬年討厭的問題 , 客戶只有一個 domain name 又必須一定要使用 80 port , 後來查了一下文件 [Sub-applications](https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/iis/?view=aspnetcore-3.1#sub-applications) 結果很不幸的全部的 url 都炸掉必須要逐一修改很無奈 , 講白了這種奇耙做法只是把 route 搞爛 , 連我去上課老師也不太願意回答這個問題 ..

在 Server Side 的 Razor Page 用了波浪符號的不會中標  , 像這樣
```
src="~/image.png"
```
但 Javascript 呼叫 ajax 的 url 中標 , 常用的 Jquery DataTable 也是中標 像這樣
```
url : '/api/food'
```
所以只好自己多墊上一層 domain name 像這樣就不會炸了 , 以後還是自己先乖乖防止先自己宣告個 namespace 物件並且加上一個 baseurl 屬性 , 像這樣
```
url : namespace.baseurl + '/api/food'
```
css 部分則是要自己看看在哪邊炸了 尤其是用了 background-image 一定炸得不要不要的 , 像這樣 只能看錯誤訊息慢慢調整 , 最悲劇的是這個我完全想不出任何方法防止 ..
```
background : url(../food.png)
```
最後一個防爆作法就是在可以加上 tag-helper 的地方都加上 , 想辦法讓 server 輸出這樣爆比較少
```
asp-append-version="true"
或
asp-append-version="false"
```