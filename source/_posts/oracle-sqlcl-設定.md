---
title: oracle sqlcl 設定
date: 2024-09-24 11:49:15
tags: oracle
---
&nbsp;
<!-- more -->

先到官網下載然後解壓即可

```
cd ~
wget https://download.oracle.com/otn_software/java/sqldeveloper/sqlcl-24.2.0.180.1721.zip
unzip sqlcl-24.2.0.180.1721.zip
```

接著設定 alias

```
vim ~/.bash_aliases
alias sql="${HOME}/sqlcl/bin/sql"
source ~/.bash_aliases
```

測試登入
```
sql testuser1/testuser1@localhost:1521
sql sys@localhost:1521 as sysdba
```

登入想要直接開 vi or emacs 模式或其他設定可以參考[這篇](https://database.guide/how-to-create-a-login-sql-file-for-sqlcl/) 或是 [這篇](https://marc-deveaux.medium.com/sqlcl-cheatsheet-8ca83de1481e)

先建一個 `~/sqlcl/bin/login.sql`

```
set sqlformat ansiconsole

set highlighting on
set highlighting keyword foreground blue
set highlighting identifier foreground magenta
set highlighting string foreground green
set highlighting number foreground cyan
set highlighting comment foreground yellow

set statusbar add timing
set statusbar on
set editor emacs 

set serveroutput on
```

然後設定環境變數 `SQLPATH` 指向 sqlcl 安裝位置

```
vim ~/.bashrc
export SQLPATH=${HOME}/sqlcl/bin
source ~/.bashrc
```
