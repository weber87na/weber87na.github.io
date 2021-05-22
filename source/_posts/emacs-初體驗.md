---
title: emacs 初體驗
date: 2020-12-30 03:57:32
tags: emacs
---
&nbsp;
<!-- more -->

## 前言
由於在 win7 的 git for windows 上使用 vim 斷手斷腳，決定來用看看 emacs，反正沒玩過
[下載](https://www.gnu.org/software/emacs/download.html#nonfree)
還不錯的 emacs [教學](https://www.youtube.com/watch?v=0hpVuoyO8_o)
爬文發現有所謂的 .emacs.d 資料夾，算是 config emacs 用
就跟著大神的 [config](https://github.com/redguardtoo/emacs.d) 另外看 [spacemacs](https://www.spacemacs.org/) 好像也很多人用
將下載後的 .emacs.d 資料夾放到 %userprofile% 底下
設定環境變數 HOME 路徑跟 %userprofile% 一樣
接著 cd 到 `HOME/.emacs.d`
執行 `emacs/bin/runemacs` or `emacs/bin/emacs` or `emacs -nw` 可以無視窗開啟
比較特別是 emacs 多半用 ctrl (C) or alt (M) 來執行整個操作流，有些操作是 `ctrl + 某個按鍵 接著放開 ctrl 在按某個按鍵`
跟一直壓著 ctrl 連按是不太一樣的
列一些初學常用的按鍵方便自己記憶

## 常用熱鍵
教學文件 `ctrl + h t` or `M + x help-with-tutorial`
退出 `q` 
中斷命令 `ctrl + g`
退出 emacs `ctrl + x ctrl + c`
顯示行號 `ctrl + x ctrl + f`
搜尋 `ctrl + s`
開新檔案 `ctrl + x ctrl + f` or 新建檔案 `ctrl + x ctrl + f` 接著輸入檔案名稱
保存檔案 `ctrl + x ctrl + s`
類似 vim 的 visual mode `ctrl + space`
切換 buffer `ctrl + x b` or `ctrl + x ctrl + b`
下捲(真是變態) `ctrl + v`
上捲 `alt + v`
只留單一視窗 `ctrl + x 1`
切割水平視窗 `ctrl + x 2`
切割垂直視窗 `ctrl + x 3`
來回切視窗 `ctrl + x o`

## Org Mode
標註狀態 `ctrl + c ctrl + t`
