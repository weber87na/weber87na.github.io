---
title: css 人物登出
date: 2022-09-13 18:41:38
tags: css
---
&nbsp;
![登出](https://raw.githubusercontent.com/weber87na/flowers/master/sign_out.png)
<!-- more -->

最近上課 & 上班快要登出 , 就順手寫看看 , 一樣沙雕的登出 style XD
要留意的點就是 	`*::before{box-sizing}` 的部分 , 想說 `before` 寫半天都沒法對準父層

<p class="codepen" data-height="500" data-default-tab="html,result" data-slug-hash="QWrGjBL" data-user="weber87na" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/QWrGjBL">
  Sign Out</a> by weber87na (<a href="https://codepen.io/weber87na">@weber87na</a>)
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
            margin: 0;
            padding: 0;
            font-family: '微軟正黑體';
        }

        *::before,
        *::after {
            box-sizing: border-box;
            ;
        }

        body {
            display: flex;
            height: 100vh;
            align-items: center;
            justify-content: center;
            background-color: #000;
            overflow: hidden;
        }

        .wrap {
            width: 250px;
            height: 250px;
            border-radius: 50%;
            border: 10px solid white;
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .wrap span {
            position: absolute;
            top: 0;
            left: 0;
        }

        .ring {
            width: 100px;
            height: 30px;
            border-radius: 50%;
            border: solid 10px yellow;
            box-shadow:
                0 0 20px yellow,
                inset 0 0 20px yellow;
            position: absolute;
            top: 20px;
            left: 0;
            right: 0;
            margin: 0 auto;
        }

        .person {
            width: 200px;
            height: 200px;
            /* background-color: red; */
            /* border: 5px solid #fff; */
            /* border-radius: 50%; */
            position: relative;
            box-sizing: content-box;
            overflow: hidden;
            animation: smoky 3s;
        }

        .person::before {
            content: '';
            position: absolute;
            top: 50%;
            left: 50%;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            border: 10px solid white;
            border-color: white white transparent white;
            transform: translate(-50%, -50%);
        }

        .person::after {
            content: '';
            width: 150px;
            height: 180px;
            border-radius: 40%;
            border: 10px solid white;
            position: absolute;
            bottom: -120px;
            left: 0;
            right: 0;
            margin: 0 auto;
        }

        .text {
            position: absolute;
            margin: 0 auto;
            text-align: center;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            color: white;
            font-size: 36px;
            font-weight: bold;
            cursor: hand;
            text-align: center;
            text-shadow: 0 0 0 whitesmoke;
        }

        @keyframes smoky {
            to{
                transform:
                    translate3d(200px, -80px, 0) rotate(-40deg)  skewY(10deg)scale(1.5);
                text-shadow: 0 0 20px whitesmoke;
                opacity: 0;
            }
        }
    </style>
</head>

<body>
    <div class="wrap">
        <div class="person">
            <div class="text">G</div>
            <div class="ring"></div>
        </div>
    </div>
</body>

</html>
```
