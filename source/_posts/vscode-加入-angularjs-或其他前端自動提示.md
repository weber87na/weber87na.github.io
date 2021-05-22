---
title: vscode 加入 angularjs 或其他前端自動提示
date: 2020-11-23 20:31:24
tags: vscode
---
&nbsp;
<!-- more -->
很久沒搞前端，遇到專案要用舊版 angularjs 1.x，印象中以前要開 intellisense 要裝一狗票鬼東西，傻傻的找了幾個參考結果都棄用了，前端還變化真快阿。
一開始裝 node 就直接失敗，後來發現有 [nvm for windows](https://github.com/coreybutler/nvm-windows)可以直接在 windows 上面切換，不過 win 7 好像只支援到 node 12，要特別留意一下版本。
現在只需要無腦一行就可以智能提示，看需要什麼 lib 的智能提示替換掉即可
```
npm install --save @types/angularjs
```
接著新增 app.js 在行首設定以下參照即可搞定
```
/// <reference path="node_modules/@types/angularjs/index.d.ts"  />
```
