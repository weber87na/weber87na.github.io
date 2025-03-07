---
title: 'asp.net core NET::ERR_CERT_INVALID'
date: 2024-10-17 11:56:01
tags: c#
---
&nbsp;
<!-- more -->

這個問題應該是滿常見的, 每次遇到每次忘, 這次順便記錄下可以參考這兩篇

https://github.com/dotnet/core/issues/8951

https://stackoverflow.com/questions/63796566/neterr-cert-authority-invalid-in-asp-net-core

如果要看憑證在哪的話可以在這裡找到

`C:\Users\%username%\AppData\Roaming\ASP.NET\Https`

先執行這個命令清除

```
dotnet dev-certs https --clean
```

接著執行, 然後請關閉所有 chrome, 重啟應該就正常了

```
dotnet dev-certs https --trust
```

萬一是其他語言不會解的話, 偷懶的方法則是先在 chrome 網址列輸入以下命令然後開啟他
一樣把所有 chrome 關閉重啟即可

```
chrome://flags/#allow-insecure-localhost
```
