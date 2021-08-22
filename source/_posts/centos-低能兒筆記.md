---
title: centos 低能兒筆記
date: 2021-08-07 19:57:00
tags: centos
---

&nbsp;
<!-- more -->

### 安裝
因為手上有些環境是 centos 7.x , 加上鳥哥的書也是 , 久沒用都忘光了玩看看 , 先到樹德[下載](http://ftp.stu.edu.tw/Linux/CentOS/7.9.2009/isos/x86_64/CentOS-7-x86_64-Minimal-2009.iso) minimal 版本
`新增虛擬機` 下一步 => 名稱 `centos 7` => `第一代` => 記憶體 `2048` => `Default Switch` => `硬碟大小 20 GB` => 選剛剛下載的 iso 位置
鍵盤全部選美國
root 密碼 gg
蓋一個 user gg 密碼 gg

### 時區設定
忘了設定時區 , 預設是美國
```
timedatectl
timedatectl set-timezone Asia/Taipei
```
後來在 ubuntu 上遇到類似的問題 不過是 hyper-v + ubuntu 時間跑掉
主要參考[這篇](https://www.hanktsai.com/2021/01/configure-ubuntu1804-timezone.html)
```
timedatectl
#Local time: Mon 2021-08-16 08:23:35 UTC
#Universal time: Mon 2021-08-16 08:23:35 UTC
#RTC time: Mon 2021-08-16 16:23:36
#Time zone: Etc/UTC (UTC, +0000)
#System clock synchronized: no
#NTP service: n/a
#RTC in local TZ: no

#撈系統上的時區列表
timedatectl list-timezones

#修正時間
sudo timedatectl set-timezone Asia/Taipei

timedatectl
#Local time: Mon 2021-08-16 16:26:09 CST
#Universal time: Mon 2021-08-16 08:26:09 UTC
#RTC time: Mon 2021-08-16 16:26:10
#Time zone: Asia/Taipei (CST, +0800)
#System clock synchronized: no
#NTP service: n/a
#RTC in local TZ: no
```

### 網路設定
進入以後 ping 看看跟 curl 一下 , 發現陣亡 , 發現是很低能的問題 , 不意外
```
ping 8.8.8.8
curl www.google.com
```

看看網卡原來沒給 ip , 上網查一下發現需要手動開啟網卡 , 預設沒 vim
```
ip a
vi /etc/sysconfig/network-scripts/ifcfg-eth0

#ONBOOT 修改為 yes開啟網路
#ONBOOT=yes
```

centos 不是用 netplan 所以直接用 systemctl 來操作
```
systemctl restart network
systemctl status network
ip a
#可以看到系統生出 ip 位置
#172.25.12.123
```

注意因為是用 hyper-v 所以需要額外設定一堆
`虛擬交換器管理員` => `新增虛擬網路交換器` => `內部` => `建立虛擬交換器` = > `名稱 centos` => `內部網路`
`變更介面卡選項` => `選 centos` => `IPV4` => `內容` =>  `ip 192.168.137.123` => `子網路遮罩 255.255.255.0`
至於為什麼是 137 , 是因為設定 NAT windows 好像預設就會給 137
我在家是用 wifi 所以設定共用選 centos 即可, 這個 nat 問題之前其實有[寫過了](https://weber87na.github.io/2021/07/28/vagrant-%E7%AD%86%E8%A8%98/)不過用 ubuntu , 反正又遇到就在筆記一次

如果要設定固定 ip 可以追加 `IPADDR` `PREFIX` `GATEWAY` , 另外要把 `BOOTPROTO` 改為 `static`
另外還要設定 dns 不然對外 ping or curl 都不通
```
vi /etc/sysconfig/network-scripts/ifcfg-eth0
systemctl restart network
vi /etc/resolv.conf
```

resolv.conf
注意這個雷是沒有冒號他吃空格 , 腦子不清醒加了冒號老半天沒動
```
nameserver 192.168.137.1
#nameserver 8.8.8.8
```

ifcfg-eth0
```
TYPE=Ethernet                              
PROXY_METHOD=none                          
BROWSER_ONLY=no                            
#BOOTPROTO=dhcp                            
BOOTPROTO=static                           
DEFROUTE=yes                               
IPV4_FAILURE_FATAL=no                      
IPV6INIT=yes                               
IPV6_AUTOCONF=yes                          
IPV6_DEFROUTE=yes                          
IPV6_FAILURE_FATAL=no                      
IPV6_ADDR_GEN_MODE=stable-privacy          
NAME=eth0                                  
UUID=2902ded1-a5aa-4c96-95f9-f20ab3d19be3  
DEVICE=eth0                                
ONBOOT=yes                                 
                                           
#static ip                                 
IPADDR=192.168.137.123                     
PREFIX=24                                  
GATEWAY=192.168.137.1                      
```

### Windows 安裝 OpenSSH
後來發現 win10 預設沒有 ssh 可用 , 在 windows 安裝 OpenSSH [參考老外](https://jcutrer.com/windows/install-openssh-on-windows10)
加入環境變數到 `PATH` `C:\WINDOWS\System32\OpenSSH`

### 分割硬碟
話說上次弄這個大概也 5 年以前了吧 , 忘光
先說結論前三個是 partition 最後一個是蓋 extended , extended 內又可以蓋其他的邏輯分區
以前用 xp 的時候都自己重灌 , 也常常弄這些 , 真的好久沒弄啦

`右鍵` => `設定` => `新增硬體` => `SCSI 控制器` => `新增` => `硬碟` => `虛擬硬碟` => 
`新增` => `VHDX` => `動態擴充` => 名稱 `centos-disk.vhdx` => `20GB`
預設路徑會在 `C:\Users\Public\Documents\Hyper-V\Virtual Hard Disks\centos-disk.vhdx`

用 fdisk 看看內容
```
fdisk -l

#Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors               
#Units = sectors of 1 * 512 = 512 bytes                                    
#Sector size (logical/physical): 512 bytes / 4096 bytes                    
#I/O size (minimum/optimal): 4096 bytes / 4096 bytes                       
#                                                                          
#                                                                          
#Disk /dev/sda: 21.5 GB, 21474836480 bytes, 41943040 sectors               
#Units = sectors of 1 * 512 = 512 bytes                                    
#Sector size (logical/physical): 512 bytes / 4096 bytes                    
#I/O size (minimum/optimal): 4096 bytes / 4096 bytes                       
#Disk label type: dos                                                      
#Disk identifier: 0x000c7b4c                                               
#                                                                          
#   Device Boot      Start         End      Blocks   Id  System            
#/dev/sda1   *        2048     2099199     1048576   83  Linux             
#/dev/sda2         2099200    41943039    19921920   8e  Linux LVM         
#                                                                          
#Disk /dev/mapper/centos-root: 18.2 GB, 18249416704 bytes, 35643392 sectors
#Units = sectors of 1 * 512 = 512 bytes                                    
#Sector size (logical/physical): 512 bytes / 4096 bytes                    
#I/O size (minimum/optimal): 4096 bytes / 4096 bytes                       
#                                                                          
#                                                                          
#Disk /dev/mapper/centos-swap: 2147 MB, 2147483648 bytes, 4194304 sectors  
#Units = sectors of 1 * 512 = 512 bytes                                    
#Sector size (logical/physical): 512 bytes / 4096 bytes                    
#I/O size (minimum/optimal): 4096 bytes / 4096 bytes                       
```

因為剛剛掛上去的是 sdb , 可以用 m 看看 help 內容
```
sudo fdisk /dev/sdb

#Command (m for help): m
#Command action
#   a   toggle a bootable flag
#   b   edit bsd disklabel
#   c   toggle the dos compatibility flag
#   d   delete a partition
#   g   create a new empty GPT partition table
#   G   create an IRIX (SGI) partition table
#   l   list known partition types
#   m   print this menu
#   n   add a new partition
#   o   create a new empty DOS partition table
#   p   print the partition table
#   q   quit without saving changes
#   s   create a new empty Sun disklabel
#   t   change a partition's system id
#   u   change display/entry units
#   v   verify the partition table
#   w   write table to disk and exit
#   x   extra functionality (experts only)
```

蓋三個主分區兩個一般的一個 swap
接著選新增 n => 主分區 p => 然後選 1 => +2G
接著選新增 n => 主分區 p => 然後選 2 => +4G
接著選新增 n => 主分區 p => 然後選 3 => +1G => t => 3 => L => 82
```
Command (m for help): n
Partition type:
   p   primary (0 primary, 0 extended, 4 free)
   e   extended
Select (default p): p
Partition number (1-4, default 1): 1
First sector (2048-41943039, default 2048): 2048
Last sector, +sectors or +size{K,M,G} (2048-41943039, default 41943039): +2G
Partition 1 of type Linux and of size 2 GiB is set

Command (m for help): p

Disk /dev/sdb: 21.5 GB, 21474836480 bytes, 41943040 sectors
Units = sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 4096 bytes
I/O size (minimum/optimal): 4096 bytes / 4096 bytes
Disk label type: dos
Disk identifier: 0x750e0ecc

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1            2048     4196351     2097152   83  Linux
Command (m for help): n
Partition type:
   p   primary (1 primary, 0 extended, 3 free)
   e   extended
Select (default p): p
Partition number (2-4, default 2): 2
First sector (4196352-41943039, default 4196352):
Using default value 4196352
Last sector, +sectors or +size{K,M,G} (4196352-41943039, default 41943039): +4G
Partition 2 of type Linux and of size 4 GiB is set

Command (m for help): n
Partition type:
   p   primary (2 primary, 0 extended, 2 free)
   e   extended
Select (default p): p
Partition number (3,4, default 3): 3
First sector (12584960-41943039, default 12584960):
Using default value 12584960
Last sector, +sectors or +size{K,M,G} (12584960-41943039, default 41943039): +1G
Partition 3 of type Linux and of size 1 GiB is set

Command (m for help): m
Command action
   a   toggle a bootable flag
   b   edit bsd disklabel
   c   toggle the dos compatibility flag
   d   delete a partition
   g   create a new empty GPT partition table
   G   create an IRIX (SGI) partition table
   l   list known partition types
   m   print this menu
   n   add a new partition
   o   create a new empty DOS partition table
   p   print the partition table
   q   quit without saving changes
   s   create a new empty Sun disklabel
   t   change a partition's system id
   u   change display/entry units
   v   verify the partition table
   w   write table to disk and exit
   x   extra functionality (experts only)

Command (m for help): t
Partition number (1-3, default 3): 3
Hex code (type L to list all codes): L

 0  Empty           24  NEC DOS         81  Minix / old Lin bf  Solaris
 1  FAT12           27  Hidden NTFS Win 82  Linux swap / So c1  DRDOS/sec (FAT-
 2  XENIX root      39  Plan 9          83  Linux           c4  DRDOS/sec (FAT-
 3  XENIX usr       3c  PartitionMagic  84  OS/2 hidden C:  c6  DRDOS/sec (FAT-
 4  FAT16 <32M      40  Venix 80286     85  Linux extended  c7  Syrinx
 5  Extended        41  PPC PReP Boot   86  NTFS volume set da  Non-FS data
 6  FAT16           42  SFS             87  NTFS volume set db  CP/M / CTOS / .
 7  HPFS/NTFS/exFAT 4d  QNX4.x          88  Linux plaintext de  Dell Utility
 8  AIX             4e  QNX4.x 2nd part 8e  Linux LVM       df  BootIt
 9  AIX bootable    4f  QNX4.x 3rd part 93  Amoeba          e1  DOS access
 a  OS/2 Boot Manag 50  OnTrack DM      94  Amoeba BBT      e3  DOS R/O
 b  W95 FAT32       51  OnTrack DM6 Aux 9f  BSD/OS          e4  SpeedStor
 c  W95 FAT32 (LBA) 52  CP/M            a0  IBM Thinkpad hi eb  BeOS fs
 e  W95 FAT16 (LBA) 53  OnTrack DM6 Aux a5  FreeBSD         ee  GPT
 f  W95 Ext'd (LBA) 54  OnTrackDM6      a6  OpenBSD         ef  EFI (FAT-12/16/
10  OPUS            55  EZ-Drive        a7  NeXTSTEP        f0  Linux/PA-RISC b
11  Hidden FAT12    56  Golden Bow      a8  Darwin UFS      f1  SpeedStor
12  Compaq diagnost 5c  Priam Edisk     a9  NetBSD          f4  SpeedStor
14  Hidden FAT16 <3 61  SpeedStor       ab  Darwin boot     f2  DOS secondary
16  Hidden FAT16    63  GNU HURD or Sys af  HFS / HFS+      fb  VMware VMFS
17  Hidden HPFS/NTF 64  Novell Netware  b7  BSDI fs         fc  VMware VMKCORE
18  AST SmartSleep  65  Novell Netware  b8  BSDI swap       fd  Linux raid auto
1b  Hidden W95 FAT3 70  DiskSecure Mult bb  Boot Wizard hid fe  LANstep
1c  Hidden W95 FAT3 75  PC/IX           be  Solaris boot    ff  BBT
1e  Hidden W95 FAT1 80  Old Minix
Hex code (type L to list all codes): 82
Changed type of partition 'Linux' to 'Linux swap / Solaris'
```

接著蓋 extended
n => default => default => default
```
Command (m for help): n
Partition type:
   p   primary (3 primary, 0 extended, 1 free)
   e   extended
Select (default e): e
Selected partition 4
First sector (14682112-41943039, default 14682112):
Using default value 14682112
Last sector, +sectors or +size{K,M,G} (14682112-41943039, default 41943039):
Using default value 41943039
Partition 4 of type Extended and of size 13 GiB is set
```

接著嘗試蓋邏輯分區 , 記得 w 才會生效
```
Command (m for help): n
All primary partitions are in use
Adding logical partition 5
First sector (14684160-41943039, default 14684160):
Using default value 14684160
Last sector, +sectors or +size{K,M,G} (14684160-41943039, default 41943039): +1G
Partition 5 of type Linux and of size 1 GiB is set
```

w 以後看看有無成功
```
cat /proc/partitions

major minor  #blocks  name   
                             
   2        0          4 fd0 
   8       16   20971520 sdb 
   8       17    2097152 sdb1
   8       18    4194304 sdb2
   8       19    1048576 sdb3
   8       20          1 sdb4
   8       21    1048576 sdb5
   8        0   20971520 sda 
   8        1    1048576 sda1
   8        2   19921920 sda2
  11        0    1048575 sr0 
 253        0   17821696 dm-0
 253        1    2097152 dm-1
```

告訴系統 kernel 搞定了 , 強國人說看到 error 沒關係 , 真是無言..
```
partx -a /dev/sdb
#partx: /dev/sdb: error adding partitions 1-5
```

接著要用 mkfs , 然後用 blkid , (BL 小孩?) 看看是否搞定
這個 blkid 如果你沒用 sudo 的話是什麼都不會 show 出來 , 可見真的是搞 BL 的
```
sudo mkfs -t ext4 /dev/sdb1
sudo blkid /dev/sdb1

#最後 mount 上去
sudo mkdir -p /data/gg
sudo mount /dev/sdb1 /data/gg
```

### 一些實用或好用的 command
#### cat 有趣用法
無意看到可以用這樣 merge , 所以如果 k8s 寫 yaml 可以很快的合成一個一大坨的 config
```
echo "helloworld" > a
echo "bbb" > b
cat a b >> c

#顯示$號在結尾 , 顯示 ^I tab
cat -AT c
```

#### mkdir 有趣用法
只用一條命令生出複雜結構
```
mkdir -p A/{B/{D/,E/},C/}

├── A
│   ├── B
│   │   ├── D
│   │   └── E
│   └── C
```

#### tail 看 log
常常會遇到阿薩布魯的 log 要看 , 可以用 -f , 在 k8s 也是滿常見的類似用法
```
tail -10f xxx.log
tail -f xxx.log
```

#### cp 常見問題
如果文件不存在的 cp 方法
```
mkdir qq && cp test.txt "$_"
```

預設複製 link 是會直接複製到 link 指向的東東 , 所以要加上參數 `-p`
```
cp -P xxx
```

備份
```
cp /var/log/messages{,.bak}
```

#### eval 執行文件的 command
```
eval $(cat ls.txt)
```

#### sysctl 操作
列出目前所有的 sysctl 狀態
```
sysctl -a
```
修改狀態只要寫進 `sysctl.conf` 檔案即可 , 讓他禁止被 ping
```
vim /etc/sysctl.conf
net.ipv4.icmp_echo_ignore_all=1

#讓寫入生效
sysctl -p

```
或是使用強制 root echo 技巧 , 可以[參考這篇](https://notes.wadeism.net/linux/1954/)有把組合技巧都寫出來
```
cat /proc/sys/net/ipv4/icmp_echo_ignore_all
#這樣相當於 > 符號完全複寫如果用 tee -a 等於 >> 追加的意思
echo 1 | sudo tee /proc/sys/net/ipv4/icmp_echo_ignore_all
```

萬一遇到 `is not in the sudoers file. this incident will be reported.` 這個問題先把 user 加入可以 sudo 的列表
```
#切成 root
su -
vi /etc/sudoers
username ALL=(ALL)  ALL
```

#### 其他
補最後一個參數 `esc  .`
