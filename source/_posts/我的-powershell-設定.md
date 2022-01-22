---
title: 我的 powershell 設定
date: 2021-12-01 02:23:38
tags: powershell
---
&nbsp;
<!-- more -->

我工作上用 powershell 多半是拿來開個 git 或是用它來當 ssh (較為輕量速度也快) 不然就是開 neovim 來用或是下一些常用指令
之前寫這類的比較散亂沒個正式整理 , 剛好看到保哥的直播[教學](https://www.youtube.com/watch?v=MA_gIbs6P1c) 就順便整理一下吧
保哥應該是參考[老外](https://www.hanselman.com/blog/adding-predictive-intellisense-to-my-windows-terminal-powershell-prompt-with-psreadline)
應該還有這[老外](https://megamorf.gitlab.io/cheat-sheets/powershell-psreadline/)
最後還有這[老外](https://4sysops.com/archives/powerline-customize-your-powershell-console/)

## powershell 事前準備
安裝 `CHOCOLATEY` [官網](https://chocolatey.org/install)
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

### 安裝 gsudo
有在用 linux 的人一定很習慣用 `sudo` 來切換成 `root` 權限 , 這個算是 windows 的 root , 美中不足就是會跳個很賭爛的視窗 , 不是直接在 terminal 裡面 , 希望有天可以改善
感興趣可以參考[官方](https://github.com/gerardog/gsudo)

choco 安裝 `gsudo`
```
choco install gsudo
```

或使用 powershell 安裝 `gsudo`
```
PowerShell -Command "Set-ExecutionPolicy RemoteSigned -scope Process; iwr -useb https://raw.githubusercontent.com/gerardog/gsudo/master/installgsudo.ps1 | iex"
```

## 安裝字體
安裝字體算是大學問 , 在新一點的環境中可以用我常用的 `firacode` , `DejaVu Sans` 或保哥推薦安裝的 `CascadiaCode`
老環境就用保哥去修正的 Microsoft YaHei Mono

### firacode
安裝 firacode 字體 (建議要安裝 , 這樣使用 git-posh 才會正常顯示)
```
choco install firacode
```
或[官網下載](https://github.com/tonsky/FiraCode) , 解壓縮以後選 `ttf` 全選以後右鍵安裝

### DejaVu Sans
萬一有使用 powerline 這鬼東西 , 可以到這個網頁[下載](https://github.com/powerline/fonts)
選擇這個字體 `DejaVu Sans Mono for Powerline` , 其他字體測不出來 , 圖示都會亂碼 , 安裝好的話用 ssh 連線 ubuntu 也可以正常顯示

### CascadiaCode
用這個字體主要是為了用 [Terminal-Icons](https://github.com/devblackops/Terminal-Icons) 這個功能 , 礙於老環境限制工作環境我就沒用這個功能
```
Install-Module -Name Terminal-Icons -Repository PSGallery
Import-Module -Name Terminal-Icons
```
[CascadiaCode 字體載點](https://github.com/ryanoasis/nerd-fonts/releases/tag/v2.1.0)


### Microsoft YaHei Mono
老的環境可以參考不管用什麼字體只要是 run powershell 都會跑掉變回原形很醜 , 找到保哥[這篇](https://blog.miniasp.com/post/2017/12/06/Microsoft-YaHei-Mono-Chinese-Font-for-Command-Prompt-and-WSL)
只要下載他的字體就可以解決問題 , 但是一些 icon 還是無解至少開 vim 不會跑掉 , 對沒有 windows terminal 的環境幫助滿大的
另外捲軸沒有 30 cm 的話可以用老外的[設定](https://mcpmag.com/articles/2013/03/12/powershell-screen-buffer-size.aspx) 老外直接設定 3000 cm真是狠腳色

## 設定 windows ssh powershell 連線
我這邊直接使用 windows 的 powershell 來進行連線 , 因為預設的 powershell 畫面很醜 , 像是很古老的當機畫面 , 所以稍微 config 一下
[powershell 字體設定](https://zhuanlan.zhihu.com/p/163007658)
```
電腦\HKEY_CURRENT_USER\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe
FaceName 設定 Fira Code 注意有空格
```
設定好後開啟 powershell => `右鍵` => `內容` => `字型` => `Fira Code` 即可


## 安裝 powershell 黑色系佈景 [Dracula](https://github.com/dracula/powershell)
這個算是我很喜歡的功能 , 工作上我調整透明度到 90% 也可以看黑色背景眼睛不會痠痛 , 不然我還要自己客製化成豆沙色超麻煩的
下載後解壓 `dist\ColorTool` 執行 `install.cmd` 即可完成安裝 , 並且將 `dracula-prompt-configuration.ps1` 內的設定貼到 `$profile`
powershell `$profile` 的設定檔 `profile.ps1` 跟 `.bashrc` 類似 , 就是用來初始化 powershell 的設定檔
一般會在以下路徑內新增一個 `profile.ps1` 文件來進行管理 , 若有 `Microsoft.PowerShell_profile.ps1` 也可以直接編輯他
```
#for admin
C:\Windows\System32\WindowsPowerShell\v1.0

#for user
C:\Users\YourName\Documents\WindowsPowerShell\
```

## 安裝 oh-my-posh
記得這個 v2 跟 v3 設定上面略有不同 , 所以如果設定佈景樣式遇到 error 可能是用了 v2 的指令 , 網路上一堆人的文章都是 v2 的 , 要特別注意下
[oh-my-posh](https://github.com/JanDeDobbeleer/oh-my-posh)
```
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

## 啟動提示及一些加強功能

### DockerCompletion
有在 windows 操作 docker 的人可以考慮安裝這個 [DockerCompletion](https://github.com/matt9ucci/DockerCompletion) 就可以有 docker 提示 , 敲起來快很多
印象中我還有裝過 k8s 提示 , 不過有點斷手斷腳而且忘了筆記就不寫了 , 而且多半用 k8s 都是在 linux 上面
```
Install-Module DockerCompletion
```

### 歷史提示
啟動歷史預測提示 [predictive](https://devblogs.microsoft.com/powershell/announcing-psreadline-2-1-with-predictive-intellisense/)
注意預設是關閉的需要自行啟用
```
Install-Module PSReadLine -RequiredVersion 2.1.0
```
後來看到保哥用這樣安裝可以獲得更好的使用體驗
```
Install-Module PSReadLine -AllowPrerelease -Force
```

### zLocation
類似 acejump 的工具 , 提升爽度 , 用法無腦輸入 z 然後可以選要跳哪 , 詳細參考[官方](https://github.com/vors/ZLocation)
```
Install-Module ZLocation
Import-Module ZLocation
```

### tig
今天研究一下 powershell 上面 tig , 因為安裝了 git 預設就會裝 tig , 之前沒有 windows terminal 斷手斷腳 , 所以會開 git bash 現在就混搭風
可是 tig 的預設佈景整個就是很靈異 , 研究下怎麼調整 , 首先到[這裡](https://github.com/edentsai/tig-theme-molokai-like) 下載
然後在你的家目錄底下建立 .tigrc 檔案 `~/.tigrc`

編輯這個檔案 `C:\Users\YourName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

```
notepad $PROFILE
```

追加這句 , 另外太容易忘記自己的 gitlab repo 網址 , 所以追加一個在 chrome 開啟的指令
```
function tig { & "C:\Program Files\Git\usr\bin\tig.exe" }

function current-repo { start chrome (git config remote.origin.url).trim(".git") }
```
接著 reload $profile
```
.$profile
```

或是直接加到 `PATH` 環境變數 `C:\Program Files\Git\usr\bin` 

## 其他問題
### Security 問題
Nuget 安裝套件炸過的問題 , 用 admin 執行以下命令 , 防止後續炸出 error
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet
```

### 簽章問題
這個炸的 error 我忘了是什麼 , 不過看保哥影片好像也有炸
```
Set-ExecutionPolicy RemoteSigned
```

## full config
最後額外設定自己的 config , 過程中太頻繁懶得打 docker 直接用 alias , 另外還有像是 history 搜尋可以按 `ctrl + r` 往前搜尋這種不錯的小技巧可以用 , 詳情參考[印度仔](https://www.thewindowsclub.com/how-to-see-powershell-command-history-on-windows-10)
另外可以設定 Emacs 的 key binding 這樣操作起來就跟用 bash 預設的熱鍵一樣 , 這個一定要啟用 , 不然對不起 emacs 大師
看了保哥的設定之後我又多加了一個開啟 `_vsvimrc` 的功能 , 因為很常需要去找這些散落在各地的 vim 設定檔 , 也可以看你環境去加入如 vscode 的 `setting.json` 之類的
```
#注意要用這串安裝才會有增強功能
#Install-Module PSReadLine -AllowPrerelease -Force

#使用 bash 的 emacs 鍵盤設定
Set-PSReadLineOption -EditMode Emacs

#美化 powershell
Import-Module posh-git
Import-Module oh-my-posh
Set-PoshPrompt darkblood
#Set-PoshPrompt fish

#設定 icon 檔
Import-Module -Name Terminal-Icons

#Docker 提示
Import-Module DockerCompletion

#k8s 提示
Import-Module -Name PSKubectlCompletion
Register-KubectlCompletion

#dotnet 提示
# PowerShell parameter completion shim for the dotnet CLI
Register-ArgumentCompleter -Native -CommandName dotnet -ScriptBlock {
    param($commandName, $wordToComplete, $cursorPosition)
        dotnet complete --position $cursorPosition "$wordToComplete" | ForEach-Object {
           [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
        }
}


#設定 tab 補全
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete

#開啟歷史提示
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

#alias
Set-Alias -Name d -Value docker
Set-Alias -Name k -Value kubectl
Set-Alias gsudo sudo
Set-Alias -Name touch -Value New-Item

#參考保哥設定
#因為 curl windows 已經內建所以加入這個
IF (Test-Path Alias:curl) { Remove-Item Alias:curl }
IF (Test-Path Alias:wget) { Remove-Item Alias:wget }

function hosts { notepad C:\windows\system32\drivers\etc\hosts }
function vsvimrc { notepad $HOME\_vsvimrc }

#設定 tig
function tig { & "C:\Program Files\Git\usr\bin\tig.exe" }

#直接在 chrome 開 remote git repo
function current-repo { start chrome (git config remote.origin.url).trim(".git") }
```
