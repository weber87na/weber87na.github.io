---
title: 解決 vim 在 wsl 上無法複製的問題
date: 2020-08-26 16:54:23
tags:
- vim
- wsl
---
&nbsp;
<!-- more -->
參考文章
https://superuser.com/questions/1291425/windows-subsystem-linux-make-vim-use-the-clipboard

用了 wsl 一陣子突然發現到 vim 在上面無法複製文字，還好佛心老外已經搞定這個問題，只需要加入以下這段到 .vimrc 即可
```
" WSL yank support
let s:clip = '/mnt/c/Windows/System32/clip.exe'  " change this path according to your mount point
if executable(s:clip)
    augroup WSLYank
        autocmd!
        autocmd TextYankPost * if v:event.operator ==# 'y' | call system(s:clip, @0) | endif
    augroup END
endif
```
