---
title: sqlplus clear screen
date: 2024-09-18 11:14:33
tags: oracle
---
&nbsp;
<!-- more -->

工作上遇到的問題, 因為在 linux 上面直接用 sqlplus 比較快
可是發現當慣性按下 ctrl + l 是清不了畫面低
然後用 ctrl + a ctrl + k AK 也沒辦法把那行送回老家, 會出現以下這樣
以前也有用過類似的軟體遇到這種狀況, 可能是 psql 有點忘了

```
SQL> ^L
SQL> ^A^K
```

後來無意中找到 [這篇](https://topic.alibabacloud.com/tc/a/solve-the-problem-that-the-back-key-display-h-the-upper-and-lower-keys-are-invalid-and-the-ctrll-cannot-clear-the-screen-under_1_46_30121389.html) 或 [這篇](https://www.modb.pro/db/73454)
他透過安裝 [rlwrap](https://github.com/hanslub42/rlwrap) 來解決這個困擾許久的問題, 發明這個的人長得超古椎的 lol
我自己用 ubuntu 20 直接安裝即可

```
sudo apt install rlwrap
```

然後寫入 alias 到 bash_profile 並且用 source 讓他生效即可
我自己的 wsl 用 bash_profile 不曉得為啥高亮會跑掉
後來放在 .bashrc 跟 .bash_aliases 就沒事, 整個靈異 XD

```
vim ~/.bash_profile
alias sqlplus='rlwrap sqlplus'
# alias rman='rlwrap rman'
# alias lsnrctl='rlwrap lsnrctl'
# alias asmcmd='rlwrap asmcmd'
# alias adrci='rlwrap adrci'

source ~/.bash_profile
```
