---
title: MutationObserver 筆記
date: 2023-04-08 00:10:00
tags:
- js
- css
- finereport
- chatgpt
---
&nbsp;
<!-- more -->

長官在 finereport 遇到的問題 , 幫忙看看 
情境如下 : 有起訖時間 , 還有個輸入時間 , 如果小於起始時間 , 輸入時間就顯示紅色 , 如果大於結束時間 , 輸入時間也顯示紅色
印象中以前用過 DOM 改變的 event , 有點忘了名字 XD , 反正我的情境 try 了沒用
猜測 finereport 裡面可能先更新 attribute 然後才更新 innerText , 並且 finereport 裡面的 web 版跟手機板是兩回事 , 連產生出來的 element id 都不同
web 版會產生類似這樣的 id `B2-0-0` , 手機板則會產類似這樣 `col_1_row_1`
正當沒頭緒跟風問看看 chatgpt 方向 , 我的咒語如下
```
我用 javascript 怎麼偵測 innerHtml change
```

然後 chatgpt 說一堆五四三 , 就不列了 , 但是有這個關鍵字 `MutationObserver` , 所以 google 看看 , 可以看 [MutationObserver](https://developer.mozilla.org/zh-TW/docs/Web/API/MutationObserver) 的用法
有了方向做事就簡單 , 當有異動的話就取得內容然後修改字體顏色收工 ~

for web
```
//取得起訖條件 html element
var start = document.querySelector('#B2-0-0');
var end = document.querySelector('#C2-0-0');
var result = document.querySelector('#E2-0-0');

//設定監控事件
const observer = new MutationObserver(function (mutations) {
        //console.log(mutations);

        var startNum = parseInt(start.innerText);
        var endNum = parseInt(end.innerText);
        var resultNum = parseInt(result.innerText);
        
        if(startNum)
        if(endNum)
        if(resultNum){
                if(resultNum < startNum || resultNum > endNum)
                        result.style.color = 'red';
                else
                        result.style.color = 'black';
        }
});

//監控起訖條件
observer.observe(start, {
        childList: true,
        attributes: true,
        characterData: true,
});

observer.observe(end, {
        childList: true,
        attributes: true,
        characterData: true,
});

observer.observe(result, {
        childList: true,
        attributes: true,
        characterData: true,
});

```

for mobile
```
var startMobile = document.querySelector('#col_1_row_1 input');
var endMobile = document.querySelector('#col_2_row_1 input');
var resultMobile = document.querySelector('#col_4_row_1 input');

//設定監控事件
const observerMobile = new MutationObserver(function (mutations) {
        //console.log(mutations);

        var startNum = parseInt(startMobile.value);
        var endNum = parseInt(endMobile.value);
        var resultNum = parseInt(resultMobile.value);
        
        if(startNum)
        if(endNum)
        if(resultNum){
                if(resultNum < startNum || resultNum > endNum)
                        resultMobile.style.color = 'red';
                else
                        resultMobile.style.color = 'black';
        }
});

//監控起訖條件
observerMobile.observe(startMobile, {
        childList: true,
        attributes: true,
        characterData: true,
});

observerMobile.observe(endMobile, {
        childList: true,
        attributes: true,
        characterData: true,
});

observerMobile.observe(resultMobile, {
        childList: true,
        attributes: true,
        characterData: true,
});
```
