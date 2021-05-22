---
title: vim 開發 csharp 程式
date: 2020-12-29 00:38:02
tags: vim
---
&nbsp;
<!-- more -->
## 安裝 .net core 3.1
```
wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb 
sudo dpkg -i packages-microsoft-prod.deb 
sudo apt update 
sudo apt install apt-transport-https -y 
sudo apt install dotnet-sdk-3.1 
```
## 安裝 omnisharp-vim
[omnisharp vim 官網](https://github.com/OmniSharp/omnisharp-vim)
在 vimrc 設定
```
Plug 'OmniSharp/omnisharp-vim'
:PlugInstall
```

## 測試是否成功
用 vim 開 .cs 檔案時，這邊會提示你要安裝 OminSharp 的 Server
開啟提示`ctrl+x ctrl+o`
```
dotnet new console
vim Program.cs
dotnet build
dotnet run
```
結論功能還是滿殘破的，維護可能還可以
