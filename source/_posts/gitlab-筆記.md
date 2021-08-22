---
title: gitlab 筆記
date: 2021-08-22 21:17:03
tags: gitlab
---

&nbsp;
<!-- more -->

### 安裝 gitlab
主要參考自[官網](https://docs.gitlab.com/ee/ci/docker/using_docker_build.html#use-the-docker-executor-with-the-docker-image-docker-in-docker)
這邊比較容易炸的錯誤應該是 22 port 被 ssh 佔領 , 所以要換成其他 port , 鐵人賽的書上換成 2222
`docker: Error response from daemon: driver failed programming external connectivity on endpoint gitlab (e62ea7a8d96361cf34cc8d14fe08f108f7700454583df1a19c3813197ca55792): Error starting userland proxy: listen tcp4 0.0.0.0:22: bind: address already in use`
因為這個 container 還有 postgresql , nginx , redis 等等阿薩布魯的東西 , 所以第一次跑起來很慢 , 會跳 502 要等等

```
docker run -d \
--hostname gggitlab \
-p 443:443 -p 80:80 -p 2222:22 \
--name gitlab \
--restart always \
--volume /srv/gitlab/config:/etc/gitlab \
--volume /srv/gitlab/logs:/var/log/gitlab \
--volume /srv/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ee:latest
```

接著跳進去裡面看看 , 並且找出 root 密碼 , 並且在 web 介面上 點選 `Edit Profile` => `Password` 修改密碼
我這邊用 g8 個來當密碼比較好記

root
gggggggg

```
docker exec -it gitlab /bin/bash
cat /etc/gitlab/initial_root_password

# WARNING: This value is valid only in the following conditions
#          1. If provided manually (either via `GITLAB_ROOT_PASSWORD` environment variable or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`, it was provided before database was seeded for th
e first time (usually, the first reconfigure run).
#          2. Password hasn't been changed manually, either via UI or via command line.
#
#          If the password shown here doesn't work, you must reset the admin password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

Password: okvCm2FXbQm07jfAG3VsBPbSbzVP2L1C88169Cpx5xM=
```

如果不想跳進去 container 內的話 , 因為一開始有 mount , 所以直接用下面指令就好
```
sudo cat /srv/gitlab/config/initial_root_password
```


接著設定 SSH , 讓 git 可以 clone or push , 執行 ssh-keygen 指令 , 看看要不要自己設定密碼 , 不然就一路 enter
最後會生出兩個檔案 `id_rsa`  `id_rsa.pub` , 其中 `id_rsa.pub` 等等要貼到 gitlab 上
```
cd ~/.ssh
ssh-keygen -t rsa
cat id_rsa.pub

#最後生出以下內容 , 等等這整串都要貼
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHNUE0ZxN4zXpVuM1YSjB2zWnn+OSTcT4JYQjxDSWdwwNNCI+S1RrTHU1hB5FAkKDXlYlIl20zRogrvZa+HcAGcYvZOkH9g3KazKxRf2ey8yfKhee+zygFo12EdYIEeLTTOP4M//coJrHm9ELbF+VlZoSB846lvt7IodhXmdY7Kx/62NetTMmFMR3qzAGLZk6sWcw4M+upoDu/arcqReJRltI7eXlSM2RgYi1xWrfRa0JDyfQ8zVRGM62zRZeZaR48002cWF8Nw8doNXkbLVOns1o0WVrQmnpirGXlpGBi1GEWfIwtBMhbMOIQKV/wLKXrO8v/BTZqG9JLeMlDsYFp5iBUAceX2yLR0UCoKZFS1JRdPBF8DcahG3k1R5zFCl6MCh8UL5cFETk1TzqWB8/Dmf6ztQHFhyGOVMHeBZkKSUBNsaTB3hQaebz6bdaip20r3pYW0Hz6mMwl3t5xuO8iyQ8XnOQTKgHhxrIQSQ+tTwVbZox2GzaTch93rRDO/Wk= vagrant@docker-lab
```

接著在 .ssh 資料夾底下加入 config , 如果懶得每次打 port 就直接在此設定防止自己犯下低能錯誤 , [參考老外](https://gist.github.com/nguyentamvinhlong/d3c9e15a687179a639704c21c5291f39)
注意最大重點因為預設 22 port 已經被佔用所有稍早有改成 2222 port
```
cd ~/.ssh
vim config

#Host gggitlab
#User git
#Port 2222
#Hostname gggitlab
#IdentityFile ~/.ssh/id_rsa
#TCPKeepAlive yes
#IdentitiesOnly yes
```

回到 gitlab 上面 , 選擇 `Edit profile` => `User settings` => `SSH key` 整個貼上 , 並且新增一個 gg 的 project
```
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDHNUE0ZxN4zXpVuM1YSjB2zWnn+OSTcT4JYQjxDSWdwwNNCI+S1RrTHU1hB5FAkKDXlYlIl20zRogrvZa+HcAGcYvZOkH9g3KazKxRf2ey8yfKhee+zygFo12EdYIEeLTTOP4M//coJrHm9ELbF+VlZoSB846lvt7IodhXmdY7Kx/62NetTMmFMR3qzAGLZk6sWcw4M+upoDu/arcqReJRltI7eXlSM2RgYi1xWrfRa0JDyfQ8zVRGM62zRZeZaR48002cWF8Nw8doNXkbLVOns1o0WVrQmnpirGXlpGBi1GEWfIwtBMhbMOIQKV/wLKXrO8v/BTZqG9JLeMlDsYFp5iBUAceX2yLR0UCoKZFS1JRdPBF8DcahG3k1R5zFCl6MCh8UL5cFETk1TzqWB8/Dmf6ztQHFhyGOVMHeBZkKSUBNsaTB3hQaebz6bdaip20r3pYW0Hz6mMwl3t5xuO8iyQ8XnOQTKgHhxrIQSQ+tTwVbZox2GzaTch93rRDO/Wk= vagrant@docker-lab
```

稍早因為設定 gggitlab 當作 gitlab 的網址 , 所以要在 etc/hosts 內加上去 , 不然 git 會認不得
```
sudo vim /etc/hosts

#補上這句
#192.168.137.219 gggitlab
```

接著用 ssh 測看看 , 正常的話會輸出以下這樣
```
ssh -T git@gggitlab
#Welcome to GitLab, @root!
```

最後用 git push 看看
```
cd ~
mkdir gg
cd ~/gg
git init
git remote add origin git@gggitlab:root/gg.git
echo helloworld >> helloworld
git add .
git commit -m "helloworld"
git push --set-upstream origin master

#會要你打 yes
#The authenticity of host '[gggitlab]:2222 ([192.168.137.219]:2222)' can't be established.
#ECDSA key fingerprint is SHA256:7h1cEZ6e6DhY0xZgea0987zE/4hYfXla/iWLbTsZGF8.
#Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
#Warning: Permanently added '[gggitlab]:2222,[192.168.137.219]:2222' (ECDSA) to the list of known hosts.
```



### 安裝 gitlab-runner
接著我們安裝並且註冊 gitlab-runner
```
docker run -d --name gitlab-runner \
--restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
gitlab/gitlab-runner:latest
```


### 註冊 config
我比較喜歡跳進去 container 內執行指令
先打看看應該是吃不到網址 gggitlab , 所以追加到 /etc/hosts 內 (這步沒做也可以)
執行註冊前先去 webui 上取得 url 及 token
http://gggitlab/admin/runners

http://gggitlab
8bmeuSp1z9nLQvzwyx8t

此外之後會跑 docker in docker 所以必須要在 container 內的 container 設定參數 registry 就是做這檔事
最重要的就是 `docker-volumes` 及 `docker-extra-hosts` , 沒補這些的話 dind 是不會認得正確的 ip 位置的
此外目前只要測試先用 `run-untagged` 即可他還有 `tag-list` 參數正式的話應該是要加比較優 , 這邊先玩看看就不理他
```
docker exec -it gitlab-runner /bin/bash
echo "192.168.137.219 gggitlab" >> /etc/hosts
curl http://gggitlab
#<html><body>You are being <a href="http://gggitlab/users/sign_in">redirected</a>.</body></html>

#註冊
gitlab-runner register -n \
  --url http://192.168.137.219 \
  --registration-token 8bmeuSp1z9nLQvzwyx8t \
  --executor docker \
  --description "My Docker Runner" \
  --docker-image "docker:19.03.12" \
  --docker-privileged \
  --docker-volumes "/var/run/docker.sock:/var/run/docker.sock" \
  --docker-extra-hosts "gggitlab:192.168.137.219" \
  --run-untagged
```

如果 dind 對外撈不到東西可以加 dns 在 host 的 docker 看看 , 我是沒加就可以過了
```
sudo vim /etc/docker/daemon.json

{
	"dns":["172.17.0.1" , "8.8.8.8"]
}
```

回到 host 上 cat 看看
```
sudo  cat /srv/gitlab-runner/config/config.toml

concurrent = 1
check_interval = 0

[session_server]
  session_timeout = 1800

[[runners]]
  name = "My Docker Runner"
  url = "http://192.168.137.219"
  token = "nciB6tUJtAzMzUs9Ffhs"
  executor = "docker"
  [runners.custom_build_dir]
  [runners.cache]
    [runners.cache.s3]
    [runners.cache.gcs]
    [runners.cache.azure]
  [runners.docker]
    tls_verify = false
    image = "docker:19.03.12"
    privileged = true
    disable_entrypoint_overwrite = false
    oom_kill_disable = false
    disable_cache = false
    #volumes = ["/certs/client", "/cache"]
    volumes = ["/cache", "/var/run/docker.sock:/var/run/docker.sock"]
    shm_size = 0
    extra_hosts = ["gggitlab:192.168.137.219"]
```

這邊在稍早我們的 gg project pipeline `CI/CD` => `Editor` 內加入以下設定

gitlab-ci.yml
```
image: docker:stable

services:
    - docker:dind

build:
    stage: build
    script:
        - docker run hello-world
```

如果都有設定成功的話執行 docker images 會長這樣
```
REPOSITORY                                                          TAG               IMAGE ID       CREATED          SIZE
registry.gitlab.com/gitlab-org/gitlab-runner/gitlab-runner-helper   x86_64-8925d9a0   ce5fee60525e   52 minutes ago   72MB
gitlab/gitlab-ee                                                    latest            c5b017ad7f7a   2 days ago       2.4GB
docker                                                              dind              ede8a8017c85   2 weeks ago      231MB
gitlab/gitlab-runner                                                latest            7f83dee88242   4 weeks ago      1.9GB
hello-world                                                         latest            d1165f221234   5 months ago     13.3kB
docker                                                              stable            b0757c55a1fd   8 months ago     220MB
```

如果你執行 pipeline 的時候會從 host 上面看到兩個奇怪的 container 在跑
```
CONTAINER ID   IMAGE                         COMMAND                  CREATED         STATUS                    PORTS
               NAMES
a7f82ace1b52   213df41cd892                  "/usr/bin/dumb-init …"   1 second ago    Up Less than a second
               runner-xwjhepae-project-2-concurrent-0-96b3efa40d914cd2-docker-0-wait-for-service
51b8fb27c636   ede8a8017c85                  "dockerd-entrypoint.…"   1 second ago    Up Less than a second     2375-2376/tcp
               runner-xwjhepae-project-2-concurrent-0-96b3efa40d914cd2-docker-0
7bccda72335b   gitlab/gitlab-runner:latest   "/usr/bin/dumb-init …"   9 minutes ago   Up 9 minutes
               gitlab-runner
82dc60e7b052   gitlab/gitlab-ee:latest       "/assets/wrapper"        5 hours ago     Up 28 minutes (healthy)   0.0.0.0:80->80/tcp, :::80->80/tcp, 0.0.0.0:443->443/tcp, :::443->443/tcp, 0.0.0.0:2222->22/tcp, :::
2222->22/tcp   gitlab
```
