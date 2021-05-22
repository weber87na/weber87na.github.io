---
title: docker 建立私有的 registry
date: 2021-05-12 19:25:03
tags: docker
---
&nbsp;
<!-- more -->

### 建立私有的 Registry
[官方 registry image](https://hub.docker.com/_/registry)
[比較流行的 UI](https://github.com/Joxit/docker-registry-ui)
[ui參考網址](https://www.cnblogs.com/huangxincheng/p/11131623.html)
[Registry API 文件](https://docs.docker.com/registry/spec/api/)

執行私有的 Registry
```
docker pull registry:2
docker container run -d -p 5000:5000 --name registry registry:2
```

測試私有 Registry 的 repository 目前有什麼 image 在上面
```
http://10.1.25.123:5000/v2/_catalog
http://10.1.25.124:5000/v2/_catalog
```

執行私有的 Registry UI
```
docker pull joxit/docker-registry-ui
docker container run -d -p 5050:80 --name docker-registry-ui joxit/docker-registry-ui
```


開啟 UI 後在右上角加入 registry 的 url http://10.1.25.123:5000 or http://localhost:5000/ , 之後會炸 CORS
解法因為 registry 需要開啟設定 , 所以需要建立 config.yml
注意萬一是用 `powershell` 則是使用 `${PWD}`
```
docker run -d -p 5000:5000 -v $(pwd)/registry/config.yml:/etc/docker/registry/config.yml  --name registry registry:2
```

加入 yml 在自己 user 目錄底下的 Registry 資料夾內
```
version: 0.1
log:
  fields:
    service: registry
storage:
  delete:
    enabled: true
  cache:
    blobdescriptor: inmemory
  filesystem:
    rootdirectory: /var/lib/registry
http:
  addr: :5000
  headers:
    X-Content-Type-Options: [nosniff]
    Access-Control-Allow-Origin: ['*']
    Access-Control-Allow-Methods: ['*']
    Access-Control-Allow-Headers: ['Authorization', 'Accept']
    Access-Control-Max-Age: [1728000]
    Access-Control-Allow-Credentials: [true]
    Access-Control-Expose-Headers: ['Docker-Content-Digest']
```

ubuntu 撈 docker container ip
```
docker container inspect --format '{{ .NetworkSettings.Networks.bridge.IPAddress }}' 7b2
```

遠端拉 debian 建立標籤最後推上自己的 registry
```
docker pull debian
docker tag debian debian:test
docker tag debian:test localhost:5000/debian:test
docker push localhost:5000/debian:test
```

承上 , 萬一是推到正式的 ip 會炸出這個 error `http: server gave HTTP response to HTTPS client`
```
docker pull debian
docker tag debian 10.1.25.123:5000/debian:mywheezy1
docker push 10.1.25.123:5000/debian:mywheezy1
```

[解法](https://stackoverflow.com/questions/42211380/add-insecure-registry-to-docker)
特別注意這個地方兩台主機都需要設定 client server , 不然 pull or push 一定炸
```
cd /etc/docker/
touch daemon.json
sudo service docker restart
#docker container run registry
docker run -d -p 5000:5000 -v $(pwd)/registry/config.yml:/etc/docker/registry/config.yml  --name registry registry:2
docker push 10.1.25.123:5000/debian:mywheezy1
```

daemon.json
```
{
    "insecure-registries" : [
		"10.1.25.123:5000" ,
		"10.1.25.124:5000"
	]
}
```


整個成功以後可以用 powershell 登入 ssh
登入到 124 接著拉下 123 的 debian image
```
ssh weberchang@10.1.25.124
docker pull 10.1.25.123:5000/debian:mywheezy1
```


其他 api 操作
```
#列出 tag list
curl http://localhost:5000/v2/xxxapi-image/tags/list

#xxxapi-image
curl http://localhost:5000/v2/xxxapi-image/manifests/latest

#刪除 image
Invoke-RestMethod -Method Delete -Uri "http://localhost:5000/v2/xxxapi-image/manifests/sha256:7f20c39a5575e862b6d2a81e627fe5e385a090845ae9096f3a7d8c299199dd6d"
```
