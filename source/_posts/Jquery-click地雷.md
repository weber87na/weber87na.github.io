---
title: Jquery click地雷
date: 2020-07-05 21:42:02
tags:
- jquery
- javascript
---
&nbsp;
<!-- more -->
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
