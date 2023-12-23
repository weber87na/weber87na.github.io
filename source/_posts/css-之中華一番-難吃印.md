---
title: css 之中華一番 難吃印
date: 2022-09-05 18:35:06
tags: css
---
&nbsp;
![難吃印](https://raw.githubusercontent.com/weber87na/flowers/master/eat_like_shit.png)
<!-- more -->
因為中午吃到很雷的店家 , 又剛好看到小當家裡面的難吃印 , 就趁著午休寫看看 XD
感覺很久沒寫 css 了 , 很多功能都忘得差不多 , 還好最後寫起來效果還 ok
比較特別的就這句 `writing-mode: vertical-lr;` , 可以讓字變成直的排列 
另外還順手用 animation 搞點霓虹效果 , 後來順便錄個影片 , 不過 code 不太一樣懶得改 XD

<iframe width="853" height="480" src="https://www.youtube.com/embed/b-oK70-n288" title="css 難吃印" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

<p class="codepen" data-height="745" data-default-tab="html,result" data-slug-hash="yLjVeNa" data-user="weber87na" style="height: 745px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/yLjVeNa">
  EatLikeShit</a> by weber87na (<a href="https://codepen.io/weber87na">@weber87na</a>)
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
            padding: 0;
            margin: 0;
        }

        body {
            background-color: #000;
            height: 100vh;
            display: flex;
        }

        .box {
            width: 500px;
            height: 500px;
            border-radius: 50%;
            border: 20px solid red;
            writing-mode: vertical-lr;
            display: flex;
            margin: auto;

            box-shadow:
                inset 0 0 15px #f00,
                inset 0 0 35px #f00,
                0 0 15px #f00,
                0 0 35px #f00;
            animation: box 1s alternate linear infinite;
        }
        .bottom-box{
            position: fixed;
            bottom: 0;
            left: 0;
            right: 0;
            font-family: '標楷體';
            margin: auto;
            color: #fff;
            font-size: 96pt;
            text-align: center;
            vertical-align: middle;
            /* letter-spacing: .5em; */
            text-shadow:
                0 0 15px #fff,
                0 0 35px #fff;
        }

        .text {
            font-family: '標楷體';
            margin: auto;
            color: red;
            font-size: 172pt;
            text-align: center;
            vertical-align: middle;
            text-shadow:
                0 0 15px #f00,
                0 0 35px #f00;
            animation: text 1s alternate linear infinite;
        }

        @keyframes box {
            to {
                box-shadow:
                    inset 0 0 25px #f00,
                    inset 0 0 45px #f00,
                    0 0 25px #f00,
                    0 0 45px #f00;
            }
        }

        @keyframes text {
            to {
                text-shadow:
                    0 0 25px #f00,
                    0 0 45px #f00;
            }
        }
    </style>
</head>

<body>
    <div class="box">
        <div class="text">
            難吃
        </div>
    </div>
    <div class="bottom-box">
        難吃印
    </div>

</body>

</html>
```
