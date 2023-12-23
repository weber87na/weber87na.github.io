---
title: vantajs 製作經典電影片頭
date: 2022-08-25 19:25:15
tags: js
---
![火炬女神](https://raw.githubusercontent.com/weber87na/flowers/master/columbia.png)
<!-- more -->

偶然間看到超級 [日本高手](https://www.youtube.com/watch?v=u71pHOyvBp0) 用 [vantajs](https://www.vantajs.com/)
於是乎自己也玩看看 , 驚為天人的發現他的雲彩效果很像電影的片頭 , 所以順手寫看看 , 沒想到幾乎 100% 還原 XD 寫得比較沙雕一點就別太計較了 [點這裡看沙雕效果](https://raw.githubusercontent.com/weber87na/flowers/master/movie_columbia.gif)

```
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta http-equiv="X-UA-Compatible"
        content="IE=edge">
    <meta name="viewport"
        content="width=device-width, initial-scale=1.0">
    <title>🐐</title>
    <link rel="icon"
        href="data:image/svg+xml,<svg xmlns=%22http://www.w3.org/2000/svg%22 viewBox=%220 0 100 100%22><text y=%22.9em%22 font-size=%2280%22>🐐</text></svg>">

    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r121/three.min.js"></script>
    <!-- <script src="https://cdn.jsdelivr.net/npm/vanta@0.5.21/dist/vanta.waves.min.js"></script> -->
    <script src="https://cdn.jsdelivr.net/npm/vanta@0.5.21/dist/vanta.clouds.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/vanta@0.5.21/dist/vanta.clouds2.min.js"></script>

    <style>
        * {
            padding: 0;
            margin: 0;
        }

        #my-background {
            height: 100vh;
        }

        #columbia {
            position: fixed;
            bottom: 0;
            left: calc(50% - 612px / 2);
            z-index: 999999;
            height: 408px;
            width: 612px;
            background-image: url('https://raw.githubusercontent.com/weber87na/flowers/master/columbia.png');
            animation:example 10s infinite;
        }

        @keyframes example {
            0% {
                transform: scale(1);
            }

            100% {
                bottom: 200px;
                transform: scale(2);
            }
        }
    </style>

</head>

<body>
    <div id="columbia"></div>
    <div id="my-background"></div>

    <script>
        VANTA.CLOUDS({
            el: "#my-background",
            mouseControls: true,
            touchControls: true,
            gyroControls: false,
            minHeight: 200.00,
            minWidth: 200.00
        })
    </script>

    <script>
        var goat = '🐐';
        var str = '';
        var messageCounter = 1;
        var exit = 10;
        setInterval(function () {
            if (messageCounter == exit) {
                str = '';
                messageCounter = 0;
            }
            str += goat;
            document.title = str;
            messageCounter++;
        }, 1000);

    </script>
</body>

</html>
```
