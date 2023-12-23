---
title: nexus 筆記
date: 2022-08-22 18:53:40
tags: nexus
---
&nbsp;
<!-- more -->

幫朋友看看怎麼在離線環境下建立套件管理的 server , 久聞 nexus 大名卻從未玩過 , 順手筆記下

### 安裝
礙於沒啥概念 , 找些現成乾貨來玩看看 , 我是在 wsl 上面 try , 主要參考以下幾個

* [官網](https://help.sonatype.com/repomanager3/product-information/download)
* [參考影片](https://www.youtube.com/watch?v=WHFbPGMQv20)
* [參考文章](https://epma.medium.com/install-sonatype-nexus-3-on-ubuntu-20-04-lts-562f8ba20b98)
* [這篇也不錯](https://faun.pub/remote-package-management-in-c-c959b6df3fe7)

```
#更新及安裝 jdk8
sudo apt update
sudo apt-get install openjdk-8-jdk

#下載及安裝
cd /opt
sudo wget https://download.sonatype.com/nexus/3/nexus-3.41.1-01-unix.tar.gz
sudo tar -xvf nexus-3.41.1-01-unix.tar.gz

#重新命名
sudo sudo mv nexus-3.41.1-01 nexus

#加入這個使用者
#密碼也用 nexus
sudo adduser nexus

#加入權限
sudo chown -R nexus:nexus /opt/nexus
sudo chown -R nexus:nexus /opt/sonatype-work
sudo vim /opt/nexus/bin/nexus.rc
run_as_user="nexus"

#加入到服務 如果是 wsl 這步可以跳過
#sudo vim /etc/systemd/system/nexus.service

#[Unit]
#Description=nexus service
#After=network.target
#
#[Service]
#Type=forking
#LimitNOFILE=65536
#User=nexus
#Group=nexus
#ExecStart=/opt/nexus/bin/nexus start
#ExecStop=/opt/nexus/bin/nexus stop
#User=nexus
#Restart=on-abort
#[Install]
#WantedBy=multi-user.target

#啟動服務
#sudo systemctl enable nexus
#sudo systemctl start nexus
#sudo systemctl status nexus


#wsl 走這步
cd /opt/nexus/bin
./nexus start

最後打開這個網址即可
#http://127.0.0.1:8081/
```


啟動後他的密碼在這裡 , 要點 `sign in` 登入進去他會跳出視窗要你輸入
```
cat /opt/sonatype-work/nexus3/admin.password
```

如果要連 nuget & maven 網址在以下
```
http://127.0.0.1:8081/#admin/repository/repositories:nuget.org-proxy
http://127.0.0.1:8081/#admin/repository/repositories:maven-central
```

想改 port 的話可以找這裡
```
/opt/sonatype-work/nexus3/etc
```

### wsl 網路問題
因為用 wsl 的緣故 , 如果連線 127.0.0.1:8081 這樣的話是正常 work 可是要在區網連線馬上就陣亡
google 了半天應該是 wsl 網路架構需要進行設定 , 可以[參考這個大陸人](https://zhuanlan.zhihu.com/p/425312804) 或是[這篇討論](https://stackoverflow.com/questions/61002681/connecting-to-wsl2-server-via-local-network)

我自己卡在這關 , 回頭再來看看詳細意義 , 因為是用 ubuntu , 現在預設沒 ifconfig , 都用 ip 這個工具來看
```
#先用 ip a 看看 wsl 裡面的 ip 是啥
ip a
```


接著在 powershell 執行這句 , `172.30.86.10` => wsl 的 ip , 這個好像每次都會變 , 實際上要玩還是開個 vm
另外在 windows 防火牆上面的輸出規則應該也要設定 , 不然還是 gg
```
netsh interface portproxy add v4tov4 listenport=8081 listenaddress=0.0.0.0 connectport=8081 connectaddress=172.30.86.10
```

show
```
netsh interface portproxy show all
```

delete
```
netsh interface portproxy delete v4tov4 listenport=8081 listenaddress=0.0.0.0
```

在 powershell 用 telnet 驗證有無正常連上
```
telnet 123.45.67.89 8081
```

### conda
點齒輪 => `create repository` => `conda-forge` => `https://conda.anaconda.org/conda-forge/`
看了下他的 conda 好像只有代理功能 , 沒有 hosted & group , 所以無腦選下去即可
然後使用自己的 proxy 建立一個 python 環境看看 , 這裡有個雷就是不能加 main , 參考[這篇](https://stackoverflow.com/questions/70738491/which-url-to-use-for-conda-repositories-published-through-nexus-repository-manag)
```
conda create --name test_selenium_with_proxy python=3.9 -c http://123.45.67.89:8081/repository/conda-forge
conda activate test_selenium_with_proxy
conda install selenium -c http://123.45.67.89:8081/repository/conda-forge
```


### pip
主要參考[這篇](https://help.sonatype.com/repomanager3/nexus-repository-administration/formats/pypi-repositories)
server 端一樣 `create repository` 然後 Name 設定 `pypi-proxy` , `Url` 設定 `https://pypi.org/`
接著在 client 端首先看你的 `pip.ini` 要放哪裡
```
pip config -v debug

env_var:
env:
global:
  C:\ProgramData\pip\pip.ini, exists: False
site:
  C:\Users\yourname\Anaconda3\pip.ini, exists: False
user:
  C:\Users\yourname\pip\pip.ini, exists: False
  C:\Users\yourname\AppData\Roaming\pip\pip.ini, exists: False
```

接著自己新增 `pip.ini` 然後把以下內容丟進去 , 如果沒有 https 要加上 `trusted-host` , 然後 pip install pyttsx3 應該就可以了
```
[global]
index = http://123.45.67.89:8081/repository/pypi-proxy/pypi
index-url = http://123.45.67.89:8081/repository/pypi-proxy/simple

[install]
trusted-host = 123.45.67.89:8081
```


### nuget
用 nuget 玩看看
`Manage Nuget Package` => `點齒輪` => `加號` => `Name` => `輸入 nexus3` => `Source` => `輸入 https://api.nuget.org/v3/index.json`
找個 HelloWorld 的 package 來測試看看 , 這裡可以選 group 或是直接選 proxy 都可以
group 的概念就是把 hosted & proxy 做成一個群組 , 這樣只要指向這個 ip 即可
後來發現這個 [老外的影片](https://www.youtube.com/watch?v=UehkG1VHtz0) 不錯
```
#將網址加入到你自己的 visual studio
https://api.nuget.org/v3/index.json

http://123.45.67.89:8081/repository/nuget-group/index.json
```

接著開個 console 專案 , 我還真沒想到會有這麼廢的套件 , 真不可思議
```
// See https://aka.ms/new-console-template for more information
using System;
using HelloWorld;

HelloWorld.Hello h = new Hello();
h.World();
```

### maven
先找到 maven 的 `setting.xml` , 我之前 maven 應該是 chocolatey 裝的 `C:\ProgramData\chocolatey\lib\maven\apache-maven-3.8.1\conf\settings.xml`
如果不確定 maven 到底有沒有的話 , 可以這樣測試看看
```
mvn -v
```

接著找到 `mirrors` 加上這段 , 應該就可以了
```
<mirror>  
	<id>nexus-maven</id>  
	<name>nexus-maven</name>  
	<url>http://123.45.67.89:8081/repository/maven-public/</url>  
	<mirrorOf>central</mirrorOf>          
</mirror> 
```

然後看是用 intellij or vscode , 在 `pom.xml` 的 `dependencies` 裡面加上去想要的套件基本就搞定了 , 要啥就去 [mvnrepository](https://mvnrepository.com) 找看看
以下拿 jackson 來測試看看 , 加完後記得要更新就搞定
```
<!-- https://mvnrepository.com/artifact/com.fasterxml.jackson.core/jackson-core -->
<dependency>
    <groupId>com.fasterxml.jackson.core</groupId>
    <artifactId>jackson-core</artifactId>
    <version>2.13.3</version>
</dependency>
```
