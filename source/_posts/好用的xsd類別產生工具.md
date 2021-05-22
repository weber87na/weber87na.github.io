---
title: 好用的xsd類別產生工具
date: 2020-07-05 14:18:54
tags:
- c#
- xml
---
&nbsp;
<!-- more -->
某次任務中要串接外國軟體丟出來的 XML Response , 問題是沒有任何 Response 的文件資料 , 研究了一下該軟體內有定義 XSD Schema , 於是參考[XSD](https://docs.microsoft.com/zh-tw/dotnet/standard/serialization/xml-schema-definition-tool-xsd-exe)工具 , 下載後很快速的產生 c# 類別! 看來產品要有完整性還是要多學學老外 , 細心雕琢.

```
xsd "C:\Program Files (x86)\Software\Spec\Execute\OrderSchema.xsd" /classes /o:D:\
```
