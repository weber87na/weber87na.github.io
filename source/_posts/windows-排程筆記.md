---
title: windows 排程筆記
date: 2025-04-21 03:34:46
tags:
---
&nbsp;
<!-- more -->

好多年沒在 windows 上面搞排程, 自己建 `serilog` 沒有正常寫入到該出現的地方, 整個耍腦筆記下踩到的雷

首先 `win + r` 輸入 `taskschd.msc` 打開排程檢視, 或是 `win + s` 輸入 `工作排程器` 即可
接著先選到 `工作排程器程式庫` 建立一個資料夾, 這裡用 `Demo`

然後點選 `Demo` => `右鍵` => `建立工作` => `一般` 敲入名稱 => 如果有特殊需求要用較高的權限需要勾選 `以最高權限執行`
另外最好選擇 `不論使用者登入與否均執行` 這樣才不會有問題
接著切到 `觸發程序` => `新增` 選想要的時間即可
切到 `動作` => `新增` => `程式或指令碼` 輸入要執行的程式名稱 => 重點要選 `開始位置` 跟剛剛輸入的程式名稱同資料夾底下即可, 沒選的話就會踩到雷 XD

以下是我 `serilog` 設定, 他的 `path` 設定為 `logs/log-.txt`, 可是這樣會 gg, 因為會寫到 `C:\Windows\System32\Logs` 底下 @. @
可以參考這個[說明](https://stackoverflow.com/questions/28407236/serilog-or-any-loggers-does-not-create-file-from-task-scheduler-but-creates-from)

```
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information",
      "Override": {
        "Microsoft": "Warning",
        "System": "Warning"
      }
    },
    "WriteTo": [
      { "Name": "Console" },
      {
        "Name": "File",
        "Args": {
          "path": "logs/log-.txt",
          "rollingInterval": "Day",
          "outputTemplate": "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj}{NewLine}{Exception}"
        }
      }
    ]
  }
```
