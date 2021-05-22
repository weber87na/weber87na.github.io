---
title: vscode vim mode
date: 2020-07-05 15:04:27
tags:
- vim
- vscode
top: true
---
&nbsp;
<!-- more -->

### config 說明
前陣子學習 vim mode 想替自己增加開發效率 , 以下為設定筆記

還不錯的教學
- [五倍紅寶石](https://www.youtube.com/watch?v=mPVwS8gjDVI&amp;list=PLBd8JGCAcUAH56L2CYF7SmWJYKwHQYUDI&amp;index=1)
- [Victor Lee](https://www.youtube.com/watch?v=rzpoMlss7Kk&amp;list=PLL7OBcW31PnJTOFMzvA14-Pq9cfuu9gGB)
- [boost your coding fu with vscode and vim](https://www.barbarianmeetscoding.com/boost-your-coding-fu-with-vscode-and-vim/table-of-contents)
- [上面那本書作者的 youtube Jaime González García](https://www.youtube.com/c/Vintharas/videos)
- [neovim 對照功能](https://www.youtube.com/watch?v=g4dXZ0RQWdw&feature=youtu.be)

[後來發現還滿特別的config跟extension](https://zhuanlan.zhihu.com/p/73561114)

[安裝 vim mode 外掛](https://github.com/VSCodeVim/Vim)
在 `win + r` 輸入
```
%APPDATA%/Code/User
```
在setting.json加上vim模式的config內容，建議easymotion要打開
有安裝neovim需要開啟整合的話可以打開最後面的設定
```
//vim
"editor.lineNumbers": "relative",
"vim.easymotion": true,
"vim.incsearch": true,
"vim.useSystemClipboard": true,
"vim.useCtrlKeys": true,
"vim.hlsearch": true,
"vim.insertModeKeyBindings": [
{
  "before": ["j", "j"],
  "after": ["<Esc>"]
}
],
"vim.normalModeKeyBindingsNonRecursive": [
{
  "before": ["<leader>", "d"],
  "after": ["d", "d"]
},
{
  "before": ["<C-n>"],
  "commands": [":nohl"]
}
],
"vim.leader": "<space>",
"vim.handleKeys": {
	//"<C-a>": false,
	//"<C-f>": false
}
"vim.enableNeovim" : true,
"vim.neovimPath" : "" 
```
在keybindings.json加上config內容，開intellisense時也使用鍵盤alt+j alt+k 上下移動 , 可以參考[這篇](https://stackoverflow.com/questions/18153541/scrolling-through-visual-studio-intellisense-list-without-mouse-or-keyboard-arro)

注意這邊要照著老外Rocco Ruscitti才正確!

後來發現預設的 `ctrl+n ctrl+p` 也可以完成 intellisense 的上下移動
另外還有另外一種 intellisense 就是補全已經輸入過的片段 `ctrl+x ctrl+l`

困擾幾個月 menu 不能用 jk 移動終於找到[解決辦法](https://stackoverflow.com/questions/56121333/how-to-remap-down-quick-open-menu-in-vscode)感恩老外!

要用[Easymotion可以參考這篇](http://wklken.me/posts/2015/06/07/vim-plugin-easymotion.html)

另外我有設定emmet包裹功能可以參考[老外設定](https://stackoverflow.com/questions/40155875/how-to-do-tag-wrapping-in-vs-code)
特別要注意的是使用 Individual 模式時選擇器需要這樣寫 li* 才會分開包裹
若使用 [vscode  vim surround](https://github.com/VSCodeVim/Vim) 則是在 visual mode 底下輸入大寫 S 以後輸入 <標籤> 這樣就可以包起來了

喇賽看到的老外一些[小技巧](https://gist.github.com/benjamincharity/9349506)
後來研究發現大陸 emacs 大神也有貼[更猛的 config](https://github.com/redguardtoo/vscode-setup/blob/master/settings.json)

```
// 將按鍵繫結關係放在此檔案中以覆寫預設auto[]
[
    {
        "key": "alt+w",
        "command": "editor.emmet.action.wrapWithAbbreviation"
    },
	{
		"key": "alt+i",
		"command": "editor.emmet.action.wrapIndividualLinesWithAbbreviation"
	},
    {
        "key": "alt+j",
        "command": "selectNextSuggestion",
        "when": "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"
    },
    {
        "key": "alt+k",
        "command": "selectPrevSuggestion",
        "when": "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"
    },
	//menu 選擇時 alt+j alt+k 上下移動
	{
	  "key": "alt+j",
	  "command": "workbench.action.quickOpenSelectNext",
	  "when": "inQuickOpen"
	},
	{
	  "key": "alt+k",
	  "command": "workbench.action.quickOpenSelectPrevious",
	  "when": "inQuickOpen"
	}

]
```
最近偶爾會用 terminal 功能可以增加以下片段進行切換動作
```
    //https://stackoverflow.com/questions/42796887/switch-focus-between-editor-and-integrated-terminal-in-visual-studio-code
    // Toggle between terminal and editor focus
    { "key": "ctrl+`", "command": "workbench.action.terminal.focus"},
    { "key": "ctrl+`", "command": "workbench.action.focusActiveEditorGroup", "when": "terminalFocus"}
```

vscode 在 css 裡面使用 go to definition 功能好用外掛[CSS Navigation](https://marketplace.visualstudio.com/items?itemName=pucelle.vscode-css-navigation&ssr=false#overview)
之前一直無法直接使用 gd 在 css 裡面跳，安裝 css peek 也無解，還好發現這套，解決困擾好幾個月的問題，感動
`ctrl + shift + p` 開啟 settings.json 裡面設定讓目前文件也啟用 go to definition 功能
```
"CSNavigation.alsoSearchDefinitionsInStyleTag" : true
```
使用 `gd` 可以直接呼叫 go to definition 的 class or ID 連 Html Tag 也是可以直接跳
使用 `ctrl + o` 或是 `ctrl + i`  可以跳回來

後來發現撰寫 javascript 時需要加入 jsconfig.json 才可以使用 gd 功能
[參考官方文件](https://code.visualstudio.com/docs/nodejs/working-with-javascript#_typings-and-automatic-type-acquisition)
```
{
    "compilerOptions": {
        "target": "ES6"
    },
    "exclude": [
        "node_modules",
        "**/node_modules/*"
    ]
}
```

vscode 切換到檔案列 `ctrl + shift + e`

順便筆記一下小抄
1. [vim 小抄]( https://vim.rtorr.com/lang/zh_tw)
2. [vscode vim 小抄](https://github.com/VSCodeVim/Vim/blob/master/ROADMAP.md)
3. [大陸人寫的功能介紹](https://chengjingchao.com/2020/06/13/VS-Code-%E4%B8%8E-Vim/)
4. [vim ninja 小抄](http://blog.vanutsteen.nl/secrets-of-the-vim-ninja/)

特殊功能筆記
刪除檔案內全部文字
```
:1,$d
```
format documnet 並且跳回原來 cursor 位置  
```
mmgg=G`m
```
或是使用等價方法 `gg=G ` 接著輸入 `ctrl + o `

format documnet 並且跳回行首 ` gg=G''` 

之前常常用 % 來對 tag 進行起始/結尾切換，但是寫 html 完全沒法這樣做，後來發現原來只要 `vat` 接著用 `o` 就可以來回切換。

配合 teamwork 開發 angular 導致 html attribute 又臭又長尋求解法，每個 team member 的 html 空格數也不太一樣所幸找以到下解法
```
"editor.detectIndentation": false,
// The number of spaces a tab is equal to. This setting is overridden based on the file contents when `editor.detectIndentation` is on.
"editor.tabSize": 4,
// Config the editor that making the "space" instead of "tab"
"editor.insertSpaces": true,
"html.format.wrapAttributes": "force",
```

正則表達式搜尋替換
開啟搜尋 `,ss`
切換到替換或搜尋 `ctrl + h`
比較特別的可以用以下操作去進行替換
假設搜尋 pattern `(abc)(def)`
可以用 $1 $2 這種方法去判斷符合的組別，然後去執行一些進階操作，此外還有 $0 為完全匹配
假設我有以下列表想在加號或減號前面都補上乘三
```
1 + 102 = 
11 * 92 = 
111 - 12 = 
```
就可以設樣運用
```
([+-])
* 3 $ 1
```
結果
```
1 * 3 + 102 = 
11 * 92 = 
111 * 3 - 12 = 
```
99 乘法 example
```
var x1 = 1
var x2 = 2
var x3 = 3 
(\s[\d+{1}])
$1 * $1
```
result
```
var x1 = 1 * 1
var x2 = 2 * 2
var x3 = 3 * 3
```
可以看這個[參考](https://blog.darkthread.net/blog/vs-find-replace-regex/)
跟[官方說明](https://docs.microsoft.com/zh-tw/visualstudio/ide/using-regular-expressions-in-visual-studio?view=vs-2019)

直接用 vim 的功能替換，這邊要特別注意替換 pattern 是否有開啟 neovim 有的話會用原生的方式進行替換
vscode
```
:%s/([+-])/* 3 $1/g
```
neovim 啟用原生
```
:%s/\([+-]\)/* 3 \1/g
```
實用技巧在刪除 function 內的變數，自從學會 vim 基本操作以後就很少用 `t` or `T` 這種操作，看到高手用在刪除參數筆記一下
```
#開頭
f(lct,
#結尾
f)dF,
```

參考自這個[大大](https://www.bilibili.com/read/cv9094189)
這個大大提醒一點以前玩遊戲的時候會希望腳色可以瞬間定住開槍，fps遊戲差個0.x毫秒就差很多，在 windows 底下可以這樣設定
`win + r` => `control panel` => `keyboard` => `重複延遲設定最短` => `重複速度設定最快`
交換上下行 `ddp`
交換前後字 `xp`
解決預設 % 不能找到尖括號的問題 `set mps+=<:>`

遇到 IE 要把 html 轉為 js string
```
(<[^>]*>.*)
+ '$1'
```

vim binding
```
string to html
vmap <silent> ;h :s?^\(\s*\)+ '\([^']\+\)',*\s*$?\1\2?g<CR>

"html to js string
vmap <silent> ;q :s?^\(\s*\)\(.*\)\s*$? \1 + '\2'?<CR>
```

vscode binding 滿自虐的
```
"vim.visualModeKeyBindingsNonRecursive": [
{
	"before": [
	";",
	"h"
	],
	"after": [
	//vmap <silent> ;h :s?^\(\s*\)+ '\([^']\+\)',*\s*$?\1\2?g<CR>
	":",
	"s",
	"?",
	"^",
	"\\",
	"(",
	"\\",
	"s",
	"*",
	"\\",
	")",
	"+",
	"'",
	"\\",
	"(",
	"[",
	"^",
	"'",
	"]",
	"\\",
	"+",
	"\\",
	")",
	"'",
	",",
	"*",
	"\\",
	"s",
	"*",
	"$",
	"?",
	"\\",
	"1",
	"\\",
	"2",
	"?",
	"g",

	"<CR>"

	]
},
{
	"before": [
	";",
	"q"
	],
	"after": [
	//vmap <silent> ;q :s?^\(\s*\)\(.*\)\s*$? \1 + '\2'?<CR>
	":",
	"s",
	"?",
	"^",
	"\\",
	"(",
	"\\",
	"s",
	"*",
	"\\",
	")",
	"\\",
	"(",
	".",
	"*",
	"\\",
	")",
	"\\",
	"s",
	"*",
	"$",
	"?",
	"\\",
	"1",
	"+",
	"'",
	"\\",
	"2",
	"'",
	"?",
	"<CR>"

	]
}
}
```

### full keybindings
```
// 將按鍵繫結關係放在此檔案中以覆寫預設auto[]
[
    {
        "key": "alt+w",
        "command": "editor.emmet.action.wrapWithAbbreviation"
    },
    {
        "key": "alt+i",
        "command": "editor.emmet.action.wrapIndividualLinesWithAbbreviation"
    },
    {
        "key": "alt+j",
        "command": "selectNextSuggestion",
        "when": "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"
    },
    {
        "key": "alt+k",
        "command": "selectPrevSuggestion",
        "when": "suggestWidgetMultipleSuggestions && suggestWidgetVisible && textInputFocus"
    },
    //menu 選擇時 alt+j alt+k 上下移動
    {
        "key": "alt+j",
        "command": "workbench.action.quickOpenSelectNext",
        "when": "inQuickOpen"
    },
    {
        "key": "alt+k",
        "command": "workbench.action.quickOpenSelectPrevious",
        "when": "inQuickOpen"
    },
    //https://stackoverflow.com/questions/42796887/switch-focus-between-editor-and-integrated-terminal-in-visual-studio-code
    // Toggle between terminal and editor focus
    { "key": "ctrl+`", "command": "workbench.action.terminal.focus"},
    { "key": "ctrl+`", "command": "workbench.action.focusActiveEditorGroup", "when": "terminalFocus"}
]
```

### full settings
```
{
	"workbench.iconTheme": "material-icon-theme",
		// "workbench.colorTheme": "Solarized Dark",
		"workbench.colorTheme": "Visual Studio Light",
		"workbench.colorCustomizations": {
			"editor.background": "#efffef",
		},
		//fontFamily
		"editor.fontFamily": "Fira Code",
		"editor.fontSize": 14,
		"editor.fontLigatures": true,
		"html.format.wrapAttributes": "force",
		// "editor.formatOnSave": true,
		"emmet.includeLanguages": {
			"razor": "html"
		},
		"files.associations": {
			"*.cshtml": "html"
		},
		//vim
		//"editor.lineNumbers": "relative",
		"vim.easymotion": true,
		"vim.incsearch": true,
		"vim.useSystemClipboard": true,
		"vim.useCtrlKeys": true,
		"vim.hlsearch": true,
		"vim.leader": ",",
		"vim.insertModeKeyBindings": [
		{
			"before": [
				"<leader>",
			"<leader>"
			],
			"after": [
				"<Esc>"
			]
		}
		],
		"vim.visualModeKeyBindingsNonRecursive": [
		{
			"before": [
				";",
			"h"
			],
			"after": [
				//vmap <silent> ;h :s?^\(\s*\)+ '\([^']\+\)',*\s*$?\1\2?g<CR>
				":",
			"s",
			"?",
			"^",
			"\\",
			"(",
			"\\",
			"s",
			"*",
			"\\",
			")",
			"+",
			"'",
			"\\",
			"(",
			"[",
			"^",
			"'",
			"]",
			"\\",
			"+",
			"\\",
			")",
			"'",
			",",
			"*",
			"\\",
			"s",
			"*",
			"$",
			"?",
			"\\",
			"1",
			"\\",
			"2",
			"?",
			"g",

			"<CR>"

				]
		},
		{
			"before": [
				";",
			"q"
			],
			"after": [
				//vmap <silent> ;q :s?^\(\s*\)\(.*\)\s*$? \1 + '\2'?<CR>
				":",
			"s",
			"?",
			"^",
			"\\",
			"(",
			"\\",
			"s",
			"*",
			"\\",
			")",
			"\\",
			"(",
			".",
			"*",
			"\\",
			")",
			"\\",
			"s",
			"*",
			"$",
			"?",
			"\\",
			"1",
			"+",
			"'",
			"\\",
			"2",
			"'",
			"?",
			"<CR>"

				]
		},
		{
			"before": [
				"<leader>",
			"<leader>"
			],
			"after": [
				"<Esc>"
			]
		},
		{
			"before": [
				"v"
			],
			"commands": [
				"editor.action.smartSelect.expand"
			]
		},
		{
			"before": [
				"%"
			],
			"commands": [
				"extension.matchitJumpItems"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"x"
			],
			"commands": [
				"editor.action.smartSelect.expand"
			]
		},
		{
			"before": [
				"<leader>",
			"z",
			"z"
			],
			"commands": [
				"editor.action.smartSelect.shrink"
			]
		},
		{
			"before": [
				"<leader>",
			"c",
			"i"
			],
			"commands": [
				"editor.action.commentLine"
			]
		},
		{
			"before": [
				"<leader",
			"a",
			"a"
			],
			"commands": [
				"editor.action.clipboardCopyAction"
			]
		},
		{
			"before": [
				"<leader>",
			"q",
			"q"
			],
			"commands": [
				"workbench.action.findInFiles"
			]
		},
		{
			"before": [
				"<leader>",
			"s",
			"s"
			],
			"commands": [
				"actions.find"
			]
		}
		],
		"vim.normalModeKeyBindingsNonRecursive": [
		{
			"before": [
				"<leader>",
			"<leader>"
			],
			"after": [
				"<Esc>"
			]
		},
		{
			"before": [
				"<leader>",
			"r",
			"v"
			],
			"commands": [
				"editor.action.rename"
			]
		},
		{
			"before": [
				"<leader>",
			"q",
			"q"
			],
			"commands": [
				"workbench.action.findInFiles"
			]
		},
		{
			"before": [
				"<leader>",
			"f",
			"p"
			],
			"commands": [
				"workbench.action.files.copyPathOfActiveFile"
			]
		},
		{
			"before": [
				"<leader>",
			"f",
			"n"
			],
			"commands": [
				"copyRelativeFilePath"
			]
		},
		{
			"before": [
				"<leader>",
			"t",
			"p"
			],
			"commands": [
				"workbench.action.togglePanel"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"m"
			],
			"commands": [
				"workbench.action.showCommands"
			]
		},
		{
			"before": [
				"<leader>",
			"c",
			"i"
			],
			"commands": [
				"editor.action.commentLine"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"x"
			],
			"commands": [
				"editor.action.smartSelect.expand"
			]
		},
		{
			"before": [
				"<leader>",
			"z",
			"z"
			],
			"commands": [
				"editor.action.smartSelect.shrink"
			]
		},
		{
			"before": [
				"<leader>",
			"t",
			"a"
			],
			"commands": [
				"workbench.action.toggleActivityBarVisibility"
			]
		},
		{
			"before": [
				"<leader>",
			"t",
			"b"
			],
			"commands": [
				"workbench.action.toggleSidebarVisibility"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"s"
			],
			"commands": [
				"workbench.action.files.save"
			]
		},
		{
			"before": [
				"<leader>",
			"s",
			"s"
			],
			"commands": [
				"actions.find"
			]
		},
		{
			"before": [
				"%"
			],
			"commands": [
				"extension.matchitJumpItems"
			]
		},
		{
			"before": [
				"<leader>",
			"s",
			"i"
			],
			"commands": [
				"extension.matchitSelectItems"
			]
		},
		{
			"before": [
				"<leader>",
			"d",
			"i"
			],
			"commands": [
				"extension.matchitDeleteItems"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"f"
			],
			"commands": [
				"workbench.action.files.openFile"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"k"
			],
			"commands": [
				"workbench.action.closeActiveEditor"
			]
		},
		{
			"before": [
				"<leader>",
			"r",
			"r"
			],
			"commands": [
				"workbench.action.openRecent"
			]
		},
		{
			"before": [
				"<leader>",
			"k",
			"k"
			],
			"commands": [
				"workbench.action.quickOpen"
			]
		},
		{
			"before": [
				"<leader>",
			"i",
			"i"
			],
			"commands": [
				"workbench.action.gotoSymbol"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"1"
			],
			"commands": [
				"workbench.action.editorLayoutSingle"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"3"
			],
			"commands": [
				"workbench.action.splitEditorRight"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"2"
			],
			"commands": [
				"workbench.action.splitEditorDown"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"4"
			],
			"commands": [
				"workbench.action.editorLayoutTwoByTwoGrid"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"0"
			],
			"commands": [
				"workbench.action.closeGroup"
			]
		},
		{
			"before": [
				"<leader>",
			"x",
			"z"
			],
			"commands": [
				"workbench.action.terminal.focus"
			]
		},
		{
			"before": [
				"<leader>",
			"f",
			"f"
			],
			"commands": [
				"workbench.action.toggleZenMode"
			]
		},
		{
			"before": [
				"<leader>",
			"w",
			"h"
			],
			"after": [
				"<C-w>",
			"h"
			]
		},
		{
			"before": [
				"<leader>",
			"w",
			"j"
			],
			"after": [
				"<C-w>",
			"j"
			]
		},
		{
			"before": [
				"<leader>",
			"w",
			"k"
			],
			"after": [
				"<C-w>",
			"k"
			]
		},
		{
			"before": [
				"<leader>",
			"w",
			"l"
			],
			"after": [
				"<C-w>",
			"l"
			]
		},
		{
			"before": [
				"<leader>",
			"w",
			"q"
			],
			"after": [
				":wq"
			],
		}
		],
		"vim.handleKeys": {
			// "<C-a>": false,
			"<C-f>": false
		},
		"vim.enableNeovim": true,
		"vim.neovimPath": "",
		"[html]": {
			"editor.defaultFormatter": "HookyQR.beautify"
		},
		"window.zoomLevel": 0,
		"workbench.activityBar.visible": true,
		"[javascript]": {
			"editor.defaultFormatter": "HookyQR.beautify"
		},
}
```


### 後記 emacs
看 emacs 大神有些操作跟 keybinding 自己也有點混用 emacs 快捷，可以安裝以下幾個 emacs 生態系的 extension
[emacs keybinding](https://marketplace.visualstudio.com/items?itemName=tuttieee.emacs-mcx&ssr=false#overview)
半殘的[org mode](https://vscode-org-mode.github.io/vscode-org-mode/)
[Code Ace Jumper](https://marketplace.visualstudio.com/items?itemName=lucax88x.codeacejumper)

### emment 更新
太久沒用 vscode 寫前端發現 emmet 的 wrap 功能不曉得哪個版本開始被合併了現在只剩下 `wrapWithAbbreviation` ˊ這個設定
要包分開多個標籤可以這樣用 `alt + w` => `div*`就搞定了
單個還是老樣子 `alt + w` => `div`
```
{
	"key": "alt+w",
		"command": "editor.emmet.action.wrapWithAbbreviation"
},
```


### colab 整合 vscode
基本上[參考這老外](https://medium.com/swlh/connecting-local-vscode-to-google-colabs-gpu-runtime-bceda3d6cf64)
先依照老外說的[下載 cloudflare](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/install-and-setup/installation)
然後看要放在哪我是直接放在這個路徑 `c:\cloudflare\cloudflare.exe`
開啟 vscode 安裝 `Remote SSH` => `Remote SSH Open SSH Configuration File` 貼以下這段
```
# Read more about SSH config files: https://linux.die.net/man/5/ssh_config
Host *.trycloudflare.com
    HostName %h
    User root
    Port 22
ProxyCommand C:\cloudflared\cloudflared.exe access ssh --hostname %h
```
接著開啟 colab 在 jupyter 貼上這段
```
# Install colab_ssh on google colab
!pip install colab_ssh --upgrade

from colab_ssh import launch_ssh_cloudflared, init_git_cloudflared
launch_ssh_cloudflared(password="helloworld")

# Optional: if you want to clone a github repository
# init_git_cloudflared(githubRepositoryUrl)
```
在 vscode 呼叫 Remote SSH Connect To Host 貼上生出來的片段大概長這樣 , 然後 vscode 會要你輸入密碼 , 之前設定 `helloworld`
```
xxxx-xxxx-oooo-oooo.trycloudflare.com
```
連線成功後可以選 `Open Folder` 直接複製 colab 上面的資料夾路徑 , 然後貼在 vscode 上面即可去遠端資料夾


### colab 整合 vscode (印度仔版)
[主要參考這個印度仔](https://www.youtube.com/watch?v=ah_7J0w1Wac)
直接在 colab 貼上以下片段
```
!pip install -q colabcode
from colabcode import ColabCode
ColabCode(port=10000, password="helloworld")
```
設定完後印度仔寫得程式會跳一個 ngork 的連結 , 點選連結會跳一個輸入密碼的視窗 , 打完後 chrome 跳出 vscode 視窗 , 注意非自己 local 的 vscode 就好了
