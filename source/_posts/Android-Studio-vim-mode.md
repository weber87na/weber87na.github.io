---
title: Android Studio vim mode
date: 2021-02-21 17:05:51
tags:
- vim
top: true
---
&nbsp;
<!-- more -->

### 課程與書籍推薦
#### 收費課程
1. [大神 91 老師的極速開發課程](https://tdd.best/courses/)
這個課算是我學 `vim` 操作的啟發 , 接案公司要趕時間 , 偏偏就是沒那麼多時間 , 於是才找到這門課 , 結果排了一年才上到
價格約 `1.w` 左右的摳摳 , 著重怎麼用 vim + ide 整合提升開發速度 , 也是有很多神奇技巧跟密技心法 , 建議先把下面的免費仔課程看完才去上 , 讚!

2. [Emacs 大神如何提高編程速度](https://www.udemy.com/course/how-to-code-faster-zh/)
emacs 大師 [vscode matchit 作者](https://marketplace.visualstudio.com/items?itemName=redguardtoo.matchit)
emacs 大師 , 只能用無敵來形容 , 內容硬核建議完整看完高見龍老師的 vim 教學才看 , 雖然也會帶你走一次 vim 基本操作 , 不過步調很快
大約 `2000` 元左右的摳摳就能享受到很多很實用的技巧 , 還有許多正常人想不出的神祕技法 , 讚!

#### 佛心免費仔課程
1. [五倍紅寶石 高見龍 高見龍老師](https://www.youtube.com/watch?v=mPVwS8gjDVI&list=PLBd8JGCAcUAH56L2CYF7SmWJYKwHQYUDI&index=2)
使用純 `vim` 進行教學 , 想要完整學會整個 `vim` 的話必看 , 熬過去就是你的 , 價值真的無價 , 佛心啊~

2. [橫跨北美的工程師 Victor](https://www.youtube.com/watch?v=rzpoMlss7Kk&list=PLL7OBcW31PnJTOFMzvA14-Pq9cfuu9gGB)
他的教學超讚 , 適合睡前花點小時間玩看看 , 講解也很口語化很好懂 , 佛心~

3. [Gamma Ray 軟體工作室](https://www.youtube.com/watch?v=Yk4s-WLjxug)
這個是 `2021` 年才看到的 , 內容是很棒 , 也很用心製作 , 就是聲音有點生硬 , 看他直播 coding 反而比較自然 , 也是很值得推薦


#### 書籍資源推薦
1. [Vim 實用技巧](https://www.tenlong.com.tw/products/9787115427861?list_name=srh)
我一開始是買這本書來翻 , 認真練大概 1 - 2 週就可以看完 , 搭配上面的課程整個過完大概也會得差不多

2. [精通 Vim : 用 Vim 8 和 Neovim 實現高效開發](https://www.tenlong.com.tw/products/9787121383281?list_name=srh)
這本是後來看到的應該是 `Vim 實用技巧` 的姊妹作 , 印象中有多講 neovim , 有點 cookbook 的感覺

3. [Vim 8 文本處理實戰 (](https://www.tenlong.com.tw/products/9787115527059?list_name=srh)
這本也是後來才發現的 , 有講些別於 `Vim 實用技巧` 以外的東東 , 考量摳摳的話可以只看 `Vim 實用技巧` 就好



### 基本設定
因為有選擇障礙, 想說來開發個 APP 所以轉戰 kotlin 萬事起頭難 , 還好之前有 vscode 跟 visual studio 使用 vim 經驗
設定字體 => `File` => `Settings` => `Editor` => `Font` => `Fira Code` => `Enable font ligatures 打勾`
設定背景豆沙色 => `File` => `Settings` => `Editor` => `Color Scheme` => `General` => `Text` => `Default text` => `#EFFFEF`
安裝 Plugin => `File` => `Settings` => `Plugins` => `IdeaVim`
一開始找不到 vimrc 位置後來看了老外才知道原來是在 `~/.ideavimrc`
順帶一提在 intelli sense 移動有支援 vim 的熱鍵 `ctrl + n` `ctrl + p`
設定 keymap => `File` => `Settings` => `Get more keymaps in setting` => `VSCode Keymap` 安裝完記得要 Apply
感覺 Android Studio 跟 intellij 出自同源不花錢就能享受到 intellij 流暢的功能還真是開心啊!
[kotlin 跟 csharp 的語法比較小抄](https://ttu.github.io/kotlin-is-like-csharp/)

後來發現中文字體看起來就是怪怪的很醜 , 請調整 `fallback font` => `Microsoft JhengHei`
萬一有按鍵發生衝突可以這樣設定 `File` => `Settings` => `Editor => `Vim Emulation`

### 使用 EAP 開啟 NERDTree
在 `Settings` => `Plugins` => 點齒輪 => `Manage Plugin Repositories` 加上這段 url `https://plugins.jetbrains.com/plugins/eap/ideavim`
撰寫這篇剛好看到 NERDTree 的功能被實做出來了 就順便設定看看
記得要在 `~/.ideavimrc` 設定 `set NERDTree` 就搞定了

### 上下移動 Hippie Completion
套用之前很常用 `alt+j alt+k` 來進行移動 intellisense , 暫時沒找到類似設定 , 找了半天只有個[非完美解]( https://stackoverflow.com/questions/30149091/how-to-configure-in-ideavim-ctrl-n-and-ctrl-p-completion-from-vim)
所以把這個 key bind 讓給 Hippie Completion , 後來覺得用預設的 `alt + /` 其實就夠了 , 不過還是筆記下
在 `File` => `Settings` => `Keymap` => 搜尋 `Cyclic Expand Word` 改成 `alt + j` 接著搜 `Cyclic Expand Word (Backward)` 改成 `alt + k`
然後再 .ideavimrc 裡面設定以下 remap 就可以用了
```
"設定 hippie completion 用 alt+j & alt+k
imap <M-j> <ESC>:action HippieCompletion<CR>a
imap <M-k> <ESC>:action HippieBackwardCompletion<CR>a
```

### 電燈泡的秘密
用過 visual studio or jetbrains 系列的人應該都知道可以用 `ctrl + .` 叫出約會殺手電燈泡 , [補個我做的電燈泡圖](https://hcizcummqz5rubajpp5diq-on.drv.tw/www/snowman/) 
接著燈泡就會給出很多建議像是吃西餐還是日本料理之類的 , 偏偏又有選擇障礙 , 選起來很困難就會開始用滑鼠去點 , 其實可以用 `tab` 往下移動 `shift + tab` 往上移動


### AceJump
[安裝網址](https://plugins.jetbrains.com/plugin/7086-acejump)
跟 visual studio 的預期效果不太一樣 , 需要按下 `space` 以後 , 接著輸入關鍵字像是找 `class` 必須要先敲 `a` 這樣才會 work
`.ideavimrc` 設定
```
nmap <space> :action AceAction<CR>
```

### 設定 1.8 新功能 matchit
今天很振奮的看到一個超有用的功能 `matchit` 終於有支援了 , 大概是不想被 emacs 大師嘴?
[changes](https://github.com/JetBrains/ideavim/blob/master/CHANGES.md)
設定方法參考[這篇說明](https://github.com/JetBrains/ideavim/wiki/Emulated-plugins)
本來以為預設是開啟 , 沒想到還要自己手動開啟
老樣子在 `.ideavimrc` 加入這行然後重新載入一下 `:source ~/.ideavimrc`
```
"1.8新增功能
set matchit
```
接著就可以爽用 `%` 符號在 html tag 開頭結尾遊走 , 不需要再用 `vato` 接著 `o` 這種變態的智障方法操作 , 祈禱 visual studio vim 的作者也快點搞出來吧


### 設定 1.8 新功能指定 config
預設都是讀取 `.ideavimrc` 這個檔案 , 但是如果寫好幾種語言的話大概就會有這個需求 , 官方現在提供了用 vimscript 的方式去客製這個部分
可以參考他這個[說明](https://github.com/JetBrains/ideavim#vim-script)
不過目前我好像還用不太到 , 能想到的是判斷哪個 ide 去讀取那個 ide 的 config
```
set nu
set relativenumber

if has('ide')
  " mappings and options that exist only in IdeaVim
  map <leader>f <Action>(GotoFile)
  map <leader>g <Action>(FindInPath)
  map <leader>b <Action>(Switcher)

  if &ide =~? 'intellij idea'
    if &ide =~? 'community'
      " some mappings and options for IntelliJ IDEA Community Edition
    elseif &ide =~? 'ultimate'
      " some mappings and options for IntelliJ IDEA Ultimate Edition
    endif
  elseif &ide =~? 'pycharm'
    " PyCharm specific mappings and options
  endif
else
  " some mappings for Vim/Neovim
  nnoremap <leader>f <cmd>Telescope find_files<cr>
endif
```

### exchange 交換單字或是行的功能
最近遇到一個很賭爛的需求 , 就是要交換一堆單字 , 以前對這種交換的認知大概就是個跑龍套 , 今天特別搞看看 , 主要參考[這篇](https://github.com/tommcdo/vim-exchange)
首先需要在 `.ideavimrc` 手動開啟
```
set exchange
```

操作方式
在第一個要交換的單字敲上 `cxiw` 他會亮起黃色 , 然後移動到第二個單字一樣敲上 `cxiw` 就搞定

before
```
hello world
```

after
```
world hello
```

`cxx` 則是交換行
假設想交換 `hello world` 跟 `world hello`
先在 `hello world` 這行敲上 `cxx` 一樣會整行亮起黃色 , 接著移動到 `world hello` 敲 `cxx` 就搞定了
before
```
hello world
喇低賽
world hello
```

after
```
world hello
喇低賽
hello world
```

想清除交換的動作則用 `cxc`


### Surround 筆記
最近又跑來搞前端真的悲劇 , 筆記一下遇到的問題 , Surround [操作參考](https://github.com/tpope/vim-surround)

記得設定 `.ideavimrc` 啟動 surround
```
set surround " use surround shortcuts
```

visual mode 操作

在 angular 常常會有這樣的需求要包中括號
例如 `class.bg-info` 可以用呼叫 `EditorSelectWord` 快速選起來 , 我是 bind `,xx`
或是用 `veeeee` 直接選都可 , 接著用 `S[` 就可以包起來 , 最後就長這樣
特別要注意到操作要連貫 , 不然呼叫 `S` 的時候會失效 , 變成 vim 的整行消除
```
<div [class.bg-info]=""></div>
```

另外 JetBrain 系列的 IDE 都有 `SurroundWith` 這個功能 , 也可以善加利用來包東西
`.ideavimrc` 設定
```
vmap ,sr :action SurroundWith<CR>
```

### 反向 Surround
最近時不時會用到移除 html tag 的功能 , 之前都是包裹比較多 , 特別研究看看
可以參考這份看有啥[actionlist](https://gist.github.com/zchee/9c78f91cc5ad771c1f5d)
預設熱鍵 `ctrl` + `shift` + `delete`
老樣子編輯 `.ideavimrc` , 我是設定 `,dsr` 就可以快樂移除
vscode 也有類似的功能可以參考[這篇](https://stackoverflow.com/questions/49336584/is-there-a-quick-way-to-delete-an-html-tag-pair-in-vscode)
```
vmap ,dsr :action Unwrap<CR>
```


### 窮人的 JSP Support
主要參考自[這個老外的方法](https://blog.softhints.com/intellij-community-edition-add-css-jsp-syntax-highlighting/#addcssjspsyntaxhighlightingtointellij)
還有[這篇](https://stackoverflow.com/questions/33782187/intellij-community-edition-jsp-syntax-highlighting/35439692)
cd 到這個目錄底下 `%APPDATA%\JetBrains`
把下面這串另存成 `Custom JSP.xml` 貼進去這個路徑 `%APPDATA%\JetBrains\IdeaIC2021.1\filetypes\Custom JSP.xml`
這樣就可以得到一個半殘的高亮 , 只能用悲劇 , 還是乖乖花錢買比較實在

```
<filetype binary="false" description="Custom JSP" name="Custom JSP">
  <highlighting>
    <options>
      <option name="LINE_COMMENT" value="" />
      <option name="COMMENT_START" value="" />
      <option name="COMMENT_END" value="" />
      <option name="HEX_PREFIX" value="" />
      <option name="NUM_POSTFIXES" value="" />
    </options>
    <keywords keywords="%&gt;;&lt;%!;&lt;%@;include;page;taglib" ignore_case="false" />
    <keywords2 keywords="c:choose;c:if;c:otherwise;c:set;c:url;c:when;fmt:message;fmt:setBundle;fmt:setLocale;s:eval;s:message;sec:authorize" />
    <keywords3 keywords="a;body;br;button;div;footer;form;h1;h2;h3;h4;h5;head;header;hr;html;i;img;input;label;li;meta;nav;noscript;ol;p;script;section;span;style;submit;table;td;textarea;th;title;tr;ul" />
    <keywords4 keywords="alert;boolean;case;char;confirm;console;continue;do;else;false;for;forms;function;if;length;let;return;this;thows;true;var;while;with" />
  </highlighting>
  <extensionMap>
    <mapping ext="jsp" />
  </extensionMap>
</filetype>
```

### 設定 Html Tag 屬性引號預設值
因為在 vscode 上面預設好像是雙引號 , 可是 webstorm 上面則是單引號 , 所幸查看看 , [參考自老外](https://stackoverflow.com/questions/35918707/how-to-make-webstorm-reformatting-source-code-to-change-double-quotes-to-singl)
`File` => `Settings` => `Editor` => `Code Style` => `Html` => `Other` => `Generated quote marks`


### 啟用 CodeMap
這個功能在 visual studio 上面也用滿多年的 , 螢幕比較大的話多半會開啟他 , 查了下預設在 Jetbrain 系列的 ide 好像沒有
乖乖安裝這個 [CodeGlance](https://github.com/vektah/CodeGlance) plugin 當隻掛狗 , 裝完記得重開 ide

### 透明視窗設定
不曉得為啥 , 我不太能適應黑色佈景與白底的網頁或是看紙本書籍之間的切換 , 眼睛會很不舒服
所以大多數情況下我會使用白色主題佈景然後底用綠色的豆沙色 , 如果必須使用黑色佈景我會想辦法加上透明度 , 這樣就會緩解眼睛的不適

原生的 jetbrains ide 有沒有可以設定整個視窗透明的功能我沒特別研究過 , 不過可以用看看這個古老軟體 [Glass2k](https://chime.tv/products/glass2k.shtml)
算是一種萬用的解法 , 大多數的視窗好像都可以透明 , 我測 notepad++ , jetbrains 系列可以 , 不過 visual studio 不能 , 真的悲劇 , 冏

除了緩解眼睛的不適外還有個好處是可以把需求放在底下 , 這樣就不用一直接換視窗或是用雙螢幕也可以直接看到需求寫啥 , 我就免費仔 ~
我自己是設定桌面為純色黑色 , 然後 `右鍵` => `檢視` => `顯示桌面圖示` 讓桌面整個乾淨


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

"1.8新增功能快速移動到 html tag 頭尾
set matchit

"交換單字或是行
set exchange

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

"頭尾移動
nmap zl $
imap zl <End>

nmap zh ^
imap zh <Esc>^i

nmap z; $a;<Esc>
imap z; <Esc>$a;

nmap z, $a,<Esc>
imap z, <Esc>$a,

"包裹
vmap ,sr :action SurroundWith<CR>
vmap ,dsr :action Unwrap<CR>

"ace jump
nmap <space> :action AceAction<CR>

"設定跳到錯誤
nmap zn :action GotoNextError<CR>
imap zn <Esc>:action GotoNextError<CR>i
```

### 其他阿薩布魯問題
參考[這篇](https://stackoverflow.com/questions/60092405/untrusted-server-certificate-in-intellij)
rider server's certificate is not trusted
`Preferences` => `Tools` => `Server Certificates` => `Check on Accept non-trusted certificates automatically`
