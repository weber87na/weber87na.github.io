---
title: 在 azure data studio 使用 vim
date: 2021-01-14 19:09:35
tags:
- vim
- azure data studio
---
&nbsp;
<!-- more -->

因為更新了新版的 SSMS 很雞婆的被安裝 azure data studio，心中感到 OXOX
打開來發現跟 vscode 很像，剛好 ssms 上面也沒 vim mode，vscode 對這些資料庫支援也是斷手斷腳就來玩看看，
整體用起來還算不錯，圖表功能超強大，以前跟本沒工具可以拉這麼酷的圖表，另外還支援 postgresql 實在讚，不然 pgadmin 被改成 web 介面以後就難用到炸掉
開腦洞安裝 [VSCodeVim](https://github.com/VSCodeVim/Vim/releases) 下載並且在
`Extensions` `點點點` => `Install From VSIX` => `ctrl shift + p` 開啟之前 vscode 上的 config `setting.json` 跟 `keybinding.json` 並且把需要的部分進行微調就搞定了
後來發現沒有相對行號還是挺痛苦的 [Relative Line Numbers](https://marketplace.visualstudio.com/items?itemName=extr0py.vscode-relative-line-numbers)
