---
title: Android Studio vim mode
date: 2021-02-21 17:05:51
tags:
- vim
top: true
---
&nbsp;
<!-- more -->

### 內文
因為有選擇障礙, 想說來開發個 APP 所以轉戰 kotlin 萬事起頭難 , 還好之前有 vscode 跟 visual studio 使用 vim 經驗
設定字體 => `File` => `Settings` => `Editor` => `Font` => `Fira Code` => `Enable font ligatures 打勾`
設定背景豆沙色 => `File` => `Settings` => `Editor` => `Color Scheme` => `General` => `Text` => `Default text` => `#EFFFEF`
安裝 Plugin => `File` => `Settings` => `Plugins` => `IdeaVim`
一開始找不到 vimrc 位置後來看了老外才知道原來是在 `~/.ideavimrc`
順帶一提在 intelli sense 移動有支援 vim 的熱鍵 `ctrl + n` `ctrl + p`
設定 keymap => `File` => `Settings` => `Get more keymaps in setting` => `VSCode Keymap` 安裝完記得要 Apply
感覺 Android Studio 跟 intellij 出自同源不花錢就能享受到 intellij 流暢的功能還真是開心啊!
[kotlin 跟 csharp 的語法比較小抄](https://ttu.github.io/kotlin-is-like-csharp/)

### 使用 EAP 開啟 NERDTree
在 `Settings` => `Plugins` => 點齒輪 => `Manage Plugin Repositories` 加上這段 url `https://plugins.jetbrains.com/plugins/eap/ideavim`
撰寫這篇剛好看到 NERDTree 的功能被實做出來了 就順便設定看看
記得要在 `~/.ideavimrc` 設定 `set NERDTree` 就搞定了

### 上下移動 intellisense 選單
套用之前很常用 `alt+j alt+k` 來進行移動 , 找了半天只有個[非完美解]( https://stackoverflow.com/questions/30149091/how-to-configure-in-ideavim-ctrl-n-and-ctrl-p-completion-from-vim)
在 `File` => `Settings` => `Keymap` => 搜尋 `Cyclic Expand Word` 改成 `alt + j` 接著搜 `Cyclic Expand Word (Backward)` 改成 `alt + k`
然後再 .ideavimrc 裡面設定以下 remap 就可以用了
```
"設定 intellisense 選單用 alt+j & alt+k
imap <M-j> <ESC>:action HippieCompletion<CR>a
imap <M-k> <ESC>:action HippieBackwardCompletion<CR>a
```

### full config 這邊幾乎偷懶先用 emacs 大師的
```
let mapleader = ","   " leader is comma
let localleader = "," " leader is comma

set tabstop=4       " number of visual spaces per TAB
set softtabstop=4   " number of spaces in tab when editing
set shiftwidth=4    " spaces in newline start
set expandtab       " tabs are spaces
set number              " show line numbers
set rnu                 " show relative line numbers
set showcmd             " show command in bottom bar
set cursorline          " highlight current line
set surround            " use surround shortcuts
set commentary "vim-commentary
filetype indent on      " load filetype-specific indent files
set wildmenu            " visual autocomplete for command menu
set showmatch           " highlight matching [{()}]
set timeoutlen=500      " timeout for key combinations

set so=5                " lines to cursor
set backspace=2         " make backspace work like most other apps
set incsearch           " search as characters are entered
set hlsearch            " highlight matches
set ignorecase          " do case insensitive matching
set smartcase           " do smart case matching
set hidden

set fillchars+=stl:\ ,stlnc:\
set laststatus=2
set clipboard=unnamedplus  "X clipboard as unnamed
set NERDTree

"press kj to exit insert mode
"imap kj <Esc>
"vmap kj <Esc>
imap ,, <Esc>
vmap ,, <Esc>
noremap ,, <Esc>

"reload
map ,so :source ~/.ideavimrc<CR>

"@see https://youtrack.jetbrains.com/issue/VIM-510 on expand selected region. Press `Ctrl-W` and `Ctrl-Shift-W` to increase and decrease selected region

noremap ,xm :action SearchEverywhere<CR>
noremap ,ci :action CommentByLineComment<CR>
noremap ,xs :action SaveAll<CR>
noremap ,aa :action $Copy<CR>
noremap ,zz :action $Paste<CR>
noremap ,yy :action PasteMultiple<CR>
noremap ,qq :action FindInPath<CR>
noremap ,ss :action Find<CR>
noremap ,fp :action CopyPaths<CR>
noremap ,xk :action CloseEditor<CR>
noremap ,rr :action RecentFiles<CR>
noremap ,kk :action GotoFile<CR>
noremap ,ii :action GotoSymbol<CR>
noremap <C-]> :action GotoImplementation<CR>
noremap ,xz :action ActivateTerminalToolWindow<CR>

" ideavim don't support numberic character in hotkey in 0.55
" it's fixed in 0.55.1
noremap ,x1 <C-W>o
noremap ,x2 :split<CR>
noremap ,x3 :vsplit<CR>
noremap ,x0 :q<CR>
" move window
noremap ,wh <C-W>h
noremap ,wl <C-W>l
noremap ,wj <C-W>j
noremap ,wk <C-W>k
noremap ,xx :action EditorSelectWord<CR>

noremap ,ff :action ToggleDistractionFreeMode<CR>

"設定 intellisense 選單用 alt+j & alt+k
imap <M-j> <ESC>:action HippieCompletion<CR>a
imap <M-k> <ESC>:action HippieBackwardCompletion<CR>a
```

### 其他資源
[內容還不錯的教學 , 不過聲音太有點硬](https://www.youtube.com/watch?v=FkL17L_gokc)
[內容還不錯的教學 , vim ](https://www.youtube.com/watch?v=Yk4s-WLjxug)
