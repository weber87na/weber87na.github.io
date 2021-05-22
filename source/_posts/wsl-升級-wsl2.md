---
title: wsl 升級 wsl2
date: 2020-08-03 11:16:33
tags:
- wsl
---
&nbsp;
<!-- more -->
升級 wsl 到 wsl2
參考官方說明
https://docs.microsoft.com/zh-tw/windows/wsl/install-win10

``` powershell
#需要切換至 sudo
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
wsl --set-default-version 2
```

有可能發生以下錯誤 (注意 windows 最好更新到最新版本)
錯誤: 0x1bc
到以下頁面下載
https://docs.microsoft.com/zh-tw/windows/wsl/wsl2-kernel

輸入以下命令進行 ubuntu更新
``` powershell
wsl --set-version Ubuntu-18.04 2
```

確認有無更新成功，看到 VERSION 2 就是成功了
``` powershell
wsl --list --verbose
#  NAME            STATE           VERSION
#  Ubuntu-18.04    Running         2
```

參考資料
https://blog.miniasp.com/post/2020/07/26/Multiple-Linux-Dev-Environment-build-on-WSL-2
https://samiouob.github.io/2019/06/17/WSL2/
https://www.huanlintalk.com/2020/02/wsl-2-installation.html
