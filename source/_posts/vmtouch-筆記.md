---
title: vmtouch 筆記
date: 2020-12-15 03:22:12
tags: vmtouch
---
&nbsp;
<!-- more -->

體驗 [vmtouch](https://github.com/hoytech/vmtouch) 加速
```
$ git clone https://github.com/hoytech/vmtouch.git
$ cd vmtouch
$ make
$ sudo make install
```
無腦加入目錄加速
```
vmtouch -t yourdir
```
```
無腦踢掉 vmtouch -e yourdir
```

test report
查看目錄與檔案
```
gg@gg:/mnt/c/Program Files (x86)/Google/Chrome$ vmtouch .
           Files: 276
     Directories: 15
  Resident Pages: 0/114577  0/447M  0%
         Elapsed: 0.53017 seconds
```

加入目錄與檔案
```
gg@gg:/mnt/c/Program Files (x86)/Google/Chrome$ vmtouch -t .
           Files: 276
     Directories: 15
   Touched Pages: 114577 (447M)
         Elapsed: 28.978 seconds
```

踢掉
```
gg@gg:/mnt/c/Program Files (x86)/Google/Chrome$ vmtouch -e .
           Files: 276
     Directories: 15
   Evicted Pages: 114577 (447M)
         Elapsed: 0.55052 seconds

```

vscode report wsl 有加速???? 不是很確定不過 linux 跟 mac 應該是會有
```
gg@gg:/mnt/c/Users/GG/AppData/Local/Programs/Microsoft VS Code$ vmtouch .
           Files: 1284
     Directories: 540
  Resident Pages: 0/64691  0/252M  0%
         Elapsed: 21.678 seconds
gg@gg:/mnt/c/Users/GG/AppData/Local/Programs/Microsoft VS Code$ vmtouch -t .
           Files: 1284
     Directories: 540
   Touched Pages: 64691 (252M)
         Elapsed: 16.296 seconds
```

