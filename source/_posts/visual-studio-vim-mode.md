---
title: visual studio vim mode
date: 2020-07-05 15:22:58
tags:
- vim
- visual studio
- vsvim
top: true
---
&nbsp;
<!-- more -->
## 內文
### 基本設定
前陣子學習 vim mode 想替自己增加開發效率 , 以下為設定筆記

還不錯的兩個教學
- [五倍紅寶石](https://www.youtube.com/watch?v=mPVwS8gjDVI&amp;list=PLBd8JGCAcUAH56L2CYF7SmWJYKwHQYUDI&amp;index=1)
- [Victor Lee](https://www.youtube.com/watch?v=rzpoMlss7Kk&amp;list=PLL7OBcW31PnJTOFMzvA14-Pq9cfuu9gGB)

[安裝 vim mode 外掛](https://marketplace.visualstudio.com/items?itemName=JaredParMSFT.VsVim)
設定可以[參考](https://www.cnblogs.com/qiyuexin/p/10424755.html)這個大陸人
解決衝突(可以把`ctrl + f` 設定為用 Visual Studio 不要用 vim 的往上翻功能 看個人喜好 , 個人是覺得用 `ctrl + u`就很夠用)

在工具->選項->VsVim中設定解決衝突

接著切換目錄到C:\Users\你的使用者名稱
建立一個_vimrc檔案設定以下內容
```
set clipboard=unnamed
set number
```
(相對行號等等會裝外掛解決可以不加)
`set relativenumber`

[安裝相對行號外掛](https://marketplace.visualstudio.com/items?itemName=BrianSchmitt.RelativeNumber)

設定相對行號的樣式 , 我是背景設定黑色 , 文字設定紅色看個人愛好

Tools-&gt;Options-&gt;Environment-&gt;Font and Colors and set the &quot;Relative Number - Current Line&quot; property.

[安裝快速切換註解外掛 toggle comment](https://marketplace.visualstudio.com/items?itemName=munyabe.ToggleComment)
這個外掛可以用 `ctrl + /` 切換註解相當方便

如果沒有英文語言套件最好裝一下
開啟 visual studio installer安裝英文語言套件!

接著開啟
工具-&gt;選項-&gt;環境-&gt;國際設定-&gt;English

設定當使用 IntelliSense 跳出來要選擇時使用 `Alt + J (向下移動) Alt + K (向上移動)`
Tools-&gt;Options-&gt;Environment-&gt;Keyboard
接著在 `Show commands containing` 裡面搜尋 `Edit.LineDown`
在 `Press shortcut keys` 裡面按下 `Alt + J` 同理設定 `Edit.LineUp` 修改為 `Alt + K`

使用[NERDTree](https://github.com/stevium/vs-nerdx)
[下載](https://marketplace.visualstudio.com/items?itemName=mstevius.vs-nerdx-solution-explorer)
最重要的快捷不動滑鼠移動到專案總管，其他熱鍵就參考官網說明吧..
`ctrl + alt + l`
要切回寫 code 視窗則是 `ctrl + f6`

在專案開啟檔案總管 `ProjectandSolutionContextMenus.Project.OpenFolderinFileExplorer`

設定不要使用 preview tab 功能
tools => options => envionment => tabs and windows => Preview Tab => allow new files to be opened in the preview tab

在 vsvim 執行 visual studio 命令可以像以下這樣
例如一個很常見的操作將 code block 包裹起來 (warp/surround)
`:vsc Edit.SurroundWith`
或是快速新增類別
`:vsc Project.AddClass`
甚至是列出 Members
`:vsc ListMembers`

### 設定 method 提示
之前一直有個困擾就是滑鼠移到某個 method 時會顯示提示在 vscode vim mode 可以用 gh 讓鍵盤直接 show 出來，
但是用了很多年的 visual studio 卻不曉得要怎麼調整，花了半年終於找到了!
原來是 `Edit.QuickInfo` 預設好像是 `ctrl+k ctrl+i` 為了跟 vscode 盡量一致修改為 `alt+g alt+h`

### 設定 mvc
有陣子沒寫 mvc 了，不太有印象 go to view 的功能是啥熱鍵，自己自訂 `EditorContextMenus.CodeWindow.GoToView` 為 `alt+g alt+v`
順便在定義一下關閉右側視窗 `File.CloseAllButThis` 為 `alt+c alt+r`

### 設定 vsvimrc
今天研究一下 vsvim 的 config 如下
`:set vimrc?`
重新 load config
`:so ~/_vsvimrc`

### 自訂 template 技巧
後來參考這個[變態中國佬](https://www.bilibili.com/video/BV1r4411G7de?from=search&seid=17984154817972931817)偷學兩招
第一招可以加入自訂的 template 替換想要的內容，有點像鬍子變數的感覺
第二招太常打類似 new Car() 這種操作，用這招可以快速在建立類別時補全
```
" template
map <LEADER><LEADER> <ESC> /<++><CR>:nohlsearch<CR>c4l

" add var x = 
map <LEADER>vx ^ivar x = <ESC> bbciw
```
中國佬還教一招可以用 vim 轉換 html 這招以前沒看 cool
`:%TOhtml`

### trim 技巧
這是看 java script 忍者書學到的 , 用這招可以讓亂七八糟的文件馬上乖乖聽話掐頭去尾
```
^\s+|\s+$
```

### 快速替換為 Nullable
正則快速替換為 nullable
```
public (bool|int|decimal|long)([?])
public $1

public (bool|int|decimal|long)
public $1?
```

### 自動產生類別屬性片段
每次要手動 mapping 要打一堆字很賭爛，今天想一個辦法解決，在專案按下右鍵 initialize interactive with Project 接著 using 需要的 namespace
最後把下面這句貼上就可以快速運用 interactive 視窗去產生程式碼了，唯一缺點就是還要用到滑鼠，也可以直接用 `View.C#Interactive` 開啟
注意在這個 Intercative 裡面也是可以用 `alt + j` `alt + k` 去進行移動
其他詳細用法 [interactive](https://dailydotnettips.com/executing-c-scripts-from-command-line-or-c-interactive-windows-in-visual-studio/)
後來發現這個在 .net core 上面好像還沒有被直接整合在 visual studio 裡面

load dll
```
#r c:\yourdll.dll
```

有趣用法直接執行 Program 裡面的 Console 程式
```
#r c:\yourapp.exe
using YourConsole;
Program.Main( null );
```

利用反射產生屬性片段
```
var x = new YourObject(); var t = x.GetType(); foreach (var prop in t.GetProperties()) Console.WriteLine( $"x.{prop.Name} = " );
```
也可以把這種片段做成 template 然後執行以下指令就可以快速插入
```
:read d:\template\generate-full-prop.txt
```

### 自動產生類別屬性片段(新)
使用變態老外的 extension [CsharpMacros](https://github.com/cezarypiatek/CsharpMacros) 來進行產生屬性 , 後來找到這個方法簡潔多了! 感恩老外!
看這老外是運用 roslyn 來達成這套功能 , 屌!
```
var x = new LaSai();
//marcos.properties(LaSai)
//p.${name} = 
```

### JSON To CSharp 類別
將 JSON 快速轉換 csharp 類別 `Edit.PasteJSONAsClasses` 注意 Clipboard 裡面要先有 JSON 才可以快速產生

### multi cursor 操作技巧
類似 vscode multi cursor 的功能 `Edit.InsertNextMatchingCaret` `Edit.InsertCaretsatAllMatching` 注意使用以後是 visual mode 這時候按下 `o` 是會來回在頭尾切換，
需要多按 `esc` 接著就可以模擬類似 multi cursor 的功能

### 快速切換資料型別
常常開立類別時型別喬不定換來換去換到煩乾脆寫個 mapping
to 方便記憶用 2 string bool float decimal 最懶直接用 var
切換 true false 用 toggle 所以用 t 當作切換方便記憶 true or false
其實可以考慮加上回到開頭 ^ 不過就先暫時這樣吧
```
"to string
nmap <Leader>2s viwxistring<Esc>

"to bool
nmap <Leader>2b viwxibool<Esc>

"to float
nmap <Leader>2f viwxifloat<Esc>

"to decimal
nmap <Leader>2d viwxidecimal<Esc>

"to var
nmap <Leader>2v viwxivar<Esc>

"toogle true
nmap <Leader>tt viwxitrue<Esc>

"toogle false
nmap <Leader>tf viwxifalse<Esc>
```

### ReSharper Source Template
這功能第一次看到還真的覺得懷疑人生，怎麼會有如此噁心的功能，不過身為一個免費仔只能 30 天玩玩
第一次見到是這種自動補 var 的功能，很多時候先輸入 new List<string>{}; 接著再補 var ，有這功能馬上就做完了
希望有空可以搞個窮人版，直接用 vim 來模擬
預設的 [Postfix Templates](https://www.jetbrains.com/help/resharper/Reference__Options__Environment__Postfix_Templates.html#list) 在 `ReSharper` => `General` => `Options` => `Code Editing` => `Postfix Templates`
先在 nuget 安裝 JetBrains.Annotations
`using JetBrains.Annotations;`
[參考自老外](https://stackoverflow.com/questions/50413835/how-to-add-a-cw-postfix-template-in-visual-studio-resharper-like-sout-template)
``` csharp
    public static class ResharperHelper
    {
        [SourceTemplate]
        public static void cw(this string str)
        {
            Console.WriteLine(str);
            //$ $END$
        }
    }
```
接著就可以在 visual studio 打出魔法般的操作 
輸入類似這樣 => `yourString.cw` 輸出 `Console.WriteLine(yourString);`
後來發現有[老外](https://marketplace.visualstudio.com/items?itemName=ipatalas.vscode-postfix-ts)在 vscode 的 js/ts 上有搞出來這功能，真是佛心來著
然後連 [python](https://marketplace.visualstudio.com/items?itemName=filwaline.vscode-postfix-python) 也有結果 visual studio 自己沒有，暈倒

### 取代 prop 產生屬性的技巧 ZenSharp
Emmet官方死變態老外寫的 extension [Emmet.net](https://github.com/sergey-rybalkin/Emmet.net)
在 visual studio 上面的 Emmet 不曉得為啥就是難用 , 不過他這個 ZenSharp 不錯
可以讓我們用 `psp` 這種方式快速產生想要的 member or method 等等 `public string XXX { get;set;}`

### 顯示 var 的型別提示
主要參考這篇[官方說明](https://devblogs.microsoft.com/visualstudio/vs2019-v16-9-and-v16-10-preview-1/)首先要更新到 `Visual Studio 2019 v16.9`
接著設定 `Tools` => `Options` => `Text Editor` => `c#` => `Basic` => `Advanced` => `Display inline type hints`
如果沒辦法用最新版就乖乖安裝[C# Var Type CodeLens](https://marketplace.visualstudio.com/items?itemName=AlexanderGayko.VarAdorner)

## full config
```
"我的 _vsvimrc

"還不錯的老外 config
"https://github.com/keithn/vsvimguide

set clipboard=unnamed
set ignorecase

"重新設定 leader
:let mapleader = ","

"<CR> => Enter 的意思

"first example
"nnoremap <Leader>a :echo "Hello world"<CR>

"editor.action.rename
"使用 Refactor 功能
nmap <Leader>rv :vsc Refactor.Rename<CR>

"大範圍搜尋
"workbench.action.findInFiles
nmap <Leader>qq :vsc Edit.FindinFiles<CR>

"目前文件搜尋
"actions.find
nmap <Leader>ss :vsc Edit.Find<CR>
"選取的時候區域找
vmap <Leader>ss :vsc Edit.Find<CR>

"複製相對路徑
"workbench.action.files.copyPathOfActiveFile

"
"copyRelativeFilePath

"
"workbench.action.togglePanel


"like vscode command
"workbench.action.showCommands
nmap <Leader>xm :vsc View.CommandWindow<CR>

"切換註解
"editor.action.commentLine
nmap <Leader>ci :vsc Edit.ToggleComment<CR>
vmap <Leader>ci :vsc Edit.ToggleComment<CR>

"擴展選取
"editor.action.smartSelect.expand
nmap <Leader>xx :vsc Edit.ExpandSelection<CR>
vmap <Leader>xx :vsc Edit.ExpandSelection<CR>

"反擴展選取
"editor.action.smartSelect.shrink
nmap <Leader>zz :vsc Edit.ContractSelection<CR>
vmap <Leader>zz :vsc Edit.ContractSelection<CR>

"最近開啟的檔案
"workbench.action.openRecent
nmap <Leader>zz :vsc Edit.GoToRecentFile<CR>


"開窗到右側 ctrl + w w 切換窗
":vsplit
"workbench.action.splitEditorRight

"split
nmap <Leader>x1 :vsplit <CR>

"close
nmap <Leader>x0 :q <CR>

" map ;; to Esc
map! <Leader><Leader> <Esc>

"切換到方案總管
nmap ,e :vsc View.SolutionExplorer<CR>

"ctrl + f6
"切回 editor

"gh
map <Leader>gh :vsc Edit.QuickInfo<CR>

"在方案總管開啟資料夾
"nmap ,of :vsc ProjectandSolutionContextMenus.Project.OpenFolderinFileExplorer<CR>


"gb 設定相同字選擇功能
map <Leader>gb :vsc Edit.InsertNextMatchingCaret<CR>

"https://github.com/VsVim/VsVim/issues/1474
" Surround simulating bindings
nnoremap s) ciw(<C-r>")<Esc>
nnoremap s] ciw[<C-r>"]<Esc>
nnoremap s} ciw{<C-r>"}<Esc>
nnoremap s> ciw<lt><C-r>"><Esc>
nnoremap s" ciw"<C-r>""<Esc>
nnoremap s' ciw'<C-r>"'<Esc>
nnoremap sw) ciW(<C-r>")<Esc>
nnoremap sw] ciW[<C-r>"]<Esc>
nnoremap sw} ciW{<C-r>"}<Esc>
nnoremap sw> ciW<lt><C-r>"><Esc>
nnoremap sw" ciW"<C-r>""<Esc>
nnoremap sw' ciW'<C-r>"'<Esc>

" Surround delete bindings
nnoremap ds) vi(dvhp
nnoremap ds] vi[dvhp
nnoremap ds} vi{dvhp
nnoremap ds> vi<dvhp
nnoremap ds" vi"dvhp
nnoremap ds' vi'dvhp

" Surround change bindings
nnoremap cs"' vi"oh<Esc>msvi"l<Esc>cl'<Esc>`scl'<Esc>
nnoremap cs'" vi'oh<Esc>msvi'l<Esc>cl"<Esc>`scl"<Esc>

" Surround visual selected text
vnoremap S" c"<C-r>""<Esc>
vnoremap S' c"<C-r>"'<Esc>
vnoremap S) c(<C-r>")<Esc>
vnoremap S] c[<C-r>"]<Esc>
vnoremap S} c{<C-r>"}<Esc>
vnoremap S> c<lt><C-r>"><Esc>
vnoremap S* c/*<C-r>"*/<Esc>
"vnoremap St c<lt>div><CR><C-r>"<Esc>
" Surround in div tag and edit tag
vnoremap St c<lt>div><CR><C-r>"<Esc>`<lt>lcw


" template
map <LEADER>. <ESC> /<++><CR>:nohlsearch<CR>c4l

" add var x = 
map <LEADER>vx ^ivar x = <ESC> bbciw

"
map <LEADER>gp ^ivar x = new YourObject(); var t = x.GetType(); foreach (var prop in t.GetProperties()) Console.WriteLine( $"x.{prop.Name} = " ); <ESC>

"Json To Chsarp
map <LEADER>c2j :vsc Edit.PasteJSONAsClasses<CR>

"Add New Class
map <Leader>nc :vsc Project.AddClass<CR>

"SurroundWith
map <Leader>sr :vsc Edit.SurroundWith<CR>

"ListMembers
map <Leader>lm :vsc ListMembers<CR>

"so
nmap <Leader>so :so ~/_vsvimrc<CR>

"to string
"nmap <Leader>2s viwxistring<Esc>

"to string use extension
nmap <Leader>2s viw:vsc Tools.ToString<CR>

"to int use extension
nmap <Leader>2i viw:vsc Tools.ToInt<CR>

"to bool
"nmap <Leader>2b viwxibool<Esc>

"to bool use extension
nmap <Leader>2b viw:vsc Tools.ToBool<CR>

"to float
"nmap <Leader>2f viwxifloat<Esc>

"to decimal
"nmap <Leader>2d viwxidecimal<Esc>

"to var
"nmap <Leader>2v viwxivar<Esc>

"to var use extension
nmap <Leader>2v viw:vsc Tools.ToVar<CR>

"to double use extension
nmap <Leader>2f viw:vsc Tools.ToDouble<CR>

"toogle true
"nmap <Leader>tt viwxitrue<Esc>

"toogle false
"nmap <Leader>tf viwxifalse<Esc>

"toogle use extension
nmap <Leader>tt viw:vsc Tools.Toggle<CR>

"to mvc url
nmap <Leader>2u vi'xi@Url.Content("<C-r>"")

"go to file 必須先選中路徑
map <Leader>gf :vsc Tools.GoToFile<CR>

"select current method
map <Leader>vim :vsc Tools.SelectCurrentMethod<CR>

"Move To Method Begin
map <Leader>gmb :vsc Tools.MoveToMethodBegin<CR>

"Move To Method End
map <Leader>gme :vsc Tools.MoveToMethodEnd<CR>

"postfix completion
map <LEADER>. :vsc Tools.PostFixVar<CR>

" 設定尖括號
" set mps+=<:>
```

### codemaid 設定
`extensions` => `codemaid` => `spade`

## 其它 extension
之前看其他教學路影片時會顯示按了什麼按鍵的軟體
[carnac](https://github.com/Code52/carnac)

喇低賽發現新大陸，下列這些 extension 好像也滿有用的趁機筆記一下
- [keyboard Shortcut Exporter](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.KeyboardShortcutExporter)
- 印出快捷鍵在 command window [Learn the Shortcut](https://marketplace.visualstudio.com/items?itemName=MadsKristensen.LearntheShortcut)
- [CodeMaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid)
- 快捷鍵管理 [VSShortcutsManager](https://marketplace.visualstudio.com/items?itemName=JustinClareburtMSFT.VSShortcutsManager)
- 模擬 multi cursor [SelectNextOccurrence](https://marketplace.visualstudio.com/items?itemName=thomaswelen.SelectNextOccurrence)
- 綁一堆 extension 套裝組合 [SublimeVS](https://marketplace.visualstudio.com/items?itemName=JustinClareburtMSFT.SublimeVS)
- 一些文字操作 [VSTricks](https://marketplace.visualstudio.com/items?itemName=CodeMuncher1.VSTricks)
- Emacs 跳躍神器 [AceJump](https://marketplace.visualstudio.com/items?itemName=jsturtevant.AceJump)
- PEasyMotion 滿常當掉[PeasyMotion](https://github.com/msomeone/PeasyMotion)
- 直接顯示 var 型別的[C# Var Type CodeLens](https://marketplace.visualstudio.com/items?itemName=AlexanderGayko.VarAdorner)
- 顯示目前文件路徑在 footer [File Path On Footer](https://marketplace.visualstudio.com/items?itemName=ShemeerNS.FilePathOnFooter)
- 意外發現的超強高手[CsharpMacros 外掛](https://github.com/cezarypiatek/CsharpMacros)
- 意外發現的超強高手[Mapping Generator 外掛](https://github.com/cezarypiatek/MappingGenerator)
- [codemaid](https://marketplace.visualstudio.com/items?itemName=SteveCadwallader.CodeMaid)
