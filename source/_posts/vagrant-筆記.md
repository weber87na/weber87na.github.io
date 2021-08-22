---
title: vagrant 筆記
date: 2021-07-28 00:53:29
tags: vagrant
---
&nbsp;
<!-- more -->

### 日常操作
vagrant [下載位置](https://www.vagrantup.com/downloads)
windows 最好裝一下 [gsudo](https://github.com/gerardog/gsudo)

搜尋 [box](https://app.vagrantup.com/boxes/search)
比較重要的參數 , 特別注意要看看 provider 要符合你自己的環境 , 像是這個 `bento/ubuntu-20.04` 他所提供有 hyperv provider 的 version 就比較舊
```
config.vm.box = "bento/ubuntu-20.04"
config.vm.box_version ='202005.21.0'
```

另外一個讓人很火大的是 smb 這個鬼設定 , 如果不加下面這串他會一直要你敲 username and password , 後來發現是你 windows 的帳號密碼
```
config.vm.synced_folder ".", "/vagrant", :disabled => true
```

啟動並且看目前狀態 , 注意自己用啥虛擬機要選對
```
sudo vagrant up --provider=hyperv
sudo vagrant status
```

連線進去 vm
```
sudo vagrant ssh
```

ssh 連線 , 先看使用的 key 在哪 , 接著用普通的 ssh 連線就搞定啦
```
vagrant shh-config
ssh -i "C:\Users\yourname\test\.vagrant\machines\test\hyperv\private_key" -p 22 vagrant@192.168.22.123
```

### Vagrant 常見錯誤
#### 執行 destroy 關不掉或是啟動不了
```
An action 'read_state' was attempted on the machine 'net',
but another process is already executing an action on the machine.
Vagrant locks each machine for access by only one process at a time.
Please wait until the other Vagrant process finishes modifying this
machine, then try again.

If you believe this message is in error, please check the process
listing for any "ruby" or "vagrant" processes and kill them. Then
```

執行以下命令即可
```
ps | select-string ruby
ps | select-string vagrant

sudo Stop-Process -name ruby
sudo Stop-Process -name vagrant
```

#### 權限不足
```
The provider 'hyperv' that was requested to back the machine
'net' is reporting that it isn't usable on this system. The
reason is shown below:

The Hyper-V provider requires that Vagrant be run with
administrative privileges. This is a limitation of Hyper-V itself.
Hyper-V requires administrative privileges for management
commands. Please restart your console with administrative
privileges and try again.
```

執行以下命令或直接開 admin 起來跑
```
sudo vagrannt ssh
```

### Hyper-v 地雷
1.針對 Hyper-v Vagrant 目前版本好像沒辦法使用固定 ip [參考自此](https://jasonlee.xyz/vagrant-zai-windows-10-yong-hypervshe-ding-gu-ding-ip/)
2.設定 Hyper-v 的網際網路連線共用 NAT 在 GUI 設定完後 , 重新開機後就沒用了 , 但是 GUI 還會打勾 [參考自此](https://kheresy.wordpress.com/2019/03/12/fix-windows-ics-not-work-after-reboot/)

#### 手動設定 Hyper-v 網路為 NAT
開啟 Hyper-v 管理員 `虛擬交換器管理員` => `新虛擬網路交換器` => `內部` => `建立虛擬交換器` => `名稱設定 ubuntu` => `內部網路`


`開啟網路和網際網路設定` => `乙太網路` => `變更介面卡選項` => `vEthernet (ubuntu)` => `網際網路通訊協定第 4 版(TCP/IP)` => `使用下列的 ip 位置` => `ip 位置 192.168.137.1` => `子網路遮罩 255.255.255.0`



`乙太網路` => `共用` => `網際網路連線共用` => `允許其他網路使用者透過這台電腦的網際網路來連線` => `家用網路連線` => `vEthernet (ubuntu)`

#### 啟動 vagrant
```
mkdir lab
cd lab
sudo vagrant up --provider=hyperv
sudo vagrant ssh
```

vagrantfile
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "bento/ubuntu-20.04"
  config.vm.box_version ='202005.21.0'
  config.vm.hostname = 'docker-lab'
  config.vm.define vm_name = 'docker-lab'
  config.vm.provider "hyperv"

  #注意預設他會用 Default Switch
  #需要新增一個 ubuntu 的 bridge
  #如果用 hyperv 其實沒辦法固定 ip 需要登入到 ssh 以後修正 netplan
  config.vm.network "private_network", ip: "192.168.137.123", auto_config: false , bridge: "ubuntu"

  #停止分享資料夾
  config.vm.synced_folder ".", "/vagrant", :disabled => true


  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    set -e -x -u
    export DEBIAN_FRONTEND=noninteractive

    #安裝可能需要的咚咚
    sudo apt-get update
    sudo apt-get install -y vim git cmake build-essential tcpdump tig socat bash-completion golang libpcap-dev bridge-utils ipcalc conntrack jq bat

    #安裝 docker
	sudo apt update
	sudo apt install -y apt-transport-https ca-certificates curl software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
	sudo apt update
	apt-cache policy docker-ce
	sudo apt install -y docker-ce
	sudo usermod -aG docker $USER

	#安裝 bash-it , 也可以用 zsh or 其他代替
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    bash ~/.bash_it/install.sh -s

  SHELL


  config.vm.provider :virtualbox do |v|
      v.customize ["modifyvm", :id, "--cpus", 2]
      v.customize ["modifyvm", :id, "--memory", 2048]
      v.customize ['modifyvm', :id, '--nicpromisc1', 'allow-all']
  end
end
```


#### 登入 ssh 設定 ubuntu
這串註解不能在 vagrantfile 內執行 , 需要用 vagrant 登入 ssh 以後才執行 , 這無解 , 用 hyperv 原罪
如果 dhcp4 設定為 true 的話會多一個動態 ip
另外這個選項好像每台又不太一樣? `renderer: NetworkManager` , 我最後不加才 try 成功
可以用 vim 來編輯或是下面這個技巧直接修改
```
sudo bash -c "cat > /etc/netplan/01-netcfg.yaml << EOF
network:
  version: 2
  ethernets:
    eth0:
      addresses: [192.168.137.123/24]
      gateway4: 192.168.137.1
      dhcp4: no
      nameservers:
        addresses: [8.8.8.8]
EOF
"

#需要驗證看看格式對不對的話可以用以下指令
sudo netplan generate

#讓網路生效
sudo netplan apply
```

#### 設定 GUI 勾了 NAT 重開就失效的問題
`regedit` => `HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\SharedAccess` => 新增 `EnableRebootPersistConnection` => `DWORD 32bit` => `設定值 1`
`services.msc` => 找到他 `Internet Connection Sharing (ICS)` => 啟動類型由 `手動` 改 `自動`


#### 參考資料
多網卡 bridge 的參考
https://www.vagrantup.com/docs/networking/public_network

powershell 建立網卡
https://quotidian-ennui.github.io/blog/2016/08/17/vagrant-windows10-hyperv/

老外講怎麼設定 internal
https://gist.github.com/savishy/8ed40cd8692e295d64f45e299c2b83c9

大陸人講怎麼設定 internal
https://www.twblogs.net/a/5d650631bd9eee5327fe66cf

重點很白痴 1 問題 , 微軟 bug?
解決設定 NAT 以後重新開機就失效的問題
https://kheresy.wordpress.com/2019/03/12/fix-windows-ics-not-work-after-reboot/

重點很白痴 2 問題 , 到底 vagrant 問題還是 hyperv 問題不曉得
其實沒辦法設定固定 ip
https://jasonlee.xyz/vagrant-zai-windows-10-yong-hypervshe-ding-gu-ding-ip/
