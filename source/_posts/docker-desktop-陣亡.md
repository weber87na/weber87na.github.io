---
title: docker desktop 陣亡
date: 2024-09-03 01:38:46
tags: docker
---

&nbsp;
<!-- more -->

我 windows 的 docker desktop 已經停擺許久, 最近剛好講師的環境是用 sql server on linux 的 image
印象中幾年前有稍微玩過, 好像也是有些雷

於是乎又要在 windows 上用 docker 起初我安裝的版本是目前最新的 4.34 , 不過馬上噴這個錯誤

wsl update failed: update failed: updating wsl: exit code: 4294967295: running WSL command wsl.exe C:\WINDOWS\System32\wsl.exe --update --web-download

後來看這裡 一堆老外也遇到 一樣的問題
https://github.com/docker/for-win/issues/14022

就跟著降版看看, 可以選 4.28.0.0
https://docs.docker.com/desktop/release-notes/

可是安裝完後還是陣亡, 這次噴
Docker Desktop - WSL update failed

最後看到 強國人 用個粗暴好用的方法(一樣用 4.28.0.0)
他先解除安裝, 然後不勾 WSL, 就正常了, 接著再勾起 WSL, 直接搞定
最後執行, 灑花, 最後又發現, 重開後又掛了 真是垃圾 ~ 我最後結論就是, 升級最新版吧 lol ~ 不然就用 linux ~

```
wsl -l -v
  NAME                   STATE           VERSION
* Ubuntu                 Running         2
  docker-desktop-data    Running         2
  docker-desktop         Running         2
```
