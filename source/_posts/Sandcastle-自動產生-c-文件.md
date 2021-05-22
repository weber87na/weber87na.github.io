---
title: Sandcastle 自動產生 c# 文件
date: 2020-11-21 08:27:52
tags: csharp
---
&nbsp;
<!-- more -->

每次要看分析程式碼缺少文件或是交付文件覺得很困擾，所以找看看有無自動化的方法
首先下載 [Sandcastle](https://github.com/EWSoftware/SHFB/releases)
注意他叫你安裝的都要安裝要仔細看
尤其是這個 HTML Help Workshop 雷了很久
[https://docs.microsoft.com/en-us/previous-versions/windows/desktop/htmlhelp/microsoft-html-help-downloads](https://docs.microsoft.com/en-us/previous-versions/windows/desktop/htmlhelp/microsoft-html-help-downloads)
接著是 c++ build tool 可以參考[這篇](https://stackoverflow.com/questions/57795314/are-visual-studio-2017-build-tools-still-available-for-download)那個載點找了好久
安裝完以後就可以開啟 gui 無腦產生 code
特別需要注意的就是要把 xml 產生文件的選項也給勾起來
Project => Properties => Build => XML documentation file
