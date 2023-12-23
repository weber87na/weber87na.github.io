---
title: css 邊框效果
date: 2022-09-22 18:35:43
tags: css
---
![DBA](https://raw.githubusercontent.com/weber87na/flowers/master/DBA.png)
<!-- more -->

今天在 104 看到一個還滿有趣的[效果](https://kad.events.104.com.tw/keyence_20220823/?shelfId=189853&jobsource=189853_) , 本來以為是有字的 `「職涯」` 沒想到是撒旦說的障眼法 XD
原理是利用 `border-top` `border-left` 等去加上框線 , 因為框線有兩邊所以要用 `span-first-child & span:last-child` 個別設定 , 接著利用 `before` 偽元素去繞著跑小方框 , 我自己稍微改造下變成圓球
另外小方框的動畫也滿特別的 , 要注意算下位置讓 `0% - 100%` 回到原點 , `25% - 75%` 跑到中間 , `50%` 則跑到下方
最後八卦到公司同事以前是友達低 , 就改成一個不錯的招募標語 XD

<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="poVrQXa" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/poVrQXa">
  DBA</a> by 喇賽人 (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>


```
<html lang="zh-Hant">

<head>
    <meta charset="UTF-8">
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Document</title>
    <style>
        * {
            padding: 0;
            margin: 0;
            color: #fff;
            font-family: '微軟正黑體';
            font-size: 72px;
        }

        body {
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: #000;
        }

        .title {
            position: relative;
        }

        .title span:first-child {
            border-top: 3px solid white;
            border-left: 3px solid white;
            display: block;
            position: absolute;
            width: 30px;
            height: 20px;
            top: 5px;
            left: -5px;
        }

        .title span:last-child {
            border-bottom: 3px solid white;
            border-right: 3px solid white;
            display: block;
            position: absolute;
            width: 30px;
            height: 20px;
            bottom: 5px;
            right: -5px;
        }

        .title span:first-child:before {
            content: '';
            position: absolute;
            top: -4px;
            left: -4px;
            width: 5px;
            height: 5px;
            border-radius: 50%;
            background-color: red;
            box-shadow: 0 0 5px 5px red,
                inset 0 0 2px 2px red;
            animation: 3s move linear infinite;
        }

        @keyframes move {

            0%,
            100% {
                left: 24px;
                top: -4px;
            }

            25%,
            75% {
                top: -4px;
                left: -4px;
            }

            50% {
                top: 14px;
                left: -4px;
                box-shadow: unset;
            }
        }

        #lover {
            color: pink;
            text-decoration: line-through;
        }
        #dba{
            color: red;
        }
    </style>
</head>

<body>
    <p class="title">
        <span></span>
        友達 ◎ 以上 <span id="lover">戀人</span> <span id="dba">DBA</span> 未滿
        <span></span>
    </p>
</body>

</html>
```
