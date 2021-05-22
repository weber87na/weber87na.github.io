---
title: SSMS & Visual Studio 提升 SQL 操作設定
date: 2020-11-21 10:10:58
tags: SSMS
---
&nbsp;
<!-- more -->

今年改用 vim extension 覺得有時候操作 SSMS 寫 SQL 不是很方便，研究看看有無方法提升使用體驗
發現 SSMS 原來可以自訂熱鍵在 工具 => 自訂 => 鍵盤 就可以調整設定， 老樣子把上下移動換成  alt + k , alt + j
編輯.上移一行
編輯.下移一行

開啟行號為 工具 => 選項 => 文字編輯器 => 所有語言 => 顯示行號

有時候預設的提示不是那麼健全可以考慮安裝[dbForge SQL Complete Express](https://www.devart.com/dbforge/sql/sqlcomplete/download.html)
這套安裝完會在 SSMS 跟 Visual Studio 都可以使用，不過用 Visual Studio 還可以用 vim 進行 SQL 編寫還是更方便一點，真希望 SSMS 也可以用 vim mode
後來發現這套跳的提示還是需要用上下鍵來移動，不太方便

後記發現這個自訂熱鍵的好用軟體[AutoHotKey](https://www.autohotkey.com/)
只要再加上這個[老外寫的 script](https://github.com/rcmdnk/vim_ahk)模擬 vim 就可以在 SSMS 上面也製造出類似 vim 操作的體驗
下載回來 lib 底下的 vim_ahk.ahk 這串 array 添加或是減少到列表裡面即可，注意 SSMS 的名稱是 ssms.exe
```
  SetDefaultActiveWindows(){
    DefaultList := ["ahk_exe Evernote.exe"  ; Evernote
                  , "ahk_exe explorer.exe"  ; Explorer
                  , "ahk_exe notepad.exe"   ; NotePad
                  , "OneNote"               ; OneNote at Windows 10
                  , "ahk_exe onenote.exe"   ; OneNote Desktop
                  , "ahk_exe POWERPNT.exe"  ; PowerPoint
                  , "ahk_exe TeraPad.exe"   ; TeraPad
                  , "ahk_exe texstudio.exe" ; TexStudio
                  , "ahk_exe texworks.exe"  ; TexWork
                  , "Write:"                ; Thunderbird, English
                  , "作成"                  ; Thunderbird, 日本語
                  , "ahk_exe Code.exe"      ; Visual Studio Code
                  , "ahk_exe WINWORD.exe"   ; Word
                  , "ahk_exe wordpad.exe"]  ; WordPad
```
完成後記得在 windows 隱藏圖示設定讓老外寫的 script 顯示起來，這樣才可以看到 vim 各種 mode 的切換
右鍵 => 工作列設定 => 選取要顯示在工作列的圖示 => AutoHotkey vim.ahk

跟 dbForge SQL Complete 搭配有個好處就是，當智能提示跳出來時只要切換到 Normal mode 即可使用 j , k 進行熟悉的上下移動，
之前還要自己設定 alt + j , alt + k 無法在 dbForge SQL Complete 跳出智能提示失效的問題也就都沒有了
dbForge SQL Complete 還有個很猛的優點就是直接在星號按下 tab 可以直接幫你展開全部欄位名稱，超實用
