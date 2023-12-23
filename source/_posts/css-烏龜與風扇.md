---
title: css 烏龜與風扇
date: 2022-09-06 18:55:48
tags: css
---
![烏龜](https://raw.githubusercontent.com/weber87na/flowers/master/turtle.png)
<!-- more -->

因為上了動畫課程 , 總是要練習一下低 , 手上的案子跟烏龜還有風扇有很大的淵源 , 就來寫看看

<p class="codepen" data-height="400" data-default-tab="html,result" data-slug-hash="ZEoBbZp" data-user="weber87na" style="height: 400px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/ZEoBbZp">
  Turtle</a> by weber87na (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>

`烏龜`
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
        }

        .turtle {
            /* width: 400px;
            height: 400px;
            position: relative; */
            /* border: 1px solid; */
        }

        .head {
            width: 50px;
            height: 60px;
            border: 1px solid;
            border-radius: 50%;
            position: absolute;
            top: calc(50% - 30px - 110px);
            left: calc(50% - 25px);
            background-color: #d4ffe2;
            transition: 1s;
        }

        .head:hover{
            background-color: pink;
            box-shadow: 0 0 50px pink;
            transition: 1s;
            transform: scale(1.2);
        }

        .head::after {
            content: '';
            position: absolute;
            width: 5px;
            height: 5px;
            top: 5px;
            right: 5px;
            border-radius: 50%;
            border: 1px solid;
            background-color: #000;
        }

        .head::before {
            content: '';
            position: absolute;
            width: 5px;
            height: 5px;
            top: 5px;
            left: 5px;
            border-radius: 50%;
            border: 1px solid;
            background-color: #000;
        }

        .shell {
            /* border: 5px solid; */
            position: absolute;
            margin: auto;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;

            border-radius: 50%;

            width: 200px;
            height: 220px;
            z-index: 10;
            background-color: rgb(16, 157, 95);
            /* background-color: rgb(0, 107, 0); */


            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 0 20px #0A0;

        }

        .shell::after {
            position: absolute;
            margin: auto;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            border-radius: 41%;
            width: 195px;
            height: 210px;
            content: '';
            border: 1px solid;
            z-index: 11;
            animation: move 5s linear infinite;
        }

        @keyframes move {
            to {
                transform: rotate(-1turn);
            }
        }

        @keyframes move2 {
            to {
                transform: rotate(90deg);
            }
        }

        .shell::before {
            position: absolute;
            margin: auto;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            border-radius: 45%;
            width: 200px;
            height: 200px;
            content: '';
            border: 1px solid;
            z-index: 11;
            animation: move2 1s linear infinite;
        }


        .text {
            margin: auto;
            font-family: '標楷體';
            color: #fff;
            font-size: 72pt;
            writing-mode: vertical-lr;
            text-align: center;
            vertical-align: middle;
            text-shadow:
                0 0 15px #fff,
                0 0 35px #fff;
        }

        .text a {
            text-decoration: none;
            color: #fff;
        }

        .foot-top-left {
            width: 30px;
            height: 50px;
            border: 1px solid;
            border-radius: 50%;
            position: absolute;
            top: calc(50% - 30px - 80px);
            left: calc(50% - 30px - 60px);
            transform: rotate(-20deg);

            background-color: #d4ffe2;
            animation: move-foot-top-left 1s alternate infinite;

        }

        @keyframes move-foot-top-left {
            to {
                transform: rotate(-33deg);
            }
        }

        .foot-top-right {
            width: 30px;
            height: 50px;
            border: 1px solid;
            border-radius: 50%;
            position: absolute;
            top: calc(50% - 30px - 80px);
            right: calc(50% - 30px - 60px);
            transform: rotate(20deg);

            background-color: #d4ffe2;
            animation: move-foot-top-right 1s alternate infinite;
        }

        @keyframes move-foot-top-right {
            to {
                transform: rotate(45deg);
            }
        }

        .foot-bottom-left {
            width: 30px;
            height: 50px;
            border: 1px solid;
            border-radius: 50%;
            position: absolute;
            bottom: calc(50% - 30px - 80px);
            left: calc(50% - 30px - 60px);
            transform: rotate(20deg);
            background-color: #d4ffe2;

            animation: move-foot-bottom-left 1s alternate infinite;
        }

        @keyframes move-foot-bottom-left {
            to {
                transform: rotate(43deg);
            }
        }

        .foot-bottom-right {
            width: 30px;
            height: 50px;
            border: 1px solid;
            border-radius: 50%;
            position: absolute;
            bottom: calc(50% - 30px - 80px);
            right: calc(50% - 30px - 60px);
            transform: rotate(-20deg);
            background-color: #d4ffe2;
            animation: move-foot-bottom-right 1s alternate infinite;
        }

        @keyframes move-foot-bottom-right {
            to {
                transform: rotate(-33deg);
            }
        }

    </style>
</head>

<body>

    <div class="turtle">
        <div class="head"></div>
        <div class="foot-top-left"></div>
        <div class="foot-top-right"></div>
        <div class="shell">
            <div class="text"
                style="z-index:999999">
                <a href="https://tortoisegit.org/"
                    target="_blank">電龜</a>
            </div>
        </div>
        <div class="foot-bottom-left"></div>
        <div class="foot-bottom-right"></div>
    </div>
</body>

</html>
```

`風扇`
![風扇](https://raw.githubusercontent.com/weber87na/flowers/master/saion.png)


<p class="codepen" data-height="500" data-default-tab="html,result" data-slug-hash="poVNjmg" data-user="weber87na" style="height: 500px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/poVNjmg">
  Fan</a> by weber87na (<a href="https://codepen.io/weber87na">@weber87na</a>)
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
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .box {
            width: 300px;
            height: 300px;
            border-radius: 50%;
            position: relative;
            /* background-color: #000; */
        }

        .box::before {
            position: absolute;
            width: 220px;
            height: 220px;
            border: 40px solid #000;
            border-radius: 25px;
            content: '';
        }


        .box-inner {
            width: 300px;
            height: 300px;
            /* background-color: #f00; */
            border-radius: 50%;
            position: relative;
            animation: 1.5s turn linear infinite;
        }
        .box::after{
            position: absolute;
            content: 'saion';
            text-align: center;
            line-height: 100px;
            font-size: 24pt;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            margin: auto;
            width: 100px;
            height: 100px;
            border-radius: 50%;
            background-color: #000;
            color: #fff;
        }


        .blade {
            width: 150px;
            height: 150px;
            font-size: 72pt;
            text-align: center;
            transform: rotate(135deg);
            position: absolute;
            top: 0;
            left: 0;
        }

        .blade2 {
            width: 150px;
            height: 150px;
            font-size: 72pt;
            text-align: center;
            transform: rotate(225deg);
            position: absolute;
            top: 0;
            right: 0;
        }

        .blade3 {
            width: 150px;
            height: 150px;
            font-size: 72pt;
            text-align: center;
            transform: rotate(45deg);
            position: absolute;
            bottom: 0;
            left: 0;
        }

        .blade4 {
            width: 150px;
            height: 150px;
            font-size: 72pt;
            text-align: center;
            transform: rotate(-45deg);
            position: absolute;
            bottom: 0;
            right: 0;
        }

        @keyframes turn {
            to {
                transform: rotate(-1turn);
            }
        }
    </style>
</head>

<body>
    <div class="box">
        <div class="box-inner">
            <div class="blade">💩</div>
            <div class="blade2">💩</div>
            <div class="blade3">💩</div>
            <div class="blade4">💩</div>
        </div>
    </div>
</body>

</html>
```
