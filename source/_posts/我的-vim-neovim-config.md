---
title: 我的 vim/neovim config
date: 2020-08-18 11:32:43
tags:
- vim
- neovim
top: true
---
&nbsp;
<!-- more -->

前言，老實說呢，我很懶得寫這篇，因為之前的電腦 win 10 跑 wsl or cmder 基本上都很順，
但跑到 win 7 上就很靈異，先是 cmder 顯示錯誤，安裝 cygwin 顯示也是不正確，我看 git for windows 好像顯示就沒問題，為了讓工作順暢特別研究了這篇 @__@!

## 安裝 oh-my-bash
算是無腦安裝 [oh-my-bash](https://github.com/ohmybash/oh-my-bash)
```
cd $HOME
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
```
預設會幫你蓋 .bashrc 我想要啟動時也直接啟動，所以把 .bashrc 裡面的設定直接複製到 .bash_profile , 若沒有這兩個檔案可以自己手動建立
注意他這邊用 powerline 當作樣式的話會一直跳出要你用 admin 的視窗，暫時無解先用 OSH_THEME="agnoster"


## Git bash for windows 設定 vim
在 git bash for windows 底下輸入以下命令
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

搞定後會在 ~/.vim 目錄底下多出 autoload , plugged 資料夾跟 neovim 有點不太一樣

要 config vim 的設定檔則在以下路徑
`C:\Program Files\Git\etc\vimrc`

安裝 :PlugInstall
萬一出現 airline missing comma 錯誤，調整以下修正即可
```
~\.vim\plugged\vim-airline\autoload\airline\extensions\tabline\buffers.vim

let s:number_map = { '0' : 0 , '1' : 1 , '2' : 2 , '3' : 3 , 4 : '4' , 5 : '5' , 6 : '6' , 7 : '7' , 8 : '8' , 9 : '9' }
```

## 解決 git bash for windows python 輸出有問題
nodejs 應該也會有這種類似的狀況，解法就是要用 winpty 把 windows 的 exe 指令給包一層 [參考不錯的說明](https://magicjackting.pixnet.net/blog/post/222998706)
後來想說裝個 nvim 會支援 python3 ， 結果在 windows 底下就算用 winpty 包起來也是沒有真色支援，頭很痛
```
cd ~
vim ~/.bashrc
#加入內容
alias python='winpty python'
alias pip='winpty pip'
source ~/.bashrc
```

## check vim support python
這個 python support 在 git for windows 的 vim 底下一定是沒 support 的，又雷得不要不要的
```
vim --version | grep "+python"
:echo has('python3') 
:echo has('python') 
return 1 即可
```

## Tmux 安裝
萬事起頭難，參考還不錯的[大陸人設定](https://github.com/xnng/my-git-bash)
無意中還發現還不錯的[教學](https://www.youtube.com/watch?v=M76pb775bWk)

```
git clone https://github.com/xnng/bash.git
cd bash
explorer .
分別複製
tmux/bin 底下所有檔案到 C:\Program Files\Git\usr\bin
tmux/share 底下所有檔案到 C:\Program Files\Git\usr\share
```

應該也可以直接下 command 不過需要 windows admin 權限，可以安裝 [gsudo](https://github.com/gerardog/gsudo)

在 $HOME 底下新增以下 .tmux.conf 檔案[參考自](https://blog.roy4801.tw/2018/08/25/tmux%20%E5%9F%BA%E6%9C%AC%E4%BD%BF%E7%94%A8/)
最關鍵 => 啟動真色，否則在 vim 底下會失去顏色[參考自印度仔](https://github.com/tmux/tmux/issues/1246)
tmux.conf
```
set -g default-terminal "xterm-256color"
set -ga terminal-overrides ",*256col*:Tc"
```
vimrc
```
if (has("termguicolors"))
  set termguicolors
endif
```

## Bash for Windows tmux vim 中文亂碼設定及真色設定
在 git bash for windows 開啟 options => text => Locale zh_TW => Character set UTF-8
Window => UI Language => Windows language
Terminal => Type => xterm-256 color
cursor 變粗 => options => looks => cursor => Block

萬一遇到簡體中文造成亂碼可在 vimrc 加入以下內容
```
set fileencodings=utf-8,gb2312,gb18030,gbk,ucs-bom,cp936,latin1
set enc=utf8
set fencs=utf8,gbk,gb2312,gb18030
```


## 最終 vim 設定檔
注意如果是用 git bash for windows 這些要放在預設的那段下面，另外 utf8 要註解掉
``` vimscript
" 注意如果是用 git bash for windows 這些要放在預設的那段下面
call plug#begin('~/.vim/plugged')

" Plug 'joshdick/onedark.vim'
" Plug 'iCyMind/NeoSolarized'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" 佈景主題
Plug 'ayu-theme/ayu-vim'

" 檔案樹
Plug 'scrooloose/nerdtree'

" 會亂碼
" Plug 'ryanoasis/vim-devicons'

" emmet
Plug 'mattn/emmet-vim'

" 註解外掛
Plug 'tpope/vim-commentary'

" 快速替換開頭結尾
Plug 'tpope/vim-surround'

" 多重游標
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" 縮排線
" 無效?
" Plug 'Yggdroot/indentLine'

" 縮排線
 Plug 'nathanaelkane/vim-indent-guides'

" Error
" live server
" Plug 'turbio/bracey.vim'

" css 顏色
Plug 'ap/vim-css-color'

" 自動括號
Plug 'jiangmiao/auto-pairs'



call plug#end()

" 設定編碼
set encoding=UTF-8

set fileformat=unix

" 行號
set nu
set relativenumber

" 剪貼設定
set clipboard=unnamed

" 設定cursor顏色
" set cursorcolumn
" set cursorline

" tab寬度
syntax enable
set smartindent
set tabstop=4
set shiftwidth=4
" set expandtab

" 設定字體
" set guifont=Fira\ Code:h12

" ariline
" 開啟tab樣式
let g:airline#extensions#tabline#enabled = 1


" 設定NERDTree
nnoremap <silent> <C-k><C-B> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" 設定 emmet
"
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall
imap <expr> <tab> emmet#expandAbbrIntelligent("\<tab>")

" 設定縮排顏色
" let g:indentLine_setColors = 0
" let g:indentLine_color_term = 239
" let g:indentLine_char_list = ['|', '¦', '┆', '┊']

" 設定縮排第二種
let g:indent_guides_enable_on_vim_startup = 1
hi IndentGuidesOdd  ctermbg=white
hi IndentGuidesEven ctermbg=lightgrey

" 設定自動括號
let g:AutoPairsFlyMode = 1

" 設定佈景主題
set termguicolors     " enable true colors support
let ayucolor="light"  " for light version of theme
" let ayucolor="mirage" " for mirage version of theme
" let ayucolor="dark"   " for dark version of theme
colorscheme ayu"
"
" tmux true color
if (has("termguicolors"))
  set termguicolors
endif

"esc
inoremap ,, <Esc>
nnoremap ,, <Esc>
map ,so :so ~/.vimrc <CR>


```

## 最終 Tmux 設定

```
### rebind hotkey

# prefix setting (screen-like)
set -g prefix C-a
unbind C-b
bind C-a send-prefix

# reload config without killing server
bind R source-file ~/.tmux.conf \; display-message "Config reloaded..."

# "|" splits the current window vertically, and "-" splits it horizontally
unbind %
bind | split-window -h
bind - split-window -v

# Pane navigation (vim-like)
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Pane resizing
bind -r Left  resize-pane -L 4
bind -r Down  resize-pane -D 4
bind -r Up    resize-pane -U 4
bind -r Right resize-pane -R 4


### other optimization

# set the shell you like (zsh, "which zsh" to find the path)
# set -g default-command /bin/zsh
# set -g default-shell /bin/zsh

# use UTF8
#set -g utf8
#set-window-option -g utf8 on

# display things in 256 colors
set -g default-terminal "screen-256color"
#set -g default-terminal "xterm-256color"
#set -g default-terminal "xterm"

#啟動真色
set -g default-terminal "xterm-256color"
set -ga terminal-overrides ",*256col*:Tc"


# mouse is great!
set-option -g mouse on

# history size
set -g history-limit 10000

# fix delay
set -g escape-time 0

# 0 is too far
set -g base-index 1
setw -g pane-base-index 1

# stop auto renaming
setw -g automatic-rename off
set-option -g allow-rename off

# renumber windows sequentially after closing
set -g renumber-windows on

# window notifications; display activity on other window
setw -g monitor-activity on
set -g visual-activity on

```

## 後記的靈異事件
這個事件是由某天懶得貼上格式發生的直接把 set paste 寫在 .vimrc 裡面發生悲劇了 ,
 本來想 remap esc , 搞了半天如果設定 paste 的話進入 insert mode 會變成 `INSERT PASET` 
暫時找不到偷懶的解法就先不要在 .vimrc 內使用 set paste 吧

## windows 底下使用 neovim
chocolatey [下載 nvim](https://community.chocolatey.org/packages/neovim#releasenotes)

將 vimrc 複製到以下路徑 , 並修改為 init.vim
`C:\Users\YourName\AppData\Local\nvim`

下載 [vim-plug](https://github.com/junegunn/vim-plug)
``` powershell
iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim |`
    ni "$(@($env:XDG_DATA_HOME, $env:LOCALAPPDATA)[$null -eq $env:XDG_DATA_HOME])/nvim-data/site/autoload/plug.vim" -Force
```

開啟 nvim 安裝 plugin
```
:PlugInstall
```

## ubuntu 設定 vim
下載外掛管理員
```
curl -fLo ~/.vim/autoload/plug.vim --create-dirs     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```

建立 .vimrc
```
cd ~
touch .vimrc
```

登入 vim 安裝外掛
```
vim
:PlugInstall
```

在 root 使用者安裝
```
sudo -i
cd /root
curl -fLo ~/.vim/autoload/plug.vim --create-dirs     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
touch .vimrc
vim
:PlugInstall
```
