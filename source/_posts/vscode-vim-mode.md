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

## 教學及資源
### 還不錯的教學
- [五倍紅寶石](https://www.youtube.com/watch?v=mPVwS8gjDVI&amp;list=PLBd8JGCAcUAH56L2CYF7SmWJYKwHQYUDI&amp;index=1)
- [Victor Lee](https://www.youtube.com/watch?v=rzpoMlss7Kk&amp;list=PLL7OBcW31PnJTOFMzvA14-Pq9cfuu9gGB)
- [boost your coding fu with vscode and vim](https://www.barbarianmeetscoding.com/boost-your-coding-fu-with-vscode-and-vim/table-of-contents)
- [上面那本書作者的 youtube Jaime González García](https://www.youtube.com/c/Vintharas/videos)
- [neovim 對照功能](https://www.youtube.com/watch?v=g4dXZ0RQWdw&feature=youtu.be)

### 一些實用小抄
* [vim 小抄]( https://vim.rtorr.com/lang/zh_tw)
* [vscode vim 小抄](https://github.com/VSCodeVim/Vim/blob/master/ROADMAP.md)
* [大陸人寫的功能介紹](https://chengjingchao.com/2020/06/13/VS-Code-%E4%B8%8E-Vim/)
* [vim ninja 小抄](http://blog.vanutsteen.nl/secrets-of-the-vim-ninja/)

## 安裝及設定
### 安裝
首先在 vscode 搜尋 [`VSCodeVim`](https://github.com/VSCodeVim/Vim) , 然後無腦安裝就搞定了
接著開始 config 在 `win + r` 輸入
```
%APPDATA%/Code/User
```
在 `setting.json` 加上 vim 的 config 內容 , 建議 `easymotion` 要打開 , easymotion介紹 [這篇](http://wklken.me/posts/2015/06/07/vim-plugin-easymotion.html)
有安裝 neovim 需要開啟整合的話可以打開最後面的設定 , 初學的話就不用理這個選項
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

### intellisense 移動設定
在 `keybindings.json` 加 上config 內容 開 `intellisense` 時也使用鍵盤 `alt+j` `alt+k` 上下移動 , 可以參考[這篇](https://stackoverflow.com/questions/18153541/scrolling-through-visual-studio-intellisense-list-without-mouse-or-keyboard-arro)
注意這邊要照著老外 `Rocco Ruscitti` 才正確!

後來發現預設的 `ctrl+n ctrl+p` 也可以完成 `intellisense` 的上下移動 menu 也可以
還有一種特殊的 `intellisense` 就是補全已經輸入過的片段 `ctrl+x ctrl+l` 算是補整句用

如果想要客製化 menu 移動可以參考這篇 [解決辦法](https://stackoverflow.com/questions/56121333/how-to-remap-down-quick-open-menu-in-vscode) 感恩老外!
`keybindings.json`
```
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
```

### 產生常用假資料
不要臉推薦下自己寫的 extension [假的](https://marketplace.visualstudio.com/items?itemName=weber87na.tw-fake-data-gen) [github在此](https://github.com/weber87na/tw-fake-data-gen)
難得有放圖 XD
![假的](https://raw.githubusercontent.com/weber87na/tw-fake-data-gen/main/images/fake128x128.jpg)

這個問題源自於常常開發時需要生出假資料 , 客戶或是 user 打死都不給你 , 這類咚咚多半都是老外有搞 , 但是你放英文就會開始被打搶 , 所以特別研究看看有無方法直接在 vscode 內搞出來
目前支援以下命令:

[操作法](https://raw.githubusercontent.com/weber87na/tw-fake-data-gen/d9a2e0bb76c0cc7960dc5e8efb784cd0f19da053/images/features.gif)

* `fcname` 產生中文名字
* `fename` 產生老外名字
* `fphone` 產生手機號碼
* `ftwid` 產生身分證字號
* `ftwpoint` 產生隨機台灣範圍的經緯度格式 lon lat
* `ftwdate` 產生隨機日期(民國年)
* `fendate` 產生隨機日期(西元年)
* `fcolor` 產生隨機 html 色碼
* `fage` 產生隨機年齡
* `femail` 產生隨機 email

### 包裹標籤
另外我有設定 `emmet` 包裹功能可以參考 [老外設定](https://stackoverflow.com/questions/40155875/how-to-do-tag-wrapping-in-vs-code)
特別要注意的是使用 Individual 模式時選擇器需要這樣寫 li* 才會分開包裹 (注意新版已經改成只剩下 `wrapWithAbbreviation` 命令)
若使用 [vscode  vim surround](https://github.com/VSCodeVim/Vim#vim-surround) 則是在 visual mode 底下輸入大寫 S 以後輸入 <標籤> 這樣就可以包起來了
`keybindings.json`
```
[
    {
        "key": "alt+w",
        "command": "editor.emmet.action.wrapWithAbbreviation"
    },
	{
		"key": "alt+i",
		"command": "editor.emmet.action.wrapIndividualLinesWithAbbreviation"
	},
]
```

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
### 自訂 emmet snippet
一直以來都有個很火大的需求 , 就是每次用 `emmet` `!` 產生 html 時都會送你英文 `lang="en"`
這時候你打開 chrome 就會出現翻譯要你點選 , 每次都彈這個視窗很賭爛 , 所以才想辦法寫這篇
另外 Safari 9.0 還有個很北爛的 bug , 需要在加上 meta `shrink-to-fit=no`
像下面這樣才會正常 ,  可以參考[這篇討論](https://stackoverflow.com/questions/33767533/what-does-the-shrink-to-fit-viewport-meta-attribute-do)
```
<meta name="viewport" content="width=device-width, initial-scale=1.0, shrink-to-fit=no">
```

根據[官方說明](https://code.visualstudio.com/docs/editor/emmet#_using-custom-emmet-snippets)
要設定需要在你的 `settings.json` 設定 `emmet.extensionsPath` 這個區塊 , 然後建立資料夾
```
    "emmet.extensionsPath": [
        "C:\\Users\\YourName\\mysnippet"
    ]
```
然後新增 `snippets.json` 這個檔案 , 注意結尾有 `s` 很容易忘了加 , 然後下面加入自己爽的內容 , 預設可以參考這個[官方檔案](https://github.com/emmetio/snippets/blob/master/html.json)
另外自己定義的時候他吃 emmet 語法 , 所以單純想輸出文字的話需要用花括號包起來 , 如果你是謎片業者就可以定義常用的迷片連結 ? 可以看我下面的例子
```
{
  "html": {
    "snippets": {
      "lasai": "{喇賽}",
	  "lilasai": "{你喇賽}",
	  "liladisai": "{你喇低賽}",
	  "myblog" : "{https://weber87na.github.io/}"
	  "meta:vp": "meta[name=viewport content='width=${1:device-width}, initial-scale=${2:1.0}, shrink-to-fit=no']",
	  "doctw": "html[lang=zh-Hant]>(head>meta[charset=${charset}]+meta:vp+title{${1:Document}})+body",
	  "!tw": "!!!+doctw"
    }
  }
}
```
最後特別注意 , 這種設定檔的 json 如果是最後一個 item 不能有 comma 逗號 `,` 會跳 error 爽得你不要不要的 , 設定完後要重啟 vscode 才會生效
其他產生 snippet 就暫時沒太多研究 , 只知道這個[工具](https://snippet-generator.app/?description=&tabtrigger=&snippet=&mode=vscode)可以幫你

### Hippie Completion
這個 [simple-autocomplete](https://marketplace.visualstudio.com/items?itemName=mksafi.simple-autocomplete) 外掛是無意中發現的
這個在 `webstorm` 稱為 [嬉皮補全](https://www.jetbrains.com/help/webstorm/auto-completing-code.html#hippie_completion)
不過他這個功能的實作細節是包含某個字元就判定補全 , 並非用字首來計算 , 所以還是有些細微差異

因為之前都沒在 `setting.json` 設定過 bind `alt key` 所以不太曉得怎麼用 , 搞了半天好像不 work
後來查了看看老外的半殘[解法](https://stackoverflow.com/questions/50724308/is-it-possible-to-map-alts-to-escape-in-vscode-vim)
最後還是要在 `keybindings.json` 設定 , 貼上以下內容即可搞定
```
[
    {
        "key": "alt+/",
        "command": "simpleAutocomplete.next",
        "when": "editorTextFocus && vim.active && vim.mode == 'Insert'"
    }
]
```

### 設定 terminal focus
最近偶爾會用 terminal 功能可以增加以下片段進行切換動作
```
    //https://stackoverflow.com/questions/42796887/switch-focus-between-editor-and-integrated-terminal-in-visual-studio-code
    // Toggle between terminal and editor focus
    { "key": "ctrl+`", "command": "workbench.action.terminal.focus"},
    { "key": "ctrl+`", "command": "workbench.action.focusActiveEditorGroup", "when": "terminalFocus"}
```

### css navigation
vscode 在 css 裡面使用 go to definition 功能好用外掛 [CSS Navigation](https://marketplace.visualstudio.com/items?itemName=pucelle.vscode-css-navigation&ssr=false#overview)
之前一直無法直接使用 gd 在 css 裡面跳，安裝 css peek 也無解，還好發現這套，解決困擾好幾個月的問題，感動
`ctrl + shift + p` 開啟 settings.json 裡面設定讓目前文件也啟用 go to definition 功能
```
"CSNavigation.alsoSearchDefinitionsInStyleTag" : true
```
使用 `gd` 可以直接呼叫 go to definition 的 class or ID 連 Html Tag 也是可以直接跳
使用 `ctrl + o` 或是 `ctrl + i`  可以跳回來

後來發現撰寫 javascript 時需要加入 jsconfig.json 才可以使用 gd 功能[參考官方文件](https://code.visualstudio.com/docs/nodejs/working-with-javascript#_typings-and-automatic-type-acquisition)
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



### 特殊功能筆記
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

交換上下行 `ddp`
交換前後字 `xp`

解決預設 % 不能找到尖括號的問題 `set mps+=<:>` 這個在 vim 才會發生 , vscode 好像不會

### 刪除 function 內的變數
刪除 function 內的變數，自從學會 vim 基本操作以後就很少用 `t` or `T` 這種操作，看到高手用在刪除參數筆記一下
```
#開頭
f(lct,
#結尾
f)dF,
```

### 快速在 html 標籤移動
之前常常用 % 來對 tag 進行起始/結尾切換，但是寫 html 完全沒法這樣做，後來發現原來只要 `vat` 接著用 `o` 就可以來回切換。
不然就要安裝 emacs 大師的 [matchit](https://marketplace.visualstudio.com/items?itemName=redguardtoo.matchit) , 現在連 java , c++ 都 support

### 設定 html 屬性換行
配合 teamwork 開發 angular 導致 html attribute 又臭又長尋求解法，每個 team member 的 html 空格數也不太一樣所幸找以到下解法
```
"editor.detectIndentation": false,
// The number of spaces a tab is equal to. This setting is overridden based on the file contents when `editor.detectIndentation` is on.
"editor.tabSize": 4,
// Config the editor that making the "space" instead of "tab"
"editor.insertSpaces": true,
"html.format.wrapAttributes": "force",
```

### 正則表達式搜尋替換
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



### 設定鍵盤延遲時間
以前玩遊戲的時候會希望腳色可以瞬間定住開槍，fps 遊戲差個 0.x 毫秒就差很多 , 在 windows 底下可以這樣設定
`win + r` => `control panel` => `keyboard` => `重複延遲設定最短` => `重複速度設定最快`



### 把 html 轉為 js string
工作上遇到轉換的問題特別筆記一下
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






### vscode 不傷眼深色佈景及 terminal 設定
透明度的解決方案 [參考自](https://ourcodeworld.com/articles/read/669/how-to-make-the-visual-studio-code-window-transparent-in-windows) 共有兩套 , 我自己是用 [這套](https://marketplace.visualstudio.com/items?itemName=skacekachna.win-opacity)
由於會需要用到透明度代表會在深色底下工作 , 這裡安裝德古拉吸血鬼樣式 , 實測起來透明度 240 比較舒服

額外會用 k9s 管理工具所以設定樣式為 one_dark 效果比較好 , 可以看這邊的 [樣式列表](https://github.com/derailed/k9s/tree/master/skins)
`terminal` 習慣用 `emacs` 模式 , 所以 vscode 預設的 `ctrl + p` 會影響到操作 `terminal` 的體驗感 , 參考 [老外的解法](https://github.com/microsoft/vscode/issues/35722)
在開啟 `terminal` 時停用 `ctrl + p` , 最後就是從 `terminal` 切換回 editor , `ctrl +` `` ` ``  , 詳細可以參考 [此篇](https://stackoverflow.com/questions/42796887/switch-focus-between-editor-and-integrated-terminal-in-visual-studio-code)
最後就是關掉 `ctrl + k` [參考自](https://stackoverflow.com/questions/50569100/vscode-how-to-make-ctrlk-kill-till-the-end-of-line)
後續操作上又遇到很奇怪的問題 , 會一直自動的 ForwardPorts , 參考[老外解法](https://github.com/microsoft/vscode/issues/109819)

`settings.json`
```
"workbench.colorTheme": "Dracula",
"winopacity.opacity": 240,
"redhat.telemetry.enabled": true,
"terminal.integrated.allowChords": false,
"terminal.integrated.commandsToSkipShell":[
	"-workbench.action.quickOpen"
],
"remote.autoForwardPorts": false
```

還有幾個常用的功能或是尚需排除的問題點
* 將 panel 最大化
* terminal 有 focus 關掉 find 的功能
* zen mode , 因為是開 termial 比較不想要其他視窗干擾可以直接 `ctrl + shift + p` 搜尋 zen mode 來開關

`keybindings.json`
```
{
	"key": "ctrl+alt+m",
	"command": "workbench.action.toggleMaximizedPanel"
},
{
	"key": "ctrl+f", "command": "",
	"when": "terminalFocus"
}
```

總結下我在 vscode 開發 k8s 有用到的 extension
[kubernetes](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
[docker](https://marketplace.visualstudio.com/items?itemName=ms-azuretools.vscode-docker)
[Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
[Remote - SSH](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh)
[Remote - SSH: Editing Configuration Files](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit)
[Yaml](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)

深色不傷眼的 extension
[Windows opacity](https://marketplace.visualstudio.com/items?itemName=skacekachna.win-opacity)
[dracula](https://marketplace.visualstudio.com/items?itemName=dracula-theme.theme-dracula)

### 後記 emacs
看 emacs 大神有些操作跟 keybinding 導致自己也有點混用 emacs 快捷，可以安裝以下幾個 emacs 生態系的 extension
[emacs keybinding](https://marketplace.visualstudio.com/items?itemName=tuttieee.emacs-mcx&ssr=false#overview)
半殘的 [org mode](https://vscode-org-mode.github.io/vscode-org-mode/)
[Code Ace Jumper](https://marketplace.visualstudio.com/items?itemName=lucax88x.codeacejumper)

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

### 開啟 k8s 自動提示
[直接安裝 kubernetes 這個 extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools)
他會連同 redhat 的 yaml extension 一起安裝
老樣子在 setting.json 內加入以下片段即可
```
	"yaml.schemas": {
	  "Kubernetes": "*.yaml"
	}
```

### 參數換行技巧
這個方法 visual studio 不曉得啥時就可以自動 wrap 參數 , 可是 vscode 好像不行 , 所以特別筆記一下
假設 function 的參數很多 , 有時候會希望讓參數換行 , 像是下面這個片段
```
public Author(Guid id , [NotNull] string name , DateTime birthDate , [CanBeNull] string shortBio = null)
{
	//喇賽懶得寫
}
```
這時正常情況會像智障一樣慢慢敲換行 , 可是有這樣一個操作技巧
開啟 `replace` 的功能然後選住 `Author` 這一行 , 開啟 `regex` 選項及 `Match Case`
接著輸入要替換的內容 search term `,` 及 replacement term 如下面這樣 , 這個方法 notepad++ 也適用
特別注意如果是 vscode 的 newline 要用 `\n` , `\r\n` 好像沒用
```
,\n\t\t\t
```
`visual studio` or `notepad++`
```
,\r\n\t\t\t
```

最後就可以得到這樣的效果
```
internal Author(Guid id ,
	 [NotNull] string name ,
	 DateTime birthDate ,
	 [CanBeNull] string shortBio = null)
	: base( id )
{
	//喇賽懶得寫
}

```

另外也可以先用 vim 錄製 `f,a<CR><Esc>` 這樣的動作 , 用 @q 來重播達到一樣的效果
```
"q   f,a<CR><Esc>
```
## 設定檔
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
我這份 config 是參考自 emacs 大神改造而成的可以看看他的原始 [config](https://github.com/redguardtoo/vscode-setup/blob/master/settings.json)
這裡還有老外一些[小技巧](https://gist.github.com/benjamincharity/9349506) 值得參考看看
[後來發現還滿特別的 config 跟 extension](https://zhuanlan.zhihu.com/p/73561114)
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
		},
		{
			"before": [
			"z",
			";"
			],
			"after": [
                "<Esc>", "$" , "a" , ";"
			],
		},
		{
			"before": [
			"z",
			"h"
			],
			"after": [
                "<Esc>", "^" , "i"
			],
		} ,
		{
			"before": [
			"z",
			"l"
			],
			"after": [
                "<Esc>" , "$" , "a"
			],
		} ,
		{
			"before": [
			"z",
			","
			],
			"after": [
                "<Esc>" , "$" , "a" , ","
			],
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
		},
		{
			"before": [
			"z",
			"h"
			],
			"after": [
				"^"
			],
		},
		{
			"before": [
			"z",
			"l"
			],
			"after": [
				"$"
			],
		},
		{
			"before": [
			"z",
			";"
			],
			"after": [
				"$" , "a" , ";" , "<Esc>"
			],
		} ,
		{
			"before": [
			"z",
			","
			],
			"after": [
                "$" , "a" , "," , "<Esc>" ,
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
		"yaml.schemas":{
            "Kubernetes" : "*.yaml"
        },
		//德古拉樣式
        //"workbench.colorTheme": "Dracula",

		//透明度
        //"winopacity.opacity": 240,
        "redhat.telemetry.enabled": true,
        "terminal.integrated.allowChords": false,
		"terminal.integrated.commandsToSkipShell":[
			"-workbench.action.quickOpen",
		],
		"remote.autoForwardPorts": false
}
```

