---
title: css 自幹 autocomplete
date: 2022-09-07 18:38:42
tags: css
---
![autocomplete](https://raw.githubusercontent.com/weber87na/flowers/master/autocomplete.png)

<!-- more -->

因為要做搜尋功能 , 又覺得預設的搜尋很難用 , 專案也比較老 , 不太有套件可以直接插上去
所以決定自幹看看 , 比較特別的點就是希望可以在 `input` 為 `focus` 狀態下 , 點到的選項才顯示
然後就踩到雷 , 如果沒加上 `active` 這個狀態的話 , 點下去就直接失去 `focus`
另外自訂自己的 autocomplete 預設 chrome 會在 input 送你之前搜尋過的東西 , 所以要設定 `autocomplete="off"`
code 老樣子還是沙雕沙雕的 style


<p class="codepen" data-height="300" data-default-tab="html,result" data-slug-hash="abGByaj" data-user="weber87na" style="height: 300px; box-sizing: border-box; display: flex; align-items: center; justify-content: center; border: 2px solid; margin: 1em 0; padding: 1em;">
  <span>See the Pen <a href="https://codepen.io/weber87na/pen/abGByaj">
  CSS Auto Complete</a> by weber87na (<a href="https://codepen.io/weber87na">@weber87na</a>)
  on <a href="https://codepen.io">CodePen</a>.</span>
</p>
<script async src="https://cpwebassets.codepen.io/assets/embed/ei.js"></script>


```
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Document</title>
    <style>
        input{
            position: relative;
        }
        input::before{
            position: absolute;
            width: 100%;
            height: 100%;
            border-radius: 39%;
            border: 1px solid;
            content: '';
        }
        
        .autocomplete{
            width: 300px;
            height: 300px;
            border: 1px solid;
            display: none;
            position: relative;
            border-radius: 46%;
        }
        .autocomplete::before{
            content: '';
            width: 300px;
            height: 300px;
            border-radius: 36%;
            top: -5px;
            right: 12px;
            border: 1px solid;
            position: absolute;
        }

        /* 這裡重點需要加上 .autocomplete:active, 不然 btn click 沒辦法被 trigger */
        .autocomplete:active,
        #qq:focus + #test:checked ~ .autocomplete{
            display: block;
        }

        #btn{
            height: 50px;
            width: 50px;
            position: absolute;
            margin: auto;
            left: 0;
            right: 0;
            top: 0;
            bottom: 0;
        }

    </style>
</head>
<body>
    <input type="text" id="qq">

    <!--用 radio 的重點就是 name 要一樣-->
    <input type="radio" name="test" id="test" checked>
    <input type="radio" name="test" id="test2">
    <input type="radio" name="test" id="test3">

    <label for="test">test</label>
    <label for="test2">test2</label>
    <label for="test3">test3</label>

    <div class="autocomplete">
        <button id="btn">沙雕</button>
    </div>

    <script>
        var btn = document.getElementById('btn');
        btn.addEventListener('click', function(){
            console.log('123')
        });
    </script>
</body>
</html>
```
