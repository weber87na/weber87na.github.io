---
title: vscode neovim 筆記
date: 2022-02-08 19:04:18
tags:
- vscode
- vim
---

![vim](https://raw.githubusercontent.com/weber87na/flowers/master/12.jpg)
&nbsp;
<!-- more -->

因為沒玩過 [VSCode Neovim](https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim) 這個 extension , 無聊看到想說來玩看看
可以參考這篇[介紹](https://galenwong.github.io/blog/2021-03-22-vscode-neovim-vs-vscodevim/)為啥麼要轉用 vscode neovim 的原因
功能介紹可以參考這個[老外影片](https://www.youtube.com/watch?v=g4dXZ0RQWdw)

### 安裝/更新 neovim
因為我之前有裝過 0.4.4 的 neovim 他最低版本要 0.5 以上 , 所以用 choco 更新下 , 好像都要用系統管理員才能 work , 我有安裝 gsudo 所以直接下
```
sudo choco upgrade neovim
```

如果發生問題直接 uninstall 看看
```
sudo choco uninstall neovim
```

真的不行就重新安裝 , 我 `2020/02/08` 安裝是 `0.6.1`
```
sudo choco install neovim
```

如果重新安裝有跳一堆 error 應該是之前的 plugin 也被砍了 , 所以執行 `:PlugInstall` 應該就 ok
真的不行就把 Plug 註解起來 , 驗證自己的 neovim 是否正常
```
Error detected while processing C:\Users\YourName\.vim\plugged\coc.nvim\plugin\coc.vim
```

### 基本設定
開啟 vscode-neovim 的齒輪進行設定 `@ext:asvetliakov.vscode-neovim`

如果用 choco 安裝的話路徑在這裡 `C:\tools\neovim\Neovim\bin`
設定這個選項 `Neovim Executable Paths:Win32`

接著設定 Neovim Init Vim Paths: Win32
`C:\Users\YourName\AppData\Local\nvim`

嫌 GUI 麻煩就直接設定這樣
`settings.json`
```
"vscode-neovim.neovimExecutablePaths.win32": "C:\\tools\\neovim\\Neovim\\bin\\nvim.exe",
"vscode-neovim.logPath": "C:\\testlog",
"vscode-neovim.neovimInitVimPaths.win32": "C:\\Users\\YourName\\AppData\\Local\\nvim\\init.vim"
```

### 其他設定
如果要設定類似 NERDTree 功能要在 `settings` 加上這段 , 接著就可以用跟 NERDTree 類似的操作 , 可以參考這篇[說明](https://github.com/vscode-neovim/vscode-neovim#explorerlist-navigation)
```
"workbench.list.automaticKeyboardNavigation": false
```

這裡來測試看看外掛 `[vim-surround]`(https://github.com/tpope/vim-surround)
這也是最神奇的地方 , 在 neovim 上面的外掛還真的能動
設定完後好像要 reload vscode
`init.vim`
```
if exists('g:vscode')
    " VSCode extension
	call plug#begin('~/.vim/plugged')
		Plug 'tpope/vim-surround'
	call plug#end()	
else

endif
```

如果有出現類似這樣的訊息 , 應該是還沒安裝或是打錯字之類的 , 要先在 neovim 執行 `:PlugInstall` 像我下面這串就不小心打錯
```
VSCode-Neovim:

line    6:
E492: Not an editor command: ^I^IPlugin 'tpope/vim-surround'
```
