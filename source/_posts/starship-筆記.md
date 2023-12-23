---
title: starship 筆記
date: 2022-10-17 19:06:41
tags:
- rust
- wsl
---
&nbsp;
<!-- more -->

最近因為 Rust 超級流行 , 加上有高手指點 , 跟風看看 [starship](https://starship.rs/) , 說到 starship 就會讓人想到這首歌 Nothing's Gonna Stop Us Now , 男女對唱結果男的 key 還更高 , 簡直外星人 XD 
此外大概是 80 年代主唱裡面老了以後還可以唱原 key 的唯一一人吧 , 現在好像 7x 還可以唱原 key 實在太扯啦 ~
其他 band 的主唱 ex: skid row , bon jovi , steelheart 等等嗓子早就掛啦 ~
<iframe width="1280" height="720" src="https://www.youtube.com/embed/g6i7oEPOUI8" title="Starship - Nothing's Gonna Stop Us Now (Audio Official)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

另外私心推薦另外一首 80 男女對唱也很好聽的歌 XD
<iframe width="853" height="480" src="https://www.youtube.com/embed/UnaK1RRrZ2c" title="Surrender To Me (From "Tequila Sunrise" Soundtrack / Remastered)" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


回歸正題先安裝接著開啟設定檔
```
gsudo choco install starship
notepad $profile
```

因為我之前有用 oh-my-posh , 所以需要把相關部分註解 , 然後加上 `Invoke-Expression (&starship init powershell)` 就能動了 , 沒想到這麼無腦
```
#注意要用這串安裝才會有增強功能
#Install-Module PSReadLine -AllowPrerelease -Force

#清除開頭煩人的訊息
Clear-Host

#使用 bash 的 emacs 鍵盤設定
Set-PSReadLineOption -EditMode Emacs


#美化 powershell
#Import-Module oh-my-posh
#原本開啟的 posh-git
#Import-Module posh-git
#Import-Module PS-fzf

#Set-PoshPrompt darkblood
#Set-PoshPrompt fish
#Set-PoshPrompt ys

#oh-my-posh init pwsh | Invoke-Expression
#原本開啟的 oh-my-posh
#oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\ys.omp.json" | Invoke-Expression

#改用 starship
Invoke-Expression (&starship init powershell)


#設定 icon 檔
Import-Module -Name Terminal-Icons

#啟用 z 類似 acejump 的工具
#輸入 z 然後可以選要跳哪
#https://github.com/vors/ZLocation
Import-Module ZLocation

#Docker 提示
#Import-Module DockerCompletion

#k8s 提示
#Import-Module -Name PSKubectlCompletion
#Register-KubectlCompletion

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
#Set-Alias -Name d -Value docker
#Set-Alias -Name k -Value kubectl
Set-Alias gsudo sudo
Set-Alias -Name touch -Value New-Item
#Set-Alias ll ls
#Set-Alias grep findstr
#Set-Alias less 'C:\Program Files\Git\usr\bin\less.exe'

#參考保哥設定
#因為 curl windows 已經內建所以加入這個
IF (Test-Path Alias:curl) { Remove-Item Alias:curl }
IF (Test-Path Alias:wget) { Remove-Item Alias:wget }

function hosts { notepad C:\windows\system32\drivers\etc\hosts }
function vsvimrc { notepad $HOME\_vsvimrc }

function tig { & "C:\Program Files\Git\usr\bin\tig.exe" }
#function devenv { & "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe" }
#串 visual studio 的環境變數
$Env:PATH += ";C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\"

#取得目前的 git repo
function current-repo { start chrome (git config remote.origin.url).Replace(".git","") }

#清除啟動以後的訊息
clear
```

設定好以後開啟 .net core & node 專案的效果 , 可以看到目前用啥版本 , 也可以知道目前專案是啥 , 滿方便的
```
SportsStore on  master via .NET v6.0.101 🎯 net5.0
SportsStore on  master [!?] via  v16.17.1
```


進階設定 , 我這裡有把 `New-Item` 設定 alias `touch` , 老實說 starship 算是一個很開箱即用的咚咚

```
mkdir ~/.config
New-Item starship.toml
#touch starship.toml
```


`starship.toml`
這裡就把箭頭 ➜ 改成花 🌹 XD
```
# Get editor completions based on the config schema
"$schema" = 'https://starship.rs/config-schema.json'

# Inserts a blank line between shell prompts
add_newline = true

# Replace the "❯" symbol in the prompt with "➜"
[character] # The name of the module we are configuring is "character"
success_symbol = "[🌹](bold green)" # The "success_symbol" segment is being set to "➜" with the color "bold green"

# Disable the package module, hiding it from the prompt completely
[package]
disabled = true

[conda]
format = "[$symbol$environment](dimmed green) "

```


後來發現他的 conda 如果是 base 的話好像不會 show , 好像要 activate 某個環境以後才會 show , 有點怪小怪小的
```
conda activate netcdf
```



本來想用看看 `dracula` [載點](https://draculatheme.com/starship) 可是發現好像也沒改啥 XD , 其他就有空再深入研究吧
```
[aws]
style = "bold #ffb86c"

[character]
error_symbol = "[λ](bold #ff5555)"
success_symbol = "[λ](bold #50fa7b)"

[cmd_duration]
style = "bold #f1fa8c"

[directory]
style = "bold #50fa7b"

[git_branch]
style = "bold #ff79c6"

[git_status]
style = "bold #ff5555"

[hostname]
style = "bold #bd93f9"

[username]
format = "[$user]($style) on "
style_user = "bold #8be9fd"

```
