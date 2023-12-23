---
title: iframe 筆記
date: 2022-12-30 00:33:18
tags: js
---
&nbsp;
<!-- more -->
下午遇到同事的問題 , 下午了腦子當機喪失判斷能力 , 晚上補眠後看看
自己非常不喜歡用 iframe , 可是老系統一堆 iframe , 每年三不五時就遇到 iframe 爆炸 , 這次就手做幾個 iframe 之間傳遞變數及呼叫 function 的 lab 看看

### scope 問題
同事遇到的問題他用以下片段放在 child 的 iframe 內 , 希望父層可以呼叫到

`child`
```
const constqq = () => {
	console.log('constqq')
}
```

當下的直覺就是先用 `window.frames[0]` 得到 iframe 物件 , 接著直接呼叫變數應該就收工了吧 , 結果噴下面 error , 其實這是 scope 問題

`parent`
```
var child = window.frames[0]
child.constqq()
//Uncaught TypeError: child.constqq is not a function
```

如果直接改用 `var` `function` 就可以讓 `window` 得到他們 , 可是 `let` `const` 的 `scope` 是沒辦法低

`child`
```
var varqq = () => {
	console.log('varqq')
}

function fnqq(){
	console.log('fnqq')
}

const constqq = () => {
	console.log('constqq')
}

let letqq = () => {
	console.log('letqq')
}
```

`parent`
```
var child = window.frames[0]
child.varqq()
child.fnqq()

//Uncaught TypeError: child.letqq is not a function
//child.letqq()

//Uncaught TypeError: child.constqq is not a function
//child.constqq()
```

這裡又好奇如果多擺個 `script` 會有啥變化 , 反正不要在 `window` 的 `scope` 還是可以正常 work
`child`
```
console.log('start')

//這四個都正常執行
varqq()
fnqq()
letqq()
constqq()

//這兩個 scope 才會讓 window 吃到
window.varqq()
window.fnqq()

//Uncaught TypeError: window.letqq is not a function
//window.letqq()

//Uncaught TypeError: window.constqq is not a function
//window.constqq()

console.log('done')
```

### child 取得 parent 變數
鐵定會把變數改爛的做法

`parent`
```
var money = 300;
```

`child`
```
var btnVar = document.querySelector('#btn-var');
btnVar.addEventListener('click', function(){
	console.log('取得爸爸的變數' , window.parent.money)
})
```

### 執行順序問題
接著又遇到很經典的問題 , 以前也遇過 , 如果在 `DOMContentLoaded` 事件裡面撈 `iframe` 會怎樣呢 , 答案就是大爆炸
`parent`
```
//因為是這個文件 ready 可是 iframe 尚未 ready
document.addEventListener("DOMContentLoaded", function(){
	//Uncaught TypeError: child.varqq is not a function
	var child = window.frames[0]
	child.varqq()
}); 
```

看老外的作法就是擺個 `onload` , 範例就正常了

`parent`
```
//https://stackoverflow.com/questions/9249680/how-to-check-if-iframe-is-loaded-or-it-has-a-content
document.querySelector('iframe').onload = function(){
	console.log('iframe loaded');
	var child = window.frames[0]
	child.varqq()
	child.fnqq()

	//Uncaught TypeError: child.letqq is not a function
	//child.letqq()

	//Uncaught TypeError: child.constqq is not a function
	//child.constqq()
};
```


### postMessage 傳遞變數
這個算是比較潮的作法 , 以前應該沒這東西 , 寫得時候要注意下 , 一沒搞好就造成遞迴 , 詳細可以參考[這裡](https://developer.mozilla.org/zh-CN/docs/Web/API/Window/postMessage)
後來還發現可以直接呼叫 function 真是[噁心](https://stackoverflow.com/questions/11005223/how-to-execute-a-function-through-postmessage) , 不過應該沒人這樣搞

`parent`
```
window.addEventListener('message', function(e){
	console.log(e)
	e.source.postMessage('爸爸回傳給孩子' , e.source.origin)
}, false)
```

`child`
```
var btn = document.querySelector('#btn');
btn.addEventListener('click', function(){
	window.parent.postMessage('孩子傳給爸爸' , '*')
})

//孩子接收事件
window.addEventListener('message', function(e){
	console.log(e)
	//這裡要小心如果你又回傳的話會造成遞迴
	//e.source.postMessage('孩子又傳給爸爸來個遞迴' , e.source.origin)
}, false)
```


### parent code
```
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Document</title>
</head>
<body>
    <p>Parent</p>

    <iframe src="child.html" frameborder="0"></iframe>
    <script>
        //爸爸接收事件
        window.addEventListener('message', function(e){
            console.log(e)
            e.source.postMessage('爸爸回傳給孩子' , e.source.origin)
        }, false)

        var money = 300;
    </script>

    <script>
        //因為是這個文件 ready 可是 iframe 尚未 ready
        document.addEventListener("DOMContentLoaded", function(){
            //Uncaught TypeError: child.varqq is not a function
            var child = window.frames[0]
            child.varqq()
        }); 
        
        //https://stackoverflow.com/questions/9249680/how-to-check-if-iframe-is-loaded-or-it-has-a-content
        document.querySelector('iframe').onload = function(){
            console.log('iframe loaded');
            var child = window.frames[0]
            child.varqq()
            child.fnqq()

            //Uncaught TypeError: child.letqq is not a function
            //child.letqq()

            //Uncaught TypeError: child.constqq is not a function
            //child.constqq()
        };
    </script>
</body>
</html>
```


### child code
```
<html lang="zh-Hant">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
    <title>Document</title>
</head>
<body>
    <p>Child</p>
    <button id="btn">傳遞變數給爸爸</button>
    <button id="btn-var">取得爸爸的變數</button>
    <script>
        var btn = document.querySelector('#btn');
        btn.addEventListener('click', function(){
            window.parent.postMessage('孩子傳給爸爸' , '*')
        })

        var btnVar = document.querySelector('#btn-var');
        btnVar.addEventListener('click', function(){
            console.log('取得爸爸的變數' , window.parent.money)
        })

        //孩子接收事件
        window.addEventListener('message', function(e){
            console.log(e)
            //這裡要小心如果你又回傳的話會造成遞迴
            //e.source.postMessage('孩子又傳給爸爸來個遞迴' , e.source.origin)
        }, false)

        var varqq = () => {
            console.log('varqq')
        }

        function fnqq(){
            console.log('fnqq')
        }

        const constqq = () => {
            console.log('constqq')
        }

        let letqq = () => {
            console.log('letqq')
        }


    </script>
    <script>
        console.log('start')

        //這四個都正常執行
        varqq()
        fnqq()
        letqq()
        constqq()

        //這兩個 scope 才會讓 window 吃到
        window.varqq()
        window.fnqq()

        //Uncaught TypeError: window.letqq is not a function
        //window.letqq()

        //Uncaught TypeError: window.constqq is not a function
        //window.constqq()

        console.log('done')
    </script>
</body>
</html>
```
