---
title: docker 基本觀念及操作筆記
date: 2021-05-12 19:19:58
tags: docker
---
&nbsp;
<!-- more -->

### powershell 事前準備
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
