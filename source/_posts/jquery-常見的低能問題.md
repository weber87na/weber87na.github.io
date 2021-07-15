---
title: jquery 常見的低能問題
date: 2021-06-16 04:17:39
tags: jquery
---
&nbsp;
<!-- more -->

### 從父層撈 iframe 內的東東

注意 `document` 當作 context
```
$('#btn-query',window.frame[0].document);
```
後來又發現可以參考這兩篇文章
(https://stackoverflow.com/questions/6316979/selecting-an-element-in-iframe-jquery)
(https://codertw.com/%E5%89%8D%E7%AB%AF%E9%96%8B%E7%99%BC/289936/)

### click 地雷
一般在撰寫 jQuery 時需要觸發 click 都會偷懶這樣寫

問題是這種寫法遇到當物件是動態產生就很容易炸了
```
$('.item').click(function(){
    //
    console.log('item click !');
});
```
 所以最好這樣寫 就算是動態物件產生也不會炸!
```
$(document).on('click','.item',function(){
    //
    console.log('item click !');
});
```

### jquery datatable render 很慢
工作上遇到一個非常雷的問題 , 我串接其他 3rd 的 api 原本以為是資料量過大導致 jquery datatable 跟前端回應較慢 , 問題是這個 api 速度極為不穩定從 3 - 5 秒到 30 秒以上都有可能發生 , 害我一度以為要做後端 pagging .

最後發現原來是 jquery datatable 要設定 [deferRender 這個 option](https://datatables.net/examples/ajax/defer_render.html) 這樣 render 速度才會快 , 這個痛點搞了我整整一週時間去 Trace 沒想到是前端的問題 無奈 ..
