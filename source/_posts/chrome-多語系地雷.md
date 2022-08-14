---
title: chrome 多語系地雷
date: 2022-08-03 18:58:47
tags: chrome
---
&nbsp;
![chrome](https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Google_Chrome_icon_%28February_2022%29.svg/480px-Google_Chrome_icon_%28February_2022%29.svg.png)
<!-- more -->

最近發生個靈異問題 , 因為要測試多語系功能 , 我本來一直以為我的 Chrome 是使用英文設定 ,
因為我查詢時候是英文介面 , 沒想到可能是我無意中改到 `快速設定` 裡面的語言 , 要改回中文可以這樣設定
`先點齒輪` => `Using Search` => `Languages` => `中文繁體`

另外一個設定就是 UI 設定 , 這個要測的話可以用 js 的 `confirm` 函數來看看 , 如果跳出來是問你 `確定` & `取消` 的話
表示你的 chrome UI 實際上是中文 , 可以參考以下步驟
`點點點` => `設定` => `進階` => `語言` => `把英語往上移動` => `勾選 UI 使用英語` => `重啟 Chrome`
