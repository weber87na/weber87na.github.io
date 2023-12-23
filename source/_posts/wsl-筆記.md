---
title: wsl 筆記
date: 2022-08-22 01:18:57
tags: wsl
---
&nbsp;
<!-- more -->

因為常用 wsl 有時候又會不小心忘記一些細節 , 索性筆記下 , 詳細可以參考[官網](https://docs.microsoft.com/zh-tw/windows/wsl/install)

### 安裝
列出可以從網路上安裝的 linux
```
wsl --list --online

NAME            FRIENDLY NAME
Ubuntu          Ubuntu
Debian          Debian GNU/Linux
kali-linux      Kali Linux Rolling
openSUSE-42     openSUSE Leap 42
SLES-12         SUSE Linux Enterprise Server v12
Ubuntu-16.04    Ubuntu 16.04 LTS
Ubuntu-18.04    Ubuntu 18.04 LTS
Ubuntu-20.04    Ubuntu 20.04 LTS
```

安裝指定版本的 linux
```
wsl --install --distribution Ubuntu-18.04
```

列出目前有的 instance
```
wsl --list
Ubuntu (預設值)
Ubuntu-18.04
```

啟動指定的 instance
```
wsl -d Ubuntu-18.04
```

刪除 instance
```
wsl --unregister Ubuntu-18.04
```


### 版本 & 狀態

如果你之前的 ubuntu 是 `wsl1` 要升上 `wsl2` 可以用下面這句
```
wsl.exe --set-version Ubuntu 2
```

若不確定版本可以這樣看詳細訊息
```
wsl --list -v
```


如果想直接讓安裝 `wsl` 預設就是 `wsl2` 可以直接這樣下
```
wsl.exe --set-default-version 2
```

看目前 wsl 狀態
```
wsl --status
```

### 有趣用法

有趣用法 , 直接在 powershell 上面對 wsl 進行操控 , 像這樣可以直接列出我 ubuntu 裡面的檔案
```
wsl ls ~
Anaconda3-2022.05-Linux-x86_64.sh  anaconda3  blog
```

在 windows 上如果需要從 wsl 裡面撈檔案出來的話 , 可以這樣進去找
```
\\wsl$\Ubuntu
\\wsl$\Ubuntu\home\
```

你在 windows 上的位置
```
/mnt/c/Users/yourname
```

如果在 wsl 內想用 windows 檔案總管導覽某個目錄可以直接這樣下 , 萬一不 work 可以參考[這篇](https://stackoverflow.com/questions/63753322/opening-the-file-explorer-from-wsl2-debian)
```
explorer.exe .
```

如果不想一開始在 `/mnt/c/Users/yourname` 底下的話 , 想要直接在 linux home 目錄可以這樣下
```
wsl --cd ~
```

### gui
如果想在 wsl 裡面有 gui 的話可以參考這兩篇 , 我自己用起來的體驗是不大好 , 需要 gui 可能還是裝 vm 比較優
[Xfce](https://github.com/QMonkey/wsl-tutorial/blob/master/README.wsl2.md) , 這個我有跑起來
[GNOME](https://gist.github.com/Ta180m/e1471413f62e3ed94e72001d42e77e22) , 我 try 這個失敗不曉得為啥
懶得裝[vsxsrv](https://sourceforge.net/projects/vcxsrv/) 的話可以參考[GWSL](https://opticos.github.io/gwsl/) , 用起來更無腦一點

他 gui 可以自己幫你加上這些參數在 `~/.bashrc` 你也可以自己手動加 , 我自己試玩 GNOME 就跟老外噴的錯誤一樣滿多問題 , 最後也失敗
```
export DISPLAY=:0.0  #GWSL
export PULSE_SERVER=tcp:localhost #GWSL
export LIBGL_ALWAYS_INDIRECT=1 #GWSL
```

### 匯入
最後玩看看匯入 wsl 的功能 , 要自己做的話好像挺麻煩的 , 這裡下載 [alpinelinux](https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-minirootfs-3.16.2-x86_64.tar.gz) , 注意要先解壓成 `tar` , 詳細可以參考[這個影片](https://www.youtube.com/watch?v=KtN6sNJlQrA)
```
mkdir c:\alpine

wsl --import alpine c:\alpine C:\Users\TF200119\Downloads\alpine-minirootfs-3.16.2-x86_64.tar
wsl

#更新並且安裝 curl
apk update
apk upgrade
apk add curl
```
