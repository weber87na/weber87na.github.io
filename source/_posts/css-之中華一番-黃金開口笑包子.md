---
title: css 之中華一番 黃金開口笑包子
date: 2022-09-05 18:42:23
tags: css
---
![黃金開口笑包子](https://raw.githubusercontent.com/weber87na/flowers/master/bun.png)
<!-- more -->

剛好看到不斷重播的中華一番 , 乃哥對決羅根 , 心血來潮也來還原看看 XD
太久沒寫 , 做得有點沙雕 , 不過本來風格就是沙雕 , 有空時在做點油之類的特效好了

<p class="codepen" data-height="400" data-default-tab="html,result" data-slug-hash="NWMbvEb" data-user="weber87na" style="height: 400px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/NWMbvEb">
  Bun</a> by weber87na (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

```
<!DOCTYPE html>
<html lang="zh-tw">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible"
        content="IE=edge">
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0">
    <title></title>
    <style>
        * {
            margin: 0;
            padding: 0;
        }

        body {
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100vh;
            overflow: hidden;
            background-color: rgb(255, 241, 159);
        }



        .box {
            width: 500px;
            height: 300px;
            background-color: gold;
            border-radius: 50%;
            position: relative;
            animation: 4s move infinite;
        }

        .mouth-warp {
            /* border: 1px solid red; */
            position: absolute;
            width: 400px;
            height: 100px;
            bottom: 20px;
            left: calc(50% - 400px / 2);
            overflow: hidden;
        }

        .mouth {
            position: absolute;
            bottom: 60%;
            left: calc(50% - 400px / 2);
            width: 400px;
            height: 100px;
            border-radius: 50%;
            background-color: #000;
        }

        .title {
            /* border: 1px solid; */
            position: absolute;
            transform: rotate(25deg);
            top: 20%;
            left: -35%;
        }

        .title span:nth-child(1) {
            font-size: 72pt;
        }

        .title span:nth-child(2) {
            font-size: 36pt;
        }

        .title span:nth-child(3) {
            font-size: 18pt;
        }


        @keyframes move {

            0%,
            100% {
                transform: rotateZ(0deg);
            }

            20%,
            60% {
                transform: rotateZ(5deg);
            }

            40%,
            80% {
                transform: rotateZ(-5deg);
            }
        }
    </style>
</head>

<body>
    <div class="box">
        <div class="mouth-warp">
            <div class="mouth"></div>
        </div>
        <h2 class="title">
            <span>ㄤ</span>
            <span>ㄤ</span>
            <span>ㄤ</span>
        </h2>
    </div>
</body>


</html>
```
