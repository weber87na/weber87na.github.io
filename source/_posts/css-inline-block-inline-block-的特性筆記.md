---
title: 'css inline , block , inline-block 的特性筆記'
date: 2021-03-14 22:52:32
tags: css
---
&nbsp;
<!-- more -->

印象之前上 css 課的筆記寫在紙上 , 今天有空趁機電子化一下
沒用 markdown 寫過表格 , 之前小玩 emacs 時印象中有類似的 plugin 一時也找不到就先找個[線上工具將就](https://www.tablesgenerator.com/markdown_tables)

| prop                       | inline | block           | inline-block |
|----------------------------|--------|-----------------|--------------|
| width                      | x      | o               | o            |
| height                     | x      | o               | o            |
| margin-top margin-bottom   | x      | o               | o            |
| margin-left margin-right   | o      | o               | o            |
| padding-top padding-bottom | x      | o               | o            |
| padding-left padding-right | o      | o               | o            |
| direction                  | h      | v               | h            |
| space (css core 153)       | save   | n/a             | save         |
| horizontal tips            | n/a    | float flex grid | n/a          |
| text-align                 | o      | x               | o            |
| vertical-align             | o      | x               | o            |
