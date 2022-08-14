---
title: vim 使用 org mode
date: 2020-12-29 01:38:42
tags: vim
---
&nbsp;
![terminal](https://raw.githubusercontent.com/weber87na/flowers/master/terminal.png)
<!-- more -->

## 升級 ubuntu 18 to 20
年紀大了忘東忘西 , 希望有個簡單又有效的筆記管理 , 不要單純只有 notepad++ 那種文字速寫
發現 emacs 陣營有 org mode 就找看看 vim 陣營有無這東西 , 順手筆記一下
結果裝一半要用日曆功能就倒了，順手把 ubuntu 18 升級到 ubuntu 20
[參考](https://www.omgubuntu.co.uk/2020/04/ubuntu-20-04-wsl-windows-10)
```
sudo apt update
sudo apt upgrade
do-release-upgrade -d
#升級完以後 nodejs 就倒了
sudo apt install nodejs
```

## 安裝 org mode
```
Plug 'jceb/vim-orgmode'
Plug 'tpope/vim-speeddating'
Plug 'mattn/calendar-vim'
Plug 'majutsushi/tagbar'

Plug 'dhruvasagar/vim-table-mode'
```
後來發現 emacs 的 org mode 還有 table 應該要再安裝 table mode 才還原度比較高
