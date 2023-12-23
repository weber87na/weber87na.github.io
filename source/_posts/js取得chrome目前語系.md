---
title: js取得chrome目前語系
date: 2023-06-01 18:32:58
tags:
---
&nbsp;
<!-- more -->

工作上被雷到的問題 , 加減記錄下
首先按下 chrome 右側的 `點點點...` => `設定` => `拉到最底部` => `進階`
找到 `語言` => `點小箭頭` => 我自己預設有四種 `中文（繁體）` `中文` `英文（美國）` `英文`
```
this.window.navigator.languages
//["zh-TW", "zh-CN", "zh", "en-US", "en"]

this.window.navigator.language
//"zh-TW"
```

接著想要啥語言可以自己新增玩看看 , 我這裡新增日語 , 然後故意把日語往下移動 , 並且勾選為 `Chrome UI` 的語言 (你的 Chrome 介面就會顯示那個語言)
```
this.window.navigator.languages
["zh-TW", "ja", "zh", "en-US", "en"]
```

接著驗證 `this.window.navigator.language` 會得到啥
結果令人跌破眼鏡 , 沒想到用 js 撈的語言跟 Chrome UI 得到的八竿子打不著關係! 實際上會得到你第一順位的語言 , 不是你 Chrome UI 設定的語言
```
this.window.navigator.language
//"zh-TW"
```

後來我找到老外解法 [參考這篇](https://stackoverflow.com/questions/25606730/get-current-locale-of-chrome)
只要無腦塞這句 `Intl.NumberFormat().resolvedOptions().locale` 就可以取得 Chrome UI 的語言
```
function getClientLocale() {
  if (typeof Intl !== 'undefined') {
    try {
      return Intl.NumberFormat().resolvedOptions().locale;
    } catch (err) {
      console.error("Cannot get locale from Intl")
    }
  }
}
```
