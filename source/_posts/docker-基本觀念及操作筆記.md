---
title: docker 基本觀念及操作筆記
date: 2021-05-12 19:19:58
tags: docker
---
&nbsp;
<!-- more -->

### powershell 事前準備
礙於之前整理 powershell 比較散亂 , 我已經更新成[這篇](https://weber87na.github.io/2021/12/01/%E6%88%91%E7%9A%84-powershell-%E8%A8%AD%E5%AE%9A/)
安裝 `CHOCOLATEY` [官網](https://chocolatey.org/install)
```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

choco 安裝 `gsudo`
```
choco install gsudo
```

或使用 powershell 安裝 `gsudo`
```
PowerShell -Command "Set-ExecutionPolicy RemoteSigned -scope Process; iwr -useb https://raw.githubusercontent.com/gerardog/gsudo/master/installgsudo.ps1 | iex"
```

安裝 firacode 字體 (建議要安裝 , 這樣使用 git-posh 才會正常顯示)
```
choco install firacode
```
或[官網下載](https://github.com/tonsky/FiraCode) , 解壓縮以後選 `ttf` 全選以後右鍵安裝

### 設定 windows ssh powershell 連線
我這邊直接使用 windows 的 powershell 來進行連線 , 因為預設的 powershell 畫面很醜 , 像是很古老的當機畫面 , 所以稍微 config 一下
[powershell 字體設定](https://zhuanlan.zhihu.com/p/163007658)
```
電腦\HKEY_CURRENT_USER\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe
FaceName 設定 Fira Code 注意有空格
```
設定好後開啟 powershell => `右鍵` => `內容` => `字型` => `Fira Code` 即可

萬一有使用 powerline 這鬼東西 , 可以到這個網頁[下載](https://github.com/powerline/fonts) 
選擇這個字體 `DejaVu Sans Mono for Powerline` , 其他字體測不出來 , 圖示都會亂碼 , 安裝好的話用 ssh 連線 ubuntu 也可以正常顯示

後來發現不管用什麼字體只要是 run powershell 都會跑掉變回原形很醜 , 找到保哥[這篇](https://blog.miniasp.com/post/2017/12/06/Microsoft-YaHei-Mono-Chinese-Font-for-Command-Prompt-and-WSL) 只要下載他的字體就可以解決問題 , 但是一些 icon 還是無解至少開 vim 不會跑掉 , 對沒有 windows terminal 的環境幫助滿大的
另外捲軸沒有 30 cm 的話可以用老外的[設定](https://mcpmag.com/articles/2013/03/12/powershell-screen-buffer-size.aspx) 老外直接設定 3000 cm真是狠腳色

安裝 powershell 黑色系佈景 [Dracula](https://github.com/dracula/powershell)
下載後解壓 `dist\ColorTool` 執行 `install.cmd` 即可完成安裝 , 並且將 `dracula-prompt-configuration.ps1` 內的設定貼到 `$profile`
powershell `$profile` 的設定檔 `profile.ps1` 跟 `.bashrc` 類似 , 就是用來初始化 powershell 的設定檔
一般會在以下路徑內新增一個 `profile.ps1` 文件來進行管理 , 若有 `Microsoft.PowerShell_profile.ps1` 也可以直接編輯他
```
#for admin
C:\Windows\System32\WindowsPowerShell\v1.0

#for user
C:\Users\YourName\Documents\WindowsPowerShell\
```

安裝 oh-my-posh
```
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

安裝 [DockerCompletion](https://github.com/matt9ucci/DockerCompletion)
```
Install-Module DockerCompletion
```

啟動歷史預測提示 [predictive](https://devblogs.microsoft.com/powershell/announcing-psreadline-2-1-with-predictive-intellisense/)
注意預設是關閉的需要自行啟用
```
Install-Module PSReadLine -RequiredVersion 2.1.0
```

最後額外設定自己的 config , 過程中太頻繁懶得打 docker 直接用 alias , 另外還有像是 history 搜尋可以按 `ctrl + r` 往前搜尋這種不錯的小技巧可以用 , 詳情參考[印度仔](https://www.thewindowsclub.com/how-to-see-powershell-command-history-on-windows-10)
```
#設定 powershell 的 key binding emacs style
Set-PSReadLineOption -EditMode Emacs
Import-Module posh-git
Import-Module oh-my-posh

#注意 posh v3 新版是這個命令不是 Set-Theme
Set-PoshPrompt darkblood

#設定 docker alias
Set-Alias -Name d -Value docker

#啟用 docker 提示
Import-Module DockerCompletion

#設定歷史預測提示
Set-PSReadLineOption -PredictionSource History
```

接著可能會用 powershell 以 Nuget 安裝套件 , 用 admin 執行以下命令 , 防止後續炸出 error
```
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Install-PackageProvider -Name NuGet
```

萬一 docker 炸出以下 error
```
error during connect: Get http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.38/images/json: open //./pipe/docker_engine: The system cannot find the file specified. In the default daemon configuration on Windows, the docker client must be run elevated to connect. This error may also indicate that the docker daemon is not running
```

請輸入以下命令即可
```
cd "C:\Program Files\Docker\Docker"
./DockerCli.exe -SwitchDaemon
```

切換 docker 使用的 engine linux or windows
```
#切成 linux
./DockerCli.exe -SwitchLinuxEngine

#切成 windows
./DockerCli.exe -SwitchWindowsEngine
```

### docker 基本觀念及操作

image => 檔案
container => 檔案內的軟體

查看資訊的基本命令
```
#看一些資訊
docker info

#目前執行中的 container
docker ps

#注意看看是 windows or linux
docker version

#幫助訊息
docker help
docker container --help
docker container attach --help
```

常用的訊息命令
```
#看這機器上有多少 image
docker image ls
docker images

#看目前 running 的
docker container ls

#看沒 running 的
docker container ls -a

docker container ls --no-trunc -a
docker image ls --no-trunc -a
```

搜尋與下載 image
[熱門的 image](https://hub.docker.com/search?image_filter=official&type=image)
```
#搜尋
docker search hello-world

#搜尋星星數大於 100 的
docker search nginx -f stars=100

#拉 hello-world
docker image pull hello-world
docker pull hello-world

docker pull busybox

#看看自己有什麼 image
docker image ls
```

執行 hello-world
```
docker container run hello-world
```

執行 ubuntu 交互
```
docker pull ubuntu

#-i interactive 交互
#-t tty linux 終端術語
docker run -i -t ubuntu /bin/bash
docker run -it ubuntu /bin/bash

#預設就是進入到 /bin/bash 裡面
docker run ubuntu

#直接跑 bash
docker exec -it 3afs3 /bin/bash
```

除了交互式以外 , 也可以跑成後台服務 (daemon , 大陸叫做守護進程)

-d detachs
-p publish <host>:<container>

```
docker run --help
docker pull nginx
docker run --name my-nginx -d -p 8787:80 nginx
```

執行 chrome http://localhost:8787/ 應該可以看到 nginx
補充可以用 inspect 檢查 image or container 等等狀態
```
docker container inspect d312

#用 powershell 列出橫式的訊息
(docker container inspect d312 | ConvertFrom-Json)

#撈 ip
$ip = (docker container inspect d312 | ConvertFrom-Json).NetworkSettings.Networks.bridge.IPAddress

#執行 chrome , 不過這個 example 不能這樣 run
#start http://$ip

#其他連線方法以我這台為例
#http://host.docker.internal:8787/
```

其他操作 for image & container
```
#停止 container
docker stop my-nginx

#開啟 my-nginx 服務
docker start my-nginx

#因為被停止了所以用 -a 列出包含停止的 container
docker ps -a

#看看最後執行的 container 是什麼
docker ps -l

#-q 是只列出 id
docker ps -lq

#刪除 container
docker container rm d312bcc86783

#也可以搭配剛剛的命令使用
docker container rm $(docker ps -lq)

#這樣可以快速刪除全部就像 sql 語法的 in 一樣
#select * from container where id in (a345a,b2hfg,c25s,dw3,e23)
docker container rm $(docker ps ls -aq)
```

### Lab Docker 包裝一個 vim 的 image
常常包來用的兩個超迷你的 linux
```
docker pull busybox
docker pull alpine
```

包裝一個新的 image
```
docker container run -it alpine
apk add bash
```

注意這個一 run exit 下載就白費了 , 所以我們需要開另外一個 powershell
```
#看看目前這個在 run 的 container
docker ps

#自己包裝成有 bash 版本的
docker commit -m="add bash" -a="gg" 0c4a5f78e8ab alpine-bash
```

這下子就有 bash 可以用了
```
docker container run -it alpine-bash /bin/bash

#在多包一個 vim
apk add vim
```

一樣開啟另外一個 powershell 並且 commit
```
docker ps
docker commit -m="add vim" -a="gg" 5cb alpine-bash-vim
docker container run -it alpine-bash-vim /bin/bash
```

從 host 複製 vimrc 檔案到 container , 404b2c => container 的 id
```
docker cp "C:\Program Files\Git\etc\vimrc" 404b2c:/root/vimrc
apk add curl
apk add git
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
vim
:PlugInstall
#找到 colorscheme ayu 並且註解掉最後就可以 commit 了
```

補充 , 從 container 複製檔案到 host
```
docker cp 404b2c:/root/.vimrc ${PWD}/vimrcnew
```

另外一個 powershell 進行 commit
```
docker ps
docker commit -m="add vim" -a="gg" 5cb alpine-bash-vim-myconfig
docker images
#最後很清楚可以看到 docker 是一層一層疊上來的 , 所以最後一個 image 裝了一堆東西大小明顯變大很多
#REPOSITORY                         TAG        IMAGE ID       CREATED             SIZE
#alpine-bash-vim-myconfig           latest     cf92a859ff98   3 seconds ago       51MB
#alpine-bash-vim                    latest     dc17cb68096a   About an hour ago   25.7MB
#alpine-bash                        latest     0f542f76e815   About an hour ago   9.74MB
```

### Lab 用 busybox 安裝 vim , 並且包裝成新的 image
```
docker run -it progrium/busybox
```

在 busybox 內執行安裝 vim 並且退出 container
```
# busybox 裡面安裝 vim
opkg-install vim
exit
```

想要再次啟動這個 container 的話可以輸入以下指令 , 注意 busybox 跟 alpine 預設都是 sh
```
docker start 6f9bf9785ce5 /bin/sh
```

雖然已經離開了 container , 但還是可以 commit 為新的 image
```
docker commit -a="gg" -m="add vim" 6f9bf9785ce5 busybox-vim
```

注意若現在把之前的 container `6f9bf9785ce5` 跑起來的話 vim 還是會存在的 , 但如果新跑一個 image 則 vim 不會在
```
docker start 6f9bf9785ce5

#執行 vim 是可以成功的
vim
```

以下方法則是從新啟動一個 container , 所以裡面不會有 vim , container 的 id 是不一樣的
```
docker run -it progrium/busybox
docker container ls -a
#CONTAINER ID   IMAGE            COMMAND   CREATED              STATUS                         
#c77c1d77e23b   progrium/busybox "/bin/sh" About a minute ago   Exited (127) About a minute ago
#6f9bf9785ce5   progrium/busybox "/bin/sh" 29 minutes ago       Exited (137) 6 minutes ago  
```


### 網路基本命令
```
docker network ls

#建立網路
docker network create test

#刪除網路
docker network rm 789
```

在 container 內互相連線
```
docker pull tutum/wordpress
docker run -d -p 10001:80 --name blog1 tutum/wordpress

#將 container blog1 連線到 my_network 的網路內
docker network connect my_network blog1

#用 --network 指定網路 , 所以此時這兩個 container 就可以互通了
docker run -it --network my_network ubuntu:16.04 bash
```

此時在 ubuntu 的 container 內安裝 curl 並且執行以下命令
```
apt update && apt install -y curl
curl -sSL blog1 | head -n5
```

### docker 進階網路 debug
在 docker 裡面拔了一堆東西 , 所以想看網路的話直接就 gg , 所以應該包一個這種網路除錯工具來用
通常資深一點的人都習慣用 ifconfig 這類 net-tools 命令來看 , 所以最好新舊 tool 都包一包
```
sudo apt update
sudo apt upgrade

#舊版標配
sudo apt-get install -y net-tools

#新版標配
sudo apt-get install -y iproute2
```

常用 debug 網路通不通的 command
```
#一直 ping
ping 8.8.8.8

#ping 一次
ping 8.8.8.8 -c1

traceroute 8.8.8.8
mtr 8.8.8.8
```

docker 實際上是透過 linux bridge 隔離 network namespace , 預設會送你一張 docker0 , 如果有建立 container 就會自動發配 veth 給你
```
ip a

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:36:b4:38 brd ff:ff:ff:ff:ff:ff
    inet 192.168.137.156/24 brd 192.168.137.255 scope global dynamic eth0
       valid_lft 604759sec preferred_lft 604759sec
    inet6 fe80::215:5dff:fe36:b438/64 scope link
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
    link/ether 02:42:9f:6f:7d:c8 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:9fff:fe6f:7dc8/64 scope link
       valid_lft forever preferred_lft forever
5: veth1f0e6cb@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
    link/ether f2:2c:a5:77:11:12 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::f02c:a5ff:fe77:1112/64 scope link
       valid_lft forever preferred_lft forever
7: veth9a6ae72@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
    link/ether b6:99:a6:c7:dc:cb brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::b499:a6ff:fec7:dccb/64 scope link
       valid_lft forever preferred_lft forever
21: vetha156707@if20: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP group default
    link/ether b6:79:46:57:e5:82 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::b479:46ff:fe57:e582/64 scope link
       valid_lft forever preferred_lft forever
```

只看 veth 不是很好看 , 所以可以用下面這種方法來看些 details
撈 container 的 pid , 接著用 nsenter 跳進去 , 注意這邊指定 -n 參數的話才可以直接進去 network namespace (netns)
發現很好用 , 跳到 netns 內可以用 host 的工具進行 debug , 如果直接進去 docker 裡面是沒有 ip 工具可以使用的
最後可以看看[強國人這篇](https://www.cpweb.top/343)寫得滿詳細的
```
docker inspect 00f | grep Pid
#不分大小寫
docker inspect 00f | grep -i pid

#跳到 network namespace
sudo nsenter -n -t 152912 /bin/bash
ip a
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#       valid_lft forever preferred_lft forever
#6: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
#    link/ether 02:42:ac:11:00:03 brd ff:ff:ff:ff:ff:ff link-netnsid 0
#    inet 172.17.0.3/16 brd 172.17.255.255 scope global eth0
#       valid_lft forever preferred_lft forever


#看看跟直接跳 docker 裡面有啥差異 (nginx container)
docker container exec -it e0c /bin/bash
root@e0c0c8d096ca:/# ip a
bash: ip: command not found

#docker 有把 netns 偷偷搬到 docker 資料夾底下 , 多隔一層
#預設則是在 /var/run/netns/
sudo ls /var/run/docker/netns
```


為何 container 可以連線外網 , 可以用 iptables 查看看 docker 偷偷做的事 , 有兩種看法
方法一 `iptables-save`
```
sudo iptables-save

# Generated by iptables-save v1.8.4 on Wed Aug 11 04:23:28 2021
*filter
:INPUT ACCEPT [8720:602415]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [8382:1516434]
:DOCKER - [0:0]
:DOCKER-ISOLATION-STAGE-1 - [0:0]
:DOCKER-ISOLATION-STAGE-2 - [0:0]
:DOCKER-USER - [0:0]
-A FORWARD -j DOCKER-USER
-A FORWARD -j DOCKER-ISOLATION-STAGE-1
-A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -o docker0 -j DOCKER
-A FORWARD -i docker0 ! -o docker0 -j ACCEPT
-A FORWARD -i docker0 -o docker0 -j ACCEPT
-A DOCKER-ISOLATION-STAGE-1 -i docker0 ! -o docker0 -j DOCKER-ISOLATION-STAGE-2
-A DOCKER-ISOLATION-STAGE-1 -j RETURN
-A DOCKER-ISOLATION-STAGE-2 -o docker0 -j DROP
-A DOCKER-ISOLATION-STAGE-2 -j RETURN
-A DOCKER-USER -j RETURN
COMMIT
# Completed on Wed Aug 11 04:23:28 2021
# Generated by iptables-save v1.8.4 on Wed Aug 11 04:23:28 2021
*nat
:PREROUTING ACCEPT [454:89225]
:INPUT ACCEPT [22:4283]
:OUTPUT ACCEPT [1697:136012]
:POSTROUTING ACCEPT [1703:136290]
:DOCKER - [0:0]
-A PREROUTING -m addrtype --dst-type LOCAL -j DOCKER
-A OUTPUT ! -d 127.0.0.0/8 -m addrtype --dst-type LOCAL -j DOCKER
-A POSTROUTING -s 172.17.0.0/16 ! -o docker0 -j MASQUERADE
-A DOCKER -i docker0 -j RETURN
COMMIT
# Completed on Wed Aug 11 04:23:28 2021
```

方法二 `iptables` 可以搭配參數看到行號
```
sudo iptables --list --line-number

#Chain INPUT (policy ACCEPT)
#num  target     prot opt source               destination
#
#Chain FORWARD (policy DROP)
#num  target     prot opt source               destination
#1    DOCKER-USER  all  --  anywhere             anywhere
#2    DOCKER-ISOLATION-STAGE-1  all  --  anywhere             anywhere
#3    ACCEPT     all  --  anywhere             anywhere             ctstate RELATED,ESTABLISHED
#4    DOCKER     all  --  anywhere             anywhere
#5    ACCEPT     all  --  anywhere             anywhere
#6    ACCEPT     all  --  anywhere             anywhere
#
#Chain OUTPUT (policy ACCEPT)
#num  target     prot opt source               destination
#
#Chain DOCKER (1 references)
#num  target     prot opt source               destination
#
#Chain DOCKER-ISOLATION-STAGE-1 (1 references)
#num  target     prot opt source               destination
#1    DOCKER-ISOLATION-STAGE-2  all  --  anywhere             anywhere
#2    RETURN     all  --  anywhere             anywhere
#
#Chain DOCKER-ISOLATION-STAGE-2 (1 references)
#num  target     prot opt source               destination
#1    DROP       all  --  anywhere             anywhere
#2    RETURN     all  --  anywhere             anywhere
#
#Chain DOCKER-USER (1 references)
#num  target     prot opt source               destination
#1    RETURN     all  --  anywhere             anywhere
```

刪除的話用需要加 Chain 跟 行號
```
sudo iptables --delete FORWARD 1
```

最後還有種 debug 有趣用法 , 因為 docker 有個 container 模式 , k8s 就是用這種模式
這邊用 nginx + dotnet core 來玩看看 , 因為 dotnet core 的 image 內建 curl 所以可以用來打 nginx 網頁看看
提醒如果你 port 相衝突到的話 container 一執行 run 就直接跳走了 , 例如同時起兩個 nginx 會搶 80 , 所以會都起不來
```
docker run nginx
docker run  -it --net=container:757f5a389a6b  mcr.microsoft.com/dotnet/sdk
docker inspect 757f5a389a6b | grep IPA

#"SecondaryIPAddresses": null,
#"IPAddress": "172.17.0.2",
#        "IPAMConfig": null,
#        "IPAddress": "172.17.0.2",

docker exec -it awr3 /bin/bash
```

先跳到 nginx 的 netns 看看 , 注意這邊可以用 ip a 是因為在 host run
```
docker inspect 757f5a389a6b | grep -i pid
sudo   nsenter -t 25311 -n
ip a
#1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
#    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
#    inet 127.0.0.1/8 scope host lo
#       valid_lft forever preferred_lft forever
#16: eth0@if17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
#    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
#    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
#       valid_lft forever preferred_lft forever
```

接著跳到 dotnet core 的 netns 內看看 , 發現 ip 果然與 dotnet core 的如出一徹
```
docker inspect awr3 | grep -i pid
sudo   nsenter -t 35348 -n
ip a
#16: eth0@if17: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default
#    link/ether 02:42:ac:11:00:02 brd ff:ff:ff:ff:ff:ff link-netnsid 0
#    inet 172.17.0.2/16 brd 172.17.255.255 scope global eth0
#       valid_lft forever preferred_lft forever
```

### 透過 tcp 連線遠端 docker
莫名其妙的遠端 docker tcp 不能連線 , [參考強者老外](https://stackoverflow.com/questions/26561963/how-to-detect-a-docker-daemon-port)
上課看到可以直接用 ip 加上指令的方式直接管理遠端 docker
```
docker -H 10.1.25.123 images
```

搞了一堆方法都失敗 , 後來 try 這個老外講的才成功

Prepare extra configuration file. Create a file named /etc/systemd/system/docker.service.d/docker.conf. Inside the file docker.conf, paste below content:
```
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```
Note that if there is no directory like docker.service.d or a file named docker.conf then you should create it.

Restart Docker. After saving this file, reload the configuration by systemctl daemon-reload and restart Docker by systemctl restart docker.service.

Check your Docker daemon. After restarting docker service, you can see the port in the output of systemctl status docker.service like /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock.


以下為我的實作筆記過程
```
cd /etc/systemd/system
mkdir docker.service.d
cd docker.service.d
sudo vim docker.conf

#加入這個片段
#[Service]
#ExecStart=
#ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock

#重新更新 daemon 設定
systemctl daemon-reload

#重開 docker
systemctl restart docker.service

#印出狀態
systemctl status docker.service

#● docker.service - Docker Application Container Engine
#     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
#    Drop-In: /etc/systemd/system/docker.service.d
#             └─docker.conf
#     Active: active (running) since Thu 2021-07-15 12:49:20 CST; 8min ago
#TriggeredBy: ● docker.socket
#       Docs: https://docs.docker.com
#   Main PID: 829386 (dockerd)
#      Tasks: 39
#     Memory: 75.5M
#     CGroup: /system.slice/docker.service
#             ├─829386 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
#             └─829752 /usr/bin/docker-proxy -proto tcp -host-ip 127.0.0.1 -host-port 1514 -container-ip 172.21.0.6 -container-port 10514


#一樣印出狀態
ps auxw | grep dockerd
#root      829386  3.2  2.8 2422328 114552 ?      Ssl  12:48   0:19 /usr/bin/dockerd -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock
```
