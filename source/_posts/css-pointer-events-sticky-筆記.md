---
title: css pointer-events & sticky 筆記
date: 2022-12-22 19:08:01
tags: css
---
&nbsp;
<!-- more -->

工作上遇到的問題 , 需要用 RFID Reader 讀卡 , 讀卡的特性就是要有個 input focus 在上面才會正常 , 而且實際上也是會一個字一個字 key 入
雖然刷卡這個動作看似秒殺等級 , 不過實際上一口氣會有一堆 event 收到
之前做這個的人運氣好沒發生 bug , 測試好多台電腦有的有值有的又沒 , trace 到崩潰 , 研究半天靠設定 `pointer-events: none` 加上新增 `input` 來解決
當 modal 開啟的時候先 focus input , 搭配 #modal input 裡面 events 還是會觸發的特性 , 讓 input 被點到還是有效果
如果點其他 modal 內的元素 modal 就會直接關閉
最後刷卡就正常啦 , 算是小巧的解法 XD
可以參考下 [這篇](https://stackoverflow.com/questions/1369035/how-do-i-prevent-a-parents-onclick-event-from-firing-when-a-child-anchor-is-cli
)
```
#modal * {
	pointer-events: none;
	background-color: yellow;
}
#modal input{
	pointer-events: auto;
	background-color: red;
}
```

今天同事的 table 要設定固定 header , sticky 效果
之前多多少少有做過 , 不過大多忘了怎麼做啦 , [參考這裡](https://stackoverflow.com/questions/12266262/position-sticky-on-thead)
自己拿回來寫在把 sticky 加在 `tr` 上面結果完全沒效果 , 又花了不少時間
google 到最後看老外這句是重點 , 比較老的 chrome 只有 support `th` 差點暈過去
position: sticky doesn't work with table elements (as long as their display attribute starts with table-) since tables are not part of specification:
Other kinds of layout, such as tables, "floating" boxes, ruby annotations, grid layouts, columns and basic handling of normal "flow" content, are described in other modules.
Edit: As Jul 2019 according to https://caniuse.com/#feat=css-sticky Firefox supports this feature and Chrome has at least support for `th` tag.
