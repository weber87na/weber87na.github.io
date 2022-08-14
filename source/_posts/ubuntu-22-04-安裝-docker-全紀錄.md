---
title: ubuntu 22.04 安裝 docker 全紀錄
date: 2022-05-06 09:20:03
tags: docker
---
&nbsp;
<!-- more -->

老樣子直接參考[老外](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-22-04)
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
```

接著執行馬上噴 error
```
docker info
ERROR: Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.24/info": dial unix /var/run/docker.sock: connect: permission denied
```

因為權限不夠執行下面這些即可
```
sudo usermod -aG docker ${USER}
su - ${USER}

id -nG
#也可以執行 groups 等價

#正常會列出 docker
#ubuntu adm dialout cdrom floppy sudo audio dip video plugdev netdev lxd docker
```

這次因為直接在 aws ec2 上面搞 , 預設是用 ssh , 所以做到 `su - ${USER}` 這步驟應該就陣亡
可以參考[這篇](https://stackoverflow.com/questions/51667876/ec2-ubuntu-14-default-password)
```
sudo su -
passwd ubuntu
Enter new UNIX password:8787
```

用 aws 連的話 ssh 大概會長這樣
```
ssh -i "haha.pem" ubuntu@ec2-35-123-67-89.us-west-2.compute.amazonaws.com
ssh -i "haha.pem" ubuntu@ec2-54-123-45-10.us-west-2.compute.amazonaws.com
```
