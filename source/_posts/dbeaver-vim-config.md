---
title: dbeaver vim config
date: 2020-11-30 19:22:56
tags:
- vim
- dbeaver
---
&nbsp;
<!-- more -->
看到同事用 [dbeaver](https://dbeaver.io/download/) 自己也來跟風一下，發現是 eclipse 做的，剛好可以安裝 [vrapper plugin](http://vrapper.sourceforge.net/home/)
覺得很讚，紀錄一下設定的過程

在 help => install new software => work with 貼上 [vrapper](http://vrapper.sourceforge.net/update-site/stable) 以及 
[relative number](http://matf.github.io/relativenumberruler/updatesite/)
還有一個滿淫蕩的機器學習套件 [codota ai plugin](http://eclipse-update-site.codota.com) 也順便裝來玩看看

順便提一下怎麼找到正確的 plugin 連結
首先到 [eclipse market](https://marketplace.eclipse.org) 搜尋想要的關鍵字
接著點選想要的套件圖示，在 install 下方有個下載圖示，點下去複製那個 url 才是真的連結

這樣就搞定了基本的 vim 操作

接著在使用者資料夾底下建立 _vrapperrc 檔案即可編輯自己想要的 config
路徑
```
C:\Users\YourName
```
設定正常複製
```
set clipboard=unnamed
```

設定字體
window => Preferences => User Interface => Appearance => Basic => Colors And Fonts => Basic => Text Font => Edit
[fira code](https://github.com/tonsky/FiraCode)

設定背景色彩
window => Preferences => Editors => Text Editors => Appearance color options => Color => 定義自訂色彩
rgb 239 255 239

另外有個很討厭的就是預設的 eclipse keybinding 會讓 ctrl + w 及 ctrl + h 砍字與 vim 衝突到
window => Preferences => User Interface => Appearance => Keys => 

搜尋以下內容並且 Unbind Command
Close
Open Search Dialog
