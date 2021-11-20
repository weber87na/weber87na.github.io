---
title: powershell日常筆記
date: 2020-07-09 19:56:41
tags:
- powershell
---
&nbsp;
<!-- more -->
工作久了有的東西常沒用就忘了 , 剛好又遇到以前的問題 , 趁機吃個老本筆記一下

設定 powershell 上使用 vim [參考](https://blog.csdn.net/zhengqijun_/article/details/62425062)
C:\Users\YourName\\_vimrc
```
set encoding=utf-8
set termencoding=utf-8
set fileencoding=utf-8
set fileencodings=utf-8
```
這邊要隨著版本調整
並且要把這個 config 命名為 profile.ps1 丟到 C:\Windows\System32\WindowsPowerShell\v1.0 底下
```
# There's usually much more than this in my profile!
$SCRIPTPATH = "C:\Program Files (x86)\Vim"
$VIMPATH    = $SCRIPTPATH + "\vim86\vim.exe"
 
Set-Alias vi   $VIMPATH
Set-Alias vim  $VIMPATH
 
# for editing your PowerShell profile
Function Edit-Profile
{
    vim $profile
}
 
# for editing your Vim settings
Function Edit-Vimrc
{
    vim $home\_vimrc
}
```
設定完需要用admin執行以下powershell
```
Set-ExecutionPolicy RemoteSigned

```
後來發現解壓縮沒7zip還挺不方便的於是到[powershell gallery](https://www.powershellgallery.com/packages/7Zip4Powershell/1.12.0)找找想不到還真的有
``` powershell
Expand-7Zip -ArchiveFileName .\test.7z -TargetPath .\test)
```
### 小試牛刀
[參考](https://stackoverflow.com/questions/5596982/using-powershell-to-write-a-file-in-utf-8-without-the-bom)

``` powershell
#呼叫 api
$tests = Invoke-WebRequest http://127.0.0.1:5000/api/test -ContentType "application/json; charset=utf-8"  | ConvertFrom-Json

#merge id
$ids = $ids.ID -join ","

#設定utf8無bom
$utf8 = New-Object System.Text.UTF8Encoding $false

#參數ids吃先前用comma連接的
$testIds = Invoke-WebRequest Invoke-WebRequest http://127.0.0.1:5000/api/test?ids=$ids -ContentType "application/json; charset=utf-8" 
#保存到 result.txt
[System.IO.File]::WriteAllLines("test.txt", $testIds.content, $utf8)
```

### 找 api 內含有數字的資料 , 並排除某些 id
主要原理就是需要使用 ConvertFrom-Json 將 json 物件轉為 powershell 的物件 , 接著以 Where-Object 進行搜尋 , 最後在轉換回 json 並且存檔
可以[參考](https://devblogs.microsoft.com/scripting/playing-with-json-and-powershell/)
``` powershell
$utf8 = New-Object System.Text.UTF8Encoding $false
$tests = Invoke-WebRequest http://127.0.0.1:5000/api/test -ContentType "application/json; charset=utf-8"
$result = $tests.content | ConvertFrom-Json
$filter = $result |  Where-Object {$_.ddesc -Like "*[0-9]*" -and $_.id  -notin 123,456}
$resultJson = $filter | ConvertTo-Json
[System.IO.File]::WriteAllLines("test.txt", $resultJson, $utf8)
```
### 正則表示法找 api 內只含有數字的資料
``` powershell
$tests = Invoke-WebRequest http://127.0.0.1:5000/api/test
$json = $tests.content | ConvertFrom-Json
$result = $json | where ddesc -match "^[0-9]*$"
$result | ConvertTo-Json > "找出只有零到九的.json"
```

### 撈電腦產品型號
當 systeminfo 查不到型號顯示 System Model: System Product Name , 可以用以下指令撈看看
```
#查不到 顯示 System Model: System Product Name
systeminfo

#Model : System Product Name
Get-WmiObject Win32_ComputerSystem Model
wmic baseboard get product,manufacturer,version,serialnumber
```

### 撈 windows 目前版本
```
Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer
```
