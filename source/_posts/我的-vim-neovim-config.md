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

## windows 對照 vim 快速操作技巧
最近又回來用 windows 覺得賭爛 , 筆記一下操作 , 應該還要寫個 emacs 的方式才對畢竟 terminal 常常用 , 有空再搞
`ctrl + z` 復原 `u`
`ctrl + y` 復原前的狀態 `ctrl + r`
`ctrl + g` 移動到行號 `:5`
`ctrl + ←` 往左移動一整個單字 `b`
`ctrl + →` 往右移動一整個單字 `w`
`ctrl + shift + ←` 往左選取一整個單字 `vb`
`ctrl + shift + →` 往右選取一整個單字 `ve`
`home` 移動到行頭 `^`
`end` 移動到行尾 `$`
`shift + home` 目前位置選到行頭 `v^`
`shift + end` 目前位置選到行尾 `v$`
`ctrl + backspace` 刪除一個單字 , 中文的話就是刪除到空白為止 `daw`
`ctrl + home` 移動到文件最頂端 `gg`
`ctrl + end` 移動到文件最尾端 `G`
`ctrl + ↑` 往上捲 `ctrl + e`
`ctrl + ↓` 往下捲 `ctrl + y`
`ctrl + shift + ↑` 將此行往上移動 `:m-2`
`ctrl + shift + ↓` 將此行往下移動 `:m+1`

## windows 對照 terminal 快速操作技巧
`end` 往前刪除一個字 `ctrl + h` 
`delete` 刪除目前游標的字 `ctrl + d`

`←` 往左移動一個字 `ctrl + b`
`→` 往右移動一個字 `ctrl + f`

`ctrl + ←` 往左移動一個單字 `alt + b`
`ctrl + →` 往右移動一個單字 `alt + f`

`ctrl + shift + ← + delete` or `ctrl + backspace` 往左刪除一個單字 `ctrl + w`
`ctrl + shift + → + delete` or `ctrl + → + backspace` 往右刪除一個單字 `alt + d`

`shift + end + delete` 刪除目前游標之後的所有字 `ctrl + k`
`home + shift + end + delete` 刪除整行 `ctrl + a` `ctrl + k`

`home` 移動到開頭 `ctrl + a`
`end` 移動到結尾 `ctrl + e`

`ctrl + l` 清除畫面

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

## 解決 vim 編輯檔案時忘了加上 sudo 造成 readonly 的問題
這問題困擾滿久的 , 有時候編輯一堆內容才發現忘了加 sudo , 今天無意中看到[老外說明](https://superuser.com/questions/694450/using-vim-to-force-edit-a-file-when-you-opened-without-permissions)
可以執行以下指令 , 就搞定啦
```
:w !sudo tee %
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
或是直接在 terminal `vim +PlugInstall`


在 root 使用者安裝
```
sudo -i
cd /root
curl -fLo ~/.vim/autoload/plug.vim --create-dirs     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
touch .vimrc
vim
:PlugInstall
```

## 使用 COC 補全 k8s yaml
因為在搞 docker + k8s , 需要編輯 yaml 檔 , 直接在 linux 上面沒有 auto complete 實在太噁心了
決定找個至少能用的方法主要參考 [這篇老外文章](https://octetz.com/docs/2020/2020-01-06-vim-k8s-yaml-support/) , 之前好像沒用過 coc? 忘了?
這老外還有[教學影片](https://www.youtube.com/watch?v=eSAzGx34gUE) 真佛心
先在 vimrc or init.vim 內加入以下命令
```
" Use release branch (Recommend)
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" Or build from source code by use yarn: https://yarnpkg.com
Plug 'neoclide/coc.nvim', {'do': 'yarn install --frozen-lockfile'}
```

接著輸入以下命令安裝
```
:PlugInstall
```

萬一 coc 炸 error 檢查看看自己有無安裝 python , 另外好像還要裝 nodejs 不過我機器上已經有了
並且加入以下命令 [參考自老外解法](https://stackoverflow.com/questions/65160481/neovim-on-windows-cant-find-python-provider)
```
python3 -m pip install --user --upgrade pynvim
```

如果是用 ubuntu 需要先安裝 nodejs , 注意 nodejs 版本要 12.12 以上 , 小心不要直接用 apt-get install 有可能安裝到舊版 , 在 ubuntu 20.04 上 default 好像是 node 10?
萬一不小心安裝舊版可以參考這個[移除](https://askubuntu.com/questions/786015/how-to-remove-nodejs-from-ubuntu-16-04)
```
curl -sL https://deb.nodesource.com/setup_14.x | sudo bash -
sudo apt-get install -y nodejs
```

安裝 coc-yaml
```
:CocInstall coc-yaml
```

萬一 coc 炸出這個 error 可能是 nodejs or python 沒安裝或是版本錯誤 , 請確認版本是否正確
```
client coc abnormal exit with: -1
```

接著照打開 CocConfig 編輯
```
:CocConfig
```

使用 vim 的話 coc 路徑會在如下位置 `~/.vim/coc-settings.json`
windows 的 neovim 在 `~/AppData/Local/nvim/coc-settings.json`
設定完應該就能動了 , 最後就可以用 `ctrl + n` `ctrl + p` 上下移動補全的 menu 不過好像 vscode 的更好用一點
```
{
  "languageserver": {
      "golang": {
        "command": "gopls",
        "rootPatterns": ["go.mod"],
        "filetypes": ["go"]
      }
  },

  "yaml.schemas": {
      "kubernetes": "/*.yaml"
  }

}
```

## 安裝 zsh oh-my-zsh 及 powerline
參考 `oh-my-zsh` [官網](https://ohmyz.sh/#install)
```
sudo apt-get install zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sudo apt install powerline fonts-powerline
```

在 ubuntu 內挑選[佈景](https://github.com/ohmyzsh/ohmyzsh/wiki/Themes)
```
vim ~/.zshrc

#比較不花俏的預設佈景
#ZSH_THEME="darkblood"

#dracula
#ZSH_THEME="dracula"

#重新載入
source ~/.zshrc
```

因為 git for windows 上面預設的布景 [dracula](https://draculatheme.com/zsh) 用習慣了 , 所以就安裝看看
不得不說這個作者還滿屌的 , 各種 ide editor 都有 dracula 的布景
第一次用滿陌生的 , 我這邊手動安裝 , clone 以後會有個 zsh 資料夾 , 照官網說的 cp or mv 進去就可以了
```
git clone https://github.com/dracula/zsh.git
cd zsh
cp dracula.zsh-theme ~/.oh-my-zsh/themes/.
cp -r lib ~/.oh-my-zsh/themes/.
```

搞定布景後安裝 oh my zsh 的 plugin , 這裡參考大神 [Victor](https://www.youtube.com/watch?v=l4xt5B0NObQ) 的設定
[zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
[zsh-completions](https://github.com/zsh-users/zsh-completions)
[zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
```
cd ~/.oh-my-zsh/custom/plugins
git clone https://github.com/zsh-users/zsh-autosuggestions.git
git clone https://github.com/zsh-users/zsh-completions.git
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git
```

接著找到 plugins 改成這樣
```
vim ~/.zshrc

#plugins=(
#  git
#  zsh-autosuggestions
#  zsh-completions
#  zsh-syntax-highlighting
#  colored-man-pages
#)

source ~/.zshrc

```
## 為你的 cat 加上色彩

因為常常會用 cat 看些東東但是沒有語法高量可以考慮安裝 [bat](https://github.com/sharkdp/bat) 讓操作舒服點
```
sudo apt install bat
vim ~/.zshrc
#加上 alias
alias bat=batcat
```
## 裝 B 移動目錄神器 Ranger 筆記
安裝 [ranger](https://github.com/ranger/ranger) , 也可以參考這[老外教學](https://www.digitalocean.com/community/tutorials/installing-and-using-ranger-a-terminal-file-manager-on-a-ubuntu-vps) , 也可以看下強國人[影片](https://www.bilibili.com/video/BV1b4411R7ck?from=search&seid=7286148057737927194)
```
sudo apt install ranger
```

開啟 ranger 讓他自動建立資料夾
```
ranger
q
```

複製 ranger 的預設設定檔 template
```
ranger --copy-config=all
```

設定 ascii preview image 首先設定 `scope.sh` 找到這段把 `img2txt` 原本的註解開起來
```
vim ~/.config/ranger/scope.sh

## Image
image/*)
	## Preview as text conversion
	img2txt --gamma=0.6 --width="${PV_WIDTH}" -- "${FILE_PATH}" && exit 4
	exiftool "${FILE_PATH}" && exit 5
	exit 1;;
```

接著設定 `~/.config/ranger/rc.conf`
```
set preview_images false
set use_preview_script true
set preview_script ~/.config/ranger/scope.sh
```

設定 x11 preview image 注意只有在 ubuntu 有 gui 的機器有用 , 用 ssh 應該回 ascii 模式 , 先安裝 x11 相關工具及 ueberzug
```
sudo apt update
sudo apt upgrade
sudo apt-get install -y libx11-dev
sudo apt-get install -y xorg openbox
sudo apt-get install -y x11proto-xext-dev
sudo apt-get install -y libxext-dev
pip3 install ueberzug
```

設定 `~/.config/ranger/rc.conf`
```
set preview_images true
set preview_images_method ueberzug
```

萬一炸 WARNING 設定以下即可
```
#echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc
echo 'export PATH=~/.local/bin:$PATH' >> ~/.zshrc
```

最後預覽一下正妹
```
crul https://instagram.frmq3-1.fna.fbcdn.net/v/t51.2885-15/sh0.08/e35/s640x640/169486234_744729692910070_7136376512717038837_n.jpg?tp=1&_nc_ht=instagram.frmq3-1.fna.fbcdn.net&_nc_cat=110&_nc_ohc=jehk2TKowmEAX8DDWGK&edm=AABBvjUBAAAA&ccb=7-4&oh=95e49414292080950b57f70c1e6d1c09&oe=60C92944&_nc_sid=83d603 --output nono.png
```

## 在 ubuntu 上撰寫 .net core 5
今天在 ubuntu 20.04 linux 上安裝 .net core 5 莫名其妙炸了個奇怪的 error
```
E: The repository 'https://packages.microsoft.com/ubuntu/18.04/prod focal Release' does not have a Release file
```

查了下發現多了錯誤的版本在上面 , 可能之前沒睡飽下錯指令所致
把它們都註解掉 , 接著重新安裝 .net core 5 就搞定了 , 安裝可以參考[微軟官方](https://docs.microsoft.com/zh-tw/dotnet/core/install/linux-ubuntu#2004-)
```
sudo vim /etc/apt/sources.list
#deb https://packages.microsoft.com/ubuntu/18.04/prod focal main
# deb-src https://packages.microsoft.com/ubuntu/18.04/prod focal main

wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb

#sdk
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-5.0

#run time
sudo apt-get update; \
  sudo apt-get install -y apt-transport-https && \
  sudo apt-get update && \
  sudo apt-get install -y aspnetcore-runtime-5.0
```

主要參考這篇(https://github.com/OmniSharp/Omnisharp-vim)
打開 vimrc 並找到以下區塊加上 OmniSharp/omnisharp-vim
```
vim ~/.vimrc
call plug#begin('~/.vim/plugged')

#for csharp
Plug 'OmniSharp/omnisharp-vim'
```

接著在 vim 執行以下命令安裝 OmniSharp , 搞定後首次他會問我們要不要安裝 OmniSharp-Roslyn server 選 Yes 即可
```
:PlugInstall
```

接著在 Ubuntu 上面玩看看 .net core , 可以通過 dotnet xxx --help 來看詳細命令 , 這邊就直接蓋個 console 看看
```
mkdir helloworld
cd helloworld
dotnet new --list

#Console Application                           console         [C#],F#,VB  Common/Console
#Class library                                 classlib        [C#],F#,VB  Common/Library
#Worker Service                                worker          [C#],F#     Common/Worker/Web
#MSTest Test Project                           mstest          [C#],F#,VB  Test/MSTest
#NUnit 3 Test Item                             nunit-test      [C#],F#,VB  Test/NUnit
#......
```

蓋個 console 看看幫我們建了什麼
```
dotnet new console
ls
helloworld.csproj  obj  Program.cs
```

試著弄個 helloworld , 體驗一下 , 只能說連維護都不是很好用
```
using System;
using System.IO;

namespace helloworld
{
    class Program
    {
        static void Main(string[] args)
        {
			Console.WriteLine("HelloWorld");
            //StreamWriter file = new StreamWriter("test.txt");
            //file.WriteLine("Hello world");
            //file.Close();

        }
    }
}
```

最後跑看看是否成功寫入 , 結論就是裝 B 跟拿來看看 code 還可以用 , 實際開發還是用 IDE 比較有效率
```
dotnet run
cat test.txt
```

老樣子包個 Dockerfile 來玩看看 , 參考[官方](https://docs.microsoft.com/zh-tw/aspnet/core/host-and-deploy/docker/building-net-docker-images?view=aspnetcore-5.0)
```
# https://hub.docker.com/_/microsoft-dotnet
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /source

# copy csproj and restore as distinct layers
COPY *.sln .
COPY helloworld/*.csproj ./helloworld/
RUN dotnet restore

# copy everything else and build app
COPY helloworld/. ./helloworld/
WORKDIR /source/helloworld
RUN dotnet publish -c release -o /app --no-restore

# final stage/image
FROM mcr.microsoft.com/dotnet/aspnet:5.0
WORKDIR /app
COPY --from=build /app ./
ENTRYPOINT ["dotnet", "helloworld.dll"]
```

試跑看看 docker , 注意指定的 image 在最後面 , 另外如果用 -d 參數的話 , 這種單純的 console 是沒辦法跑起來的 , 需要切換 entrypoint
```
docker run  -it hello-console --name hello-console
#HelloWorld

#切換進入點 , 並且用 attach 進去看看
docker run -d -it --name hello-console --entrypoint sh hello-console
docker attach 341
ls
#helloworld  helloworld.deps.json  helloworld.dll  helloworld.pdb  helloworld.runtimeconfig.json
```

## fzf 安裝
navi 相依於 fzf , 所以先安裝 fzf , 注意最好用新一點的版本 , 不然 navi 會炸這個 error `invalid preview window layout: up:2:nohidden`
安裝好跟 vim 用法差不多因為太多電腦懶得一一 config , 最近更習慣直接 esc 用 `ctrl + [` 來代替 or `ctrl + q` 也可以
另外 fzf 除了 `ctrl + n` `ctrl +p` 以外還可以用 `ctrl + j` `ctrl + k` 上下移動
```
sudo apt update
sudo apt upgrade

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
source ~/.bashrc
```

## 安裝 navi
參考[官方](https://github.com/denisidoro/navi#installation)
安裝這個 navi 滿雷的 , 我最後退回到 v2.15.0 才跑得起來 , 平常沒在用 git 的 tag 功能查了下才知道還有這鬼東西
```
cd ~
sudo git clone --depth 1 https://github.com/denisidoro/navi
cd navi
sudo git fetch --all --tags
sudo apt-get install cargo
sudo git checkout tags/v2.15.0
sudo make install
```

都安裝好後可以自己蓋個檔案來玩看看 , 注意副檔名要是 `.cheat` , 可以把自己常用的一些 script 寫進來方便用
`%` 符號是 大類 `#` 是小類 , 還滿直覺的
docker.cheat
```
% docker 掛狗大全

# docker container 幫助
docker container --help

# docker 幫助串 grep
docker --help | grep --color container

# docker 列出 container
docker container ls

# docker 列出 image
docker image ls

# docker helloworld
docker run hello-world

# docker 列出停止的 container
docker container ls -a

# docker 列出停止的 container
docker container ls -a

# docker 跑 busybox
docker run -it busybox sh

# docker 跑 dotnet core
docker run -it --rm mcr.microsoft.com/dotnet/sdk dotnet

# docker 跑 nginx
docker run --name nginx -d -p 8080:80 nginx

# docker 查歷史
docker history 22d

# docker 查 log
docker logs 418

# docker 查 container 詳細訊息
docker inspect 418

# docker 拉 hello-world
docker pull hello-world

# docker 刪除沒用的 container
docker container prune

# docker 附加到 container 上
docker attach 7d3

# docker 啟動停止的容器
docker start 723

# docker 跳進容器 (bash)
docker exec -it 23d /bin/bash

# docker 死亡指令 (注意不要亂用 機器會爆炸)
echo "docker run -v /:/data busybox rm -rf /"

# docker 拉 imagemagick
docker pull dpokidov/imagemagick

# docker 轉換圖片為 ico
docker run -v ~/imgs:/imgs dpokidov/imagemagick -background transparent /imgs/kuai.png -define icon:auto-resize=16,24,32,48,64,72,96,128,258 /imgs/kuai.ico

# docker 建立 volume
docker volume create test

# docker 執行 imagemagick 在 volume 上
docker run -v test:imgs -d -it --entrypoint-/bin/bash dpokidov/imagemagick

# docker 查網路
docker network ls

# docker 讓網路跑在 host 上
docker run -d --network=host nginx

# docker 網路跑橋接
docker run -d -p 8080:80 --network=bridge nginx

# docker 查 container 內的 ip
docker inspect 345 | grep -i ipaddress

# docker container 網路用其他 container 的網路
docker run -it --net=container:345 nginx

# docker 查 pid
docker inspect 2f3 | grep -i pid

# nsenter 看 docker 網路
sudo nsenter -t 12342 -n

# docker 看 netns
sudo ls /var/run/docker/netns

# docker 打標籤 tag
docker tag dotnet-cowsay:latest dotnet-cowsay:latest


# docker 打標籤 tag remote
docker tag dotnet-cowsay:latest 172.18.22.33/dotnet-cowsay:latest

# docker login harbor
docker login http://10.1.2.123 --username admin --password Harbor12345

# docker commit
docker commit -m "cowsay" -c "ENV PATH=$PATH:/usr/games" 1234asfw dotnet5-new-cowsay

# docker 搭配 jq 輸出 raw
ls $(docker inspect test | jq -r ".[0].Mountpoint")

# docker 持續監控 log
docker logs s12 -f -t
```

接著讀取自己的檔案看看 , 如果按了 enter 會直接把 command 執行在 terminal
如果加了 --print 參數會把 command 寫在畫面上不會直接執行
```
navi --path .
navi --path . --print

docker 掛狗大全  docker image 用法    docker image ls  ⠀
docker 掛狗大全  docker 用法          docker container ls  ⠀
```


## tldr
ubuntu 20 基本上無腦安裝 , 老實說這個訊息量確實少了很多 , 有好有壞
```
sudo apt-get install tldr
#測看看 docker 用法
tldr docker
```

## 安裝 thefuck
https://github.com/nvbn/thefuck
```
sudo apt-get install -y pip
pip install thefuck

vim ~/.bashrc
PATH=$PATH:/home/vagrant/.local/bin
source ~/.bashrc

fuck
#Seems like fuck alias isn't configured!
#Please put eval "$(thefuck --alias)" in your ~/.bashrc and apply changes with source ~/.bashrc or restart your shell.
#Or run fuck a second time to configure it automatically.
#More details - https://github.com/nvbn/thefuck#manual-installation
source ~/.bashrc

```

## 其他好玩咚咚
https://github.com/agarrharr/awesome-cli-apps
https://github.com/alebcay/awesome-shell
https://vim.reversed.top/
