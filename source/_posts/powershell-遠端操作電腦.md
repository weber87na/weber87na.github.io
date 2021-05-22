---
title: powershell 遠端操作電腦
date: 2020-07-16 19:45:46
tags:
- powershell
---
&nbsp;
<!-- more -->
#參考文章
http://chienleebug.blogspot.com/2017/11/powershellpowershell.html
https://ithelp.ithome.com.tw/articles/10186746
https://docs.microsoft.com/zh-tw/powershell/scripting/learn/remoting/running-remote-commands?view=powershell-7
https://helpcenter.gsx.com/hc/en-us/articles/202447926-How-to-Configure-Windows-Remote-PowerShell-Access-for-Non-Privileged-User-Accounts

紀錄一下powershell操控遠端電腦的一些操作 , 方便作業
```
#允許防火牆
New-NetFireWallRule -DisplayName PowerShellWinRM -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow

#兩台都要設定
Enable-PSRemoting –force

#本機電腦執行
winrm s winrm/config/client '@{TrustedHosts="192.168.1.101"}'

#遠端電腦
winrm s winrm/config/client '@{TrustedHosts="192.168.1.102"}'

#注意遠端的電腦也要信任本機的電腦

#連線的Session
$remoteSession = New-PSSession -ComputerName 192.168.1.102 -Credential "YourComputerName\Administrator"

#直接使用該遠端連線執行指定
Enter-PSSession $remoteSession

#離開這個遠端Session
exit

#在自己電腦執行遠端電腦上的命令
Invoke-Command -Session $remoteSession -ScriptBlock { Get-ChildItem C:\ }

#注意 powershell 版本 5.0 用這指令傳到 2.0 會失敗 暫時找不到解法
Copy-Item -Path C:\Source.txt -Destination C:\Target.txt -ToSession $remoteSession

#複製整個7z檔案到指定的遠端位置
Copy-Item -Path C:\Users\Test\Test.7z -Destination D:\Test\Test.7z -ToSession $remoteSession
``` 
