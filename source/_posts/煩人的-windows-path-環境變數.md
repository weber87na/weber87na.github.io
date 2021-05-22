---
title: 煩人的 windows path 環境變數
date: 2021-01-06 04:47:07
tags: windows
---
&nbsp;
<!-- more -->

新增 windows 環境變數非常煩人，每次都要手動點一堆 GUI 按鈕，比較好一點點但是還要用 gui 的半吊子方法
```
sysdm.cpl
```
在 windows 10 底下有個 pathman 可以使用，原來這麼無腦就可以解決，注意要加到系統環境變數又要用 admin 執行，暈
```
pathman /au d:\gg
pathman /as d:\gg
```

不過 pathman 一到 windows 7 底下就失效了，因此找到這[解法](https://superuser.com/questions/268287/adding-path-with-setx-or-pathman-or-something-else)，不過需要系統管理員執行，這裡特別注意環境變數會有 2048 限制的這種低能問題，隨便都超過鄉民 30 公分
```
setx /M path "C:\gg;%path%"
```
上面這個命令很危險可能會直接讓現有的環境變數直接陣亡，不小心用了以後常用的 git 跟 windows terminal 都 gg 了可以在以下路徑找回來
```
windows terminal
C:\Users\YourName\AppData\Local\Microsoft\WindowsApps

git
C:\Program Files\Git\cmd
or
C:\Program Files(x86)\Git\cmd
```

環境變數太長了整個 gg 可以看保哥這篇[文章](https://blog.miniasp.com/post/2015/09/07/Maximum-length-of-PATH-environment-variable)，感恩保哥真是神
順便筆記一下檢查垃圾 path 用的 validatepath.bat [感恩老外](https://stackoverflow.com/questions/7337794/how-to-check-if-directories-listed-in-system-path-variable-are-valid)
```
@echo off
setlocal DisableDelayedExpansion
set "var=%PATH%"

set "var=%var:"=""%"
set "var=%var:^=^^%"
set "var=%var:&=^&%"
set "var=%var:|=^|%"
set "var=%var:<=^<%"
set "var=%var:>=^>%"

set "var=%var:;=^;^;%"
rem ** This is the key line, the missing quote is intention
set var=%var:""="%
set "var=%var:"=""%"

set "var=%var:;;="";""%"
set "var=%var:^;^;=;%"
set "var=%var:""="%"
set "var=%var:"=""%"
set "var=%var:"";""=";"%"
set "var=%var:"""="%"

setlocal EnableDelayedExpansion
for %%a in ("!var!") do (
    endlocal
    call :testdir "%%~a"
    setlocal EnableDelayedExpansion
)
goto :eof

:testdir
if exist %1 echo OK:  %1
if not exist %1 echo NOK: %1
```
