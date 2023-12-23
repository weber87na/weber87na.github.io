---
title: rxjs 筆記
date: 2022-11-16 01:46:10
tags:
- angular
- js
- rxjs
---

&nbsp;
<!-- more -->

因為工作用 angular , 裡面有一狗票 rxjs 不得不學 , 搞到現在覺得比較像學 rxjs 不是 angular XD

### pipe
`pipe` => 管線函數

如果有學過 sql 的子查詢應該會從裡面開始讀 , 而不是由上到下 , 讀起來其實有點累
正常用 js/ts 寫起來大概會長這樣 , 需要由內的 fq 開始讀 => 再拓展到外的 lasai
```
let str = 'gg'

function lasai(str){
    return 'lasai' + str
}

function fq(str){
    return 'fq' + str
}

let result = lasai(fq(str))
console.log(result)

//印出
//lasaifqgg
```

`pipe` 就是用來解決這種需要由內讀到外的問題 , 讓 code 由上到下閱讀
```
const source$ = new Subject()

let res$ = source$.pipe(
    map(x => fq(x)),
    map(x => lasai(x)),
)
res$.subscribe(x =>{
    console.log(x)
})

source$.next(str)
```

### tap
`tap` => 處理副作用函數 , 一般拿來印個 log 看現在做了啥 , 應該也可以搭個 dir or table 之類的
```
const source$ = new Subject()

let res = source$.pipe(
    tap(x => console.log('start ' + x)),
    map(x => 'fq' + x),
    tap(x => console.log('after fq ' + x)),
    map(x => 'lasai' + x),
    tap(x => console.log('after lasai ' + x)),
)
res.subscribe(x=>{
    console.log(x)
})

source$.next(str)
```


### of
最簡單把目前的咚咚轉 Observable 應該就是用 `of` or `from` 非 array 應該都會用 `of`
```
of('g' , 'gg' , 'ggg').subscribe( x => console.log(x))
//g
//gg
//ggg

of(['g' , 'gg' , 'ggg']).subscribe( x => console.log(x))
//['g' , 'gg' , 'ggg']
```


### from
一樣可以用來轉換咚咚為 Observable , 是 array 應該都會用 from
```
from(['g' , 'gg' , 'ggg']).subscribe( x => console.log(x))
//g
//gg
//ggg
```


### fromEvent
用來轉換 js event

```
let btn = document.getElementById('btn') as HTMLButtonElement

fromEvent(btn , 'click')
.subscribe(event => {
    console.log(event)
})
```


### range
產生範圍內的數字 , 不得不拿出無敵的 [99 乘法表]()
```
let A$ = range(1, 9)
let B$ = range(1, 9)

A$.subscribe(x => {
    console.log(`----${x}-----`)
    B$.subscribe(y =>
        console.log(`${x} * ${y} = ${x * y}`)
    )
    console.log('----------')
})
```


### 有用資源
* [rxjs 水果網站](https://www.rxjs-fruits.com/subscribe)
* [rxjs 水果網站 解答](https://github.com/Troy96/rxjs-fruits-solutions/blob/master/index.js)
* [官網](https://rxjs.dev/api)
