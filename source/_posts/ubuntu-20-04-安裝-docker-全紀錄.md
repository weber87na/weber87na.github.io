---
title: ubuntu 20.04 安裝 docker 全紀錄
date: 2021-05-11 02:28:13
tags:
- docker
- ubuntu
---
&nbsp;
<!-- more -->

### 安裝 ubuntu 並設定網路
有點抖 , 先在 Hyper-V 上安裝 [ubuntu-20.04.2.0-desktop-amd64.iso](https://releases.ubuntu.com/20.04/)
鍵盤排列方式用 EN(US)

這邊比較要注意的 , 您的名稱跟您的電腦名稱不是登入帳號 username 才是
您的名稱 gypc
您的電腦名稱 gypc
username : gy
password : gy

ip 設定主要參考這篇[設定](https://www.footmark.info/linux/ubuntu/ubuntu-server-install/)
```
cd /etc/netplan

#備份防止意外
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak

#需要用 sudo 否則無法編輯 , 預設只有 vi 沒有 vim
sudo vi 00-installer-config.yaml

#編完後需要測看看是否生效
sudo netplan try

#預設沒有 net-tools 所以用以下命令看 ip 
ip addr
```

00-installer-config.yaml 設定
``` yaml
network:
  renderer: NetworkManager # 網路管理模式使用 Network Manager，未設定預設使用 systemd-workd
  ethernets:
    eth0: # 網路裝置
      dhcp4: false # false: 關閉 DHCP；true： 啟用
      addresses: [10.1.25.123/24] # 固定 IP 與網路遮罩
      gateway4: 10.1.25.234 # 預設閘道
      nameservers:
        addresses: [10.1.30.87] # DNS Server
  version: 2
```

成功連上外網後 , 先安裝 vim 跟 net-tools , 方便做事
```
sudo apt install net-tools
sudo apt install vim
```

### [config ssh](https://www.gushiciku.cn/pl/pMnD/zh-tw)
ubuntu
``` bash
sudo apt install openssh-server
sudo systemctl status ssh
sudo ufw allow ssh
```

### 設定 windows ssh powershell 連線
我這邊直接使用 windows 的 powershell 來進行連線 , 因為預設的 powershell 畫面很醜 , 像是很古老的當機畫面 , 所以稍微 config 一下
[powershell 字體設定](https://zhuanlan.zhihu.com/p/163007658)
```
電腦\HKEY_CURRENT_USER\Console\%SystemRoot%_SysWOW64_WindowsPowerShell_v1.0_powershell.exe
FaceName 設定 Fira Code 注意有空格
```

[安裝 oh-my-posh](https://blog.poychang.net/setting-powershell-theme-with-oh-my-posh/)
```
Install-Module posh-git -Scope CurrentUser
Install-Module oh-my-posh -Scope CurrentUser
```

路徑 `C:\Users\YourName\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`
``` powershell
#設定 powershell 的 key binding emacs style
Set-PSReadLineOption -EditMode Emacs
Import-Module posh-git
Import-Module oh-my-posh

#注意 v3 新版是這個命令不是 Set-Theme
Set-PoshPrompt darkblood
```

### 測試 ssh 連線
萬一炸以下錯誤表示 ubuntu server 還沒安裝 openssh-server , 記得回去補一下
ssh: connect to host 10.1.25.123 port 22: Connection refused
``` powershell
ssh gy@10.1.25.123
```

### 設定使用者
```
#加入使用者過程會要你輸入密碼
sudo adduser gg

#看目前群組有哪些 user
sudo cat /etc/group | grep sudo

#改使用者密碼
sudo passwd gg #<username>
```

[docker 安裝](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04)
```
安裝 docker
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker

#如果每次都要輸入 sudo 執行 docker 的話要執行這些 , 就不用都加上 sudo 了
#加入使用者
sudo usermod -aG docker ${USER}
su - ${USER}
id -nG
```

跑 docker 的 helloworld
```
docker pull hello-world
docker run -it hello-world
```
