---
title: putty 操作筆記
date: 2024-03-20 20:07:16
tags: linux
---
&nbsp;
<!-- more -->

工作上遇到的問題 , 800 萬年沒用 Putty 筆記下
可以參考[這裡](https://www.techtarget.com/searchsecurity/tutorial/How-to-use-PuTTY-for-SSH-key-based-authentication)
先用 PuttyGen 產生公鑰 , 然後複製整行的公鑰
然後記得要保存私鑰
在 linux 底下建立 `~/.ssh/authorized_keys`
```
vim ~/.ssh/authorized_keys
#你的公鑰
ssh-rsa AAAAB3Nzaxxxxxxxxxxxxxxxxx
```
然後在 Putty 的 `Session` => `Host Name(or IP address)` 敲入 ip
`Connection` => `Data` => `Auto-login username` 敲入帳號
`SSH` => `Auth` => Credentials` => `Private key file for authentication` => `Browse` 放上你的 `ppk`
基本上就能登入了

我自己習慣用 windows 的 ssh 來操作 , 不愛 Putty , 參考[這篇](https://shivrajan.medium.com/how-to-convert-ppk-to-pem-file-using-command-bb7270945602)
一樣用 PuttyGen 來轉換
`File` => `Load Private Key`
`Conversions` => `Export OpenSSH Key` 保存成你要的名稱

```
ssh -i server1.pem ubuntu@your-server-ip
```

