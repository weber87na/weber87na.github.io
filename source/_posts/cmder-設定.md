---
title: cmder 設定
date: 2020-11-15 16:55:29
tags: cmder
---
&nbsp;
![terminal](https://raw.githubusercontent.com/weber87na/flowers/master/terminal.png)
<!-- more -->

由於工作的關係，公司發派的環境為 win7，在沒有 wsl 底下猶如斷手斷腳，只好找到這套 [cmder](https://cmder.net/)
整體用下來體驗感還滿不錯的，甚至也可以在裡面直接開啟 wsl，不過 vim 有些顯示怪怪的!
注意他有分 git 版本跟 mini 版本，由於工作的環境上已經有 git 就直接下 mini 的版本即可，
話說為何 git bash 顏色為何那麼醜呢，如果可以好看一點就不用這樣大費周章裝一堆有的沒的。
基本上無腦下載完放到 c:\ 底下即可，看看要不要加入環境變數方便快速啟動，基本上建議加入，輸入cmder即可啟動
本來想切 HOME 目錄發現不能直接使用波浪號 ~ ，在 windows 底下需使用 %userprofile% 進行切換還是有點差異

這套 cmder 也可以使用 [powerline](https://github.com/AmrEldib/cmder-powerline-prompt)來進行美化這樣跟之前用 wsl 的體驗感基本一致
把 .lua 複製到 config 資料夾底下即可，注意字型需要用 [Fira Code](https://github.com/tonsky/FiraCode)，字體大小設定 24

將 lambda 符號換成 $ ，這個搞超久
如果沒安裝 powerline 的話直接修改 vendor/clink.lua 底下的 lambda 符號為 $ 即可
有裝 powerline 的話修改 config/powerline_core.lua 找到 closePrompt 函數修正為以下片段即可
```
function closePrompt()
	clink.prompt.value = clink.prompt.value..newLineSymbol.."$ "
end
```

老樣子由於眼睛沒辦法在黑底跟白底間切換，設定綠底
setting => general => scheme => ubuntu 
features => colors => 在 0 設定綠豆沙色 239 255 239 => 在 7 跟 15 設定黑色字 0 0 0

熱鍵筆記
C => Control => ctrl
M => Meta => alt

ctrl + a 移動到開頭 (Home)
ctrl + e 移動到結尾 (End)
ctrl + b 左移 (->)
ctrl + f 右移 (<-)
alt + b 左移一個單字
alt + f 右移一個單字
ctrl + l 清空畫面 (clear)
ctrl + w 刪除一個單字
ctrl + k 刪除到句尾 (vim 的 d$)
ctrl + u 刪除到句首 (vim 的 d0)
alt + d 往前刪除單字
ctrl + h 往左刪除 (backspace)
ctrl + d 刪除目前的位置 (vim 的 x)

參考資料
[保哥](https://blog.miniasp.com/post/2015/09/27/Useful-tool-Cmder)
[https://zellwk.com/blog/windows-wsl/](https://zellwk.com/blog/windows-wsl/)
