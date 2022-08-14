---
title: fzf 在 git bash for windows 使用
date: 2021-01-02 09:18:54
tags: fzf
---
&nbsp;
![terminal](https://raw.githubusercontent.com/weber87na/flowers/master/terminal.png)
<!-- more -->

由於需要維護大型專案，很多功能都是接手其他人的在 visual studio 裡面的全局查詢又不太好用，常常開了就當在那邊
想說研究看看能否讓 [fzf](https://github.com/junegunn/fzf#windows) 在 windows 跑看看，沒想到在 windows 的 cmd正常運作，一使用 git bash for windows 就直接陣亡
試著嘗試在 ~/.bashrc 底下加入 alias 也是陣亡
```
alias fzf='winpty fzf.exe'
```
就在快放棄的時候偶然看到這個 [with](https://github.com/jesse23/with) 設定好後還真的可以 work 感動~
如果需要修改 fzf 的 config 可以在 `with.bat` 內修改
```
set FZF_DEFAULT_OPTS=--border --inline-info --bind=alt-j:down,alt-k:up
```

後來發現一個 vim style 且可以直接在 windows 上跑的 file manager [lf](https://github.com/gokcehan/lf) 
類似這類的還有，不過好像沒半個可以在 windows 上跑的 @__@+
* [ranger](https://github.com/ranger/ranger)
* [nnn](https://github.com/jarun/nnn)
* [fff](https://github.com/dylanaraps/fff)

基本操作可以看這份[文件](https://godoc.org/github.com/gokcehan/lf) or [教學](https://github.com/gokcehan/lf/wiki/Tutorial)
也可以看這個 youtuber [介紹](https://www.youtube.com/watch?v=EGBEIb2DgtQ)比較有感
想在 git bash 裡面使用不免俗要加上這段在 ~/.bashrc 裡面
```
alias lf='winpty lf.exe'
```
老樣子需要讓他 reload
```
source ~/.bashrc
```
