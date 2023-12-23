---
title: css 愛心效果
date: 2022-09-07 18:52:27
tags: css
---
![css 愛心效果](https://raw.githubusercontent.com/weber87na/flowers/master/iloveu_heart.png)
<!-- more -->

因為上課還是要練習低 ~ 心血來潮寫看看愛心效果
反正就是利用 before & after 插在正方形的任意兩側 , 然後利用 transform rotate 旋轉大概就做出來了 XD ~

<p class="codepen" data-height="650" data-default-tab="html,result" data-slug-hash="xxjRwmL" data-user="weber87na" style="height: 650px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/xxjRwmL">
  Heart</a> by weber87na (<a href="https://codepen.io/weber87na">@weber87na</a>)
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
        }

        body {
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            margin: auto;
            background-color: #000;



        }

        .wrap {
            /* From https://css.glass */
            width: 500px;
            height: 500px;
            background: rgba(255, 255, 255, 0.2);
            /* background-color: #fff; */
            /* box-shadow: inset -300px 0 300px hotpink; */


            border-radius: 50%;
            /* box-shadow: 0 4px 30px rgba(0, 0, 0, 0.1); */
            backdrop-filter: blur(5px);
            -webkit-backdrop-filter: blur(5px);
            border: 1px solid rgba(255, 255, 255, 0.3);
            display: flex;
            align-items: center;
            justify-content: center;
            animation: 60s turn linear infinite;
            position: relative;
            /* overflow: hidden; */
        }

        @keyframes turn {
            to {
                transform: rotateY(-1turn);
            }
        }

        .text {
            color: #fff;
            text-shadow: 0 0 50px #fff;
            transform: rotate(10deg);
            position: absolute;
            bottom: 20%;
            font-size: 72pt;
            z-index: -1;
        }

        .heart {
            height: 60px;
            width: 60px;
            background-color: hotpink;
            position: relative;
            transform: rotate(45deg);
            box-sizing: content-box;
        }

        .heart:nth-child(1) {
            animation: 3s move linear infinite;
            background-color: red;
        }

        .heart:nth-child(1)::before {
            background-color: red;
        }

        .heart:nth-child(1)::after {
            background-color: red;
        }

        .heart:nth-child(2) {
            animation: 5s move2 linear infinite;
        }

        .heart:nth-child(3) {
            animation: 4s move3 linear infinite;
        }

        .heart:nth-child(4) {
            animation: 7s move4 linear infinite;
        }

        .heart:nth-child(5) {
            animation: 2s move5 linear infinite;
        }

        .heart::before {
            content: '';
            position: absolute;
            height: 60px;
            width: 60px;
            top: 0;
            left: -30px;
            border-radius: 50%;
            background-color: hotpink;
        }

        .heart::after {
            content: '';
            position: absolute;
            height: 60px;
            width: 60px;
            top: -30px;
            left: 0px;
            border-radius: 50%;
            background-color: hotpink;
        }

        @keyframes move5 {
            to {
                transform: scale(0.8) rotate(130deg);
                opacity: 0.4;
            }
        }

        @keyframes move4 {
            to {
                transform: scale(1.8) rotate(80deg);
                opacity: 0.3;
            }
        }

        @keyframes move3 {
            to {
                transform: scale(0.5) rotate(150deg);
                opacity: 0.4;
            }
        }

        @keyframes move2 {
            to {
                transform: scale(1.1) rotate(130deg);
                opacity: 0.3;
            }
        }

        @keyframes move {
            to {
                opacity: 0.5;
                transform: scale(1.5);
            }
        }
    </style>
</head>

<body>
    <div class="wrap">
        <div class="heart"></div>
        <div class="heart"></div>
        <div class="heart"></div>
        <div class="heart"></div>
        <div class="heart"></div>
        <div class="text">I Love U</div>
    </div>
</body>

</html>
```
