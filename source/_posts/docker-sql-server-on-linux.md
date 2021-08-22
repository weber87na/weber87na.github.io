---
title: docker sql server on linux
date: 2021-08-16 18:17:13
tags: docker
---

&nbsp;
<!-- more -->

### 安裝
今天無意中跑看看 [sql server 2019 on linux](https://hub.docker.com/_/microsoft-mssql-server), 一上來就陣亡炸一整坨 error
另外還有 `MSSQL_PID` 可選擇預設是 Developer
密碼也可以改自己想用的 , 我懶得改
```
docker pull mcr.microsoft.com/mssql/server
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=yourStrong(!)Password' -p 1433:1433 -d mcr.microsoft.com/mssql/server
docker container ls
```

原來是要 200 megabytes 記憶體
`
SQL Server 2019 will run as non-root by default.
This container is running as user mssql.
To learn more visit https://go.microsoft.com/fwlink/?linkid=2099216.
sqlservr: This program requires a machine with at least 2000 megabytes of memory.
/opt/mssql/bin/sqlservr: This program requires a machine with at least 2000 megabytes of memory.
`

先關 swap 看看記憶體 , 發現只有 default 1024
```
sudo swapoff -a
#把 swap 也註解調
sudo vim /etc/fstab
free -m
```

調整 vagrant hyperv 記憶體部分 [參考官網](https://www.vagrantup.com/docs/providers/hyperv/configuration#maxmemory)
```
  config.vm.provider :hyperv do |v|
    #v.maxmemory = 4096
    v.memory = 4096
    v.cpus = 2
  end
```

重新讀取 vagrant
```
sudo vagrant reload
```

bash 用 sqlcmd 預設密碼會有雷 , 所以用單引號把密碼包住
```
#-bash: !: event not found
docker exec -it df5 /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'yourStrong(!)Password'
```


### 安裝 mssql-cli
先拉 ubuntu 18.04 or 16.04 , 我用 20.4 裝不起來
另外這個 [project](https://github.com/dbcli) 還有其他的 cli-tool , 有空也可以玩看看 , 感覺這票人更多心力放在 pgcli or mycli 上
```
docker pull ubuntu:18.04
docker run -it ubuntu:18.04
```

參考官方[安裝](https://github.com/dbcli/mssql-cli/blob/master/doc/installation/linux.md#ubuntu-1604-Xenial)
```
apt-get update
apt-get install -y curl

#gnupg, gnupg2 and gnupg1 do not seem to be installed, but one of them is required for this operation
apt-get install -y gnupg
curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add -

#bash: apt-add-repository: command not found
apt install -y software-properties-common
apt-add-repository https://packages.microsoft.com/ubuntu/18.04/prod
apt-get install -y mssql-cli
apt-get install -f
```

最後 run 看看 , 雖然中文出現一堆靈異符號 , 對於 vim or emacs 熟的人操作起來還是滿爽的 , 可惜開發者好像就丟著爛了
```
mssql-cli -S 192.168.137.248 -d qq -U sa -P 'yourStrong(!)Password'
```


### 安裝 pgcli
起手先拉 [postgres](https://hub.docker.com/_/postgres) 的 docker 來測看看 , 內建有 bash & psql
```
docker pull postgres
docker run -e POSTGRES_PASSWORD=mysecretpassword -d postgres
docker container ls
docker exec -it 2fd /bin/bash
```

先到官網 clone 專案下來 , 編成 image , 跳進去裡面看看
```
git clone https://github.com/dbcli/pgcli.git
cd pgcli/
docker build -t pgcli .
docker run -it pgcli /bin/bash
```

首次用 [pgcli](https://github.com/dbcli/pgcli) 登入 , 預設資料庫都是 postgres , 多蓋一個 test 玩看看
```
pgcli postgres://postgres:mysecretpassword@172.17.0.4:5432/postgres
create database test;
exit
```

登入剛剛蓋的 test 資料庫 , 撈看看有無亂碼 , 發現正常 , 那為何 mssql 的版本會亂碼呢 ...
對一個 vim or emacs 的 user 還是滿友善的 , 用起來真的不錯 , 期待這個工具有更好的更新
```
pgcli postgres://postgres:mysecretpassword@172.17.0.4:5432/test

create table aaa ( aaa VARCHAR(255));
insert into aaa (aaa) values ('測試');
#+-------+
#| aaa   |
#|-------|
#| 測試  |
#+-------+
#SELECT 1
#Time: 0.005s
```
