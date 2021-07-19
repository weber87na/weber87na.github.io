---
title: Harbar 建立私有 docker registry
date: 2021-06-29 02:49:47
tags:
- docker
- k8s
---
&nbsp;
<!-- more -->

### Harbor 安裝

[參考強國人](https://ivanzz1001.github.io/records/post/docker/2018/04/09/docker-harbor-https)
或是另一個強國人(https://www.cnblogs.com/ExMan/p/11996944.html)
```
wget https://github.com/goharbor/harbor/releases/download/v2.3.0/harbor-offline-installer-v2.3.0.tgz
tar -xvf harbor-offline-installer-v2.3.0.tgz
cd harbor
cp harbor.yml.tmpl harbor.yml
vim harbor.yml

#把 https 註解掉
#並且把 hostname 直接換成機器的 ip
hostname: 10.1.25.123

 # https related config
 #https:
   # https port for harbor, default is 443
   #port: 443
   # The path of cert and key files for nginx
   #certificate: /your/certificate/path
   #private_key: /your/private/key/path

./prepare --with-trivy --with-chartmuseum
docker-compose up -d
```

注意! 萬一之前有安裝 registry 先把他停掉或是移除 , 不然會起不來
```
docker container ls -a
docker container rm ec1fadeecc80 5b5dfc3e0a31
```

到此可以先看一下結果在 chrome 輸入 `10.1.25.123` 即可進入 Harbor 畫面
預設登入的帳號密碼為 `admin` `Harbor12345` 注意 H 是大寫
建立一個名稱為 test 私有的專案

接著確保 server 上 docker 的 `daemon.json` 屬性 `insecure-registries` 有正確 ip 加入 , 因為先前設定 harbor.yml 使用的是 80 , 此處要設定 80
另外 client 的 docker insecure-registries 也要加入正確的 ip 地址
詳細說明可以看[官網](https://docs.docker.com/registry/insecure/)

windows `C:\ProgramData\docker\config\daemon.json`
linux `/etc/docker/daemon.json`

```
cat /etc/docker/daemon.json
{
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts":{
                "max-size": "100m"
        },
        "storage-driver": "overlay2",
        "insecure-registries":[
                "10.1.25.123"
        ]
}
```

注意 修改後需要 restart docker , 並且要再次開啟 harbor
```
sudo service docker restart
sudo docker-compose up -d
```

最後開一個新的 powershell or bash 測試用 client 登入私有的 registry 應該可以看到 `Login Succeeded`
```
docker login http://10.1.25.123 --username admin --password Harbor12345
```
若失敗則會看到記得檢查看看是否為 `insecure-registries` 設定錯誤 , `注意! 如果是在 k8s 整合上的話每個 node 都需要設定`
```
Error response from daemon: Get https://10.1.25.123/v2/: dial tcp 10.1.25.123:443: connect: connection refused
```

打標籤在這個 image 上 , 並且 push
```
docker tag nginx:latest 10.1.25.123/test/nginx:latest
docker push 10.1.25.123/test/nginx:latest
```

### k8s 整合
詳細說明可參考[官網](https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/)
看網路上指定檔案都用這樣 `~/.docker/config.json` , 但是會炸 Error , 不曉得為啥 , 所以改成 $HOME 騙看看才過
```
kubectl create secret generic regcred --from-file=.dockerconfigjson=$HOME/.docker/config.json --type=kubernetes.io/dockerconfigjson
```

或是直接用這樣應該都會建立出一樣的結果
```
kubectl create secret docker-registry regcred --docker-server=10.1.25.123  \
--docker-username=admin \
--docker-password=Harbor12345
```

接著印出 secret regcred 看看
```
kubectl get secret regcred --output=yaml
```

會長這樣
```
apiVersion: v1
data:
  .dockerconfigjson: ewoJImF1dGhzIjogewoJCSIxMC4xLjMxxx...
kind: Secret
metadata:
  creationTimestamp: "2021-06-20T07:23:34Z"
  name: regcred
  namespace: default
  resourceVersion: "3050890"
  uid: 9b48e55e-89dc-4b61-b9ee-749cc47d9ae9
type: kubernetes.io/dockerconfigjson
```

最後建立 `Pod` 看看
```
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
spec:
  containers:
  - name: private-reg-container
    image: 10.1.25.123/test/nginx:latest
  imagePullSecrets:
  - name: regcred
```

### k8s 整合 .net core
可以參考[這篇強國人](https://www.cnblogs.com/sheng-jie/p/10591794.html)

#### Pod 起手式
新增 `HelloWorldController`
```
    [Route( "api/[controller]" )]
    [ApiController]
    public class HelloWorldController : ControllerBase
    {
        [HttpGet]
        public string Get()
        {
            string result = "";
            string HostName = Dns.GetHostName();
            Console.WriteLine( "Host Name of machine =" + HostName );
            result += "Host Name of machine =" + HostName + Environment.NewLine;
            IPAddress[] ipaddress = Dns.GetHostAddresses( HostName );
            Console.Write( "IPv4 of Machine is " );
            result += "IPv4 of Machine is " + Environment.NewLine;
            foreach (IPAddress ip4 in ipaddress.Where( ip => ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork ))
            {
                Console.WriteLine( ip4.ToString() );
                result += ip4.ToString() + Environment.NewLine;
            }
            Console.Write( "IPv6 of Machine is " );
            result += "IPv6 of Machine is " + Environment.NewLine;
            foreach (IPAddress ip6 in ipaddress.Where( ip => ip.AddressFamily == System.Net.Sockets.AddressFamily.InterNetworkV6 ))
            {
                Console.WriteLine( ip6.ToString() );
                result += ip6.ToString() + Environment.NewLine;
            }
            return result;
        }
    }

```


特別注意 `Startup` 內的 `Configure` 方法 , 需要把 UseHttpsRedirection 註解掉 , 不然會導向錯誤的網址
```
//app.UseHttpsRedirection();
```


新增 `DockerFile` 並且把檔案設定為 `Always Copy`
設定暴露的 PORT , 注意這個 `ENV ASPNETCORE_URLS=http://+:80;https://+:443` 一定要設定 , 不然會找不到位置
```
FROM mcr.microsoft.com/dotnet/sdk:5.0 AS build
WORKDIR /app
COPY . .
ENV ASPNETCORE_URLS=http://+:80;https://+:443
EXPOSE 80

EXPOSE 443
ENTRYPOINT ["dotnet", "HelloWorldKubernetes.dll"]
```

切換到 bin\Debug 目錄底下進行編譯 , 用 docker 跑看看結果是否正確
```
docker build -t helloworldk8s .
docker run --name helloworldk8s -d -p 5000:80 -p 5001:443  helloworldk8s:latest
```

先用以下命令查看看有無正確啟動 container 萬一沒啟動加上 `-a` 參數看看發生啥錯誤
```
docker container ls

docker container ls -a
```

開啟 chrome 測試
`https://localhost:5001/api/helloworld`
`http://localhost:5000/api/helloworld`

打標籤到自己私有的 Harbor Registry 並且推送上去
```
docker tag helloworldk8s:latest 10.1.25.123/test/helloworldk8s:latest
docker push 10.1.25.123/test/helloworldk8s:latest
```

在 master 節點 pull image
```
docker pull 10.1.25.123/test/helloworldk8s:latest
docker images
#REPOSITORY                           TAG            IMAGE ID       CREATED          SIZE
#10.1.25.123/test/helloworldk8s       latest         8d030c225a2a   18 minutes ago   635MB
```

建立 yaml 檔 , 可以參考[微軟這篇]來編(https://docs.microsoft.com/en-us/dotnet/architecture/containerized-lifecycle/design-develop-containerized-apps/build-aspnet-core-applications-linux-containers-aks-kubernetes)
```
vim private-reg-pod.yaml
kubectl apply -f private-reg-pod.yaml
```

`private-reg-pod.yaml` 內容如下
```
apiVersion: v1
kind: Pod
metadata:
  name: private-reg
  labels:
	app: private-reg
spec:
  containers:
  - name: private-reg-container
    image: 10.1.25.123/test/helloworldk8s:latest
    ports:
      - containerPort: 80
        protocol: TCP
    env:
      - name: ASPNETCORE_URLS
        value: http://+:80
  imagePullSecrets:
  - name: regcred
```


查詢目前 pod
```
kubectl get po
#NAME          READY   STATUS    RESTARTS   AGE     IP            NODE
#private-reg   1/1     Running   0          5m45s   10.244.1.87   node02
```

萬一有問題 可以用 `describe` 除錯
```
kubectl describe po private-reg

#正常的話會像是下面這樣
#Events:
#  Type    Reason     Age   From               Message
#  ----    ------     ----  ----               -------
#  Normal  Scheduled  20s   default-scheduler  Successfully assigned default/private-reg to node02
#  Normal  Pulling    19s   kubelet            Pulling image "10.1.25.123/test/helloworldk8s:latet"
#  Normal  Pulled     2s    kubelet            Successfully pulled image "10.1.25.123/test/helloworldk8s:latest" in 17.048779767s
#  Normal  Created    1s    kubelet            Created container private-reg-container
#  Normal  Started    1s    kubelet            Started container private-reg-container
```

也可以跳進去 node 裡面看看 docker 狀況
```
docker container ls
#CONTAINER ID   IMAGE                            COMMAND                  CREATED          STATUS          PORTS     NAMES
#ae35c6069640   10.1.25.123/test/helloworldk8s   "dotnet HelloWorldKu…"   23 minutes ago   Up 23 minutes             k8s_private...
```


接著可以在 master 用 curl 測試
```
curl 10.244.1.87/api/helloworld
```

或是跳入 node 測試 , 這個兩槓符號 `--` 表示結尾 , 後面接 linux 命令 , 因為 dotnet core 的預設 shell 是用 bash , 所以寫 /bin/bash , 其他容器有可能只有 sh
```
kubectl exec -it private-reg -- /bin/bash

#跳進去後會長這樣 , 接著執行 curl 測看看
root@private-reg:/app# curl localhost/api/helloworld
```

還可以用簡單粗暴的 k8s port-forward 在 master 來測看看
```
curl localhost:8087/api/helloworld
```

或是直接用 NodePort
```
kubectl expose pod private-reg --name private-reg --type=NodePort
```

#### Deployment Lab
將 `Pod` 改成佈署 `Deployment` , 有的書上或是資料會寫用 `ReplicaSet` , 實際運用上會直接使用 `Deployment` 讓他進行自動調度
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  replicas: 4
  selector:
    matchLabels:
      app: asp-net-core-helloworld-k8s
  template:
    metadata:
      labels:
        app: asp-net-core-helloworld-k8s
    spec:
      containers:
      - name: asp-net-core-helloworld-k8s
        image: 10.1.25.123/test/helloworldk8s:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
        - containerPort: 443
        env:
        - name: ASPNETCORE_URLS
          value: http://+:80;https://+:443
        - name: ASPNETCORE_ENVIRONMENT
          value: Development
      imagePullSecrets:
      - name: regcred
```

本來沒睡飽少設定 `ASPNETCORE_ENVIRONMENT` , 測試的時候發現 swagger 一直打不開 , 超無言
特別注意到 , 因為 asp.net core 預設是只有 `IsDevelopment` 才會開啟 , 所以需要加入 `ASPNETCORE_ENVIRONMENT` 區塊
可以看[ASP.NET CORE in Action 作者的文章有說明](https://andrewlock.net/deploying-asp-net-core-applications-to-kubernetes-part-5-setting-environment-variables-in-a-helm-chart/)
```
public void Configure( IApplicationBuilder app, IWebHostEnvironment env )
{
	if (env.IsDevelopment())
	{
		app.UseDeveloperExceptionPage();
		app.UseSwagger();
		app.UseSwaggerUI( c => c.SwaggerEndpoint( "/swagger/v1/swagger.json", "HelloWorldKubernetes v1" ) );
	}

	//.....
}
```

執行佈署 `asp-net-core-helloworld-k8s.yaml`
```
k apply -f asp-net-core-helloworld-k8s.yaml
```

用之前安裝的 `tree` 查看看 `Deployment` 的階層關係 , 可以發現其實後面有 `ReplicaSet`
```
k tree deployment asp-net-core-helloworld-k8s
NAMESPACE  NAME                                                    READY  REASON  AGE
default    Deployment/asp-net-core-helloworld-k8s                  -              3h42m
default    ├─ReplicaSet/asp-net-core-helloworld-k8s-66f969cb87   -              3h42m
default    └─ReplicaSet/asp-net-core-helloworld-k8s-7ff974f489   -              46m
default      ├─Pod/asp-net-core-helloworld-k8s-7ff974f489-bcj86  True           46m
default      ├─Pod/asp-net-core-helloworld-k8s-7ff974f489-fnntp  True           46m
default      ├─Pod/asp-net-core-helloworld-k8s-7ff974f489-j9s6s  True           46m
default      └─Pod/asp-net-core-helloworld-k8s-7ff974f489-l9j5f  True           46m
```

查看看 ReplicaSet 縮寫為 rs , 可以用 `k api-resources` 來查詢縮寫
```
k get rs
#NAME                                     DESIRED   CURRENT   READY   AGE
#asp-net-core-helloworld-k8s-66f969cb87   0         0         0       3h52m
#asp-net-core-helloworld-k8s-7ff974f489   4         4         4       56m
```

查目前 pods
```
k get po -o wide

#NAME                                           READY   STATUS    RESTARTS   AGE     IP             NODE
#asp-net-core-helloworld-k8s-67cb6f48cd-6xxd7   1/1     Running   0          101s    10.244.1.99    node02
#asp-net-core-helloworld-k8s-67cb6f48cd-nlhlw   1/1     Running   0          101s    10.244.1.100   node02
```

在 cluster 內用 curl 呼叫看看是否成功 , 這邊還有個 debug 的好法子就是加上 `--dump-header -` 這樣可以看到 header 更好 debug
```
curl 10.244.1.99:80/api/helloworld
curl 10.244.1.100:80/api/helloworld

#測個沒結果的
curl --dump-header - http://10.244.1.112:80
HTTP/1.1 404 Not Found
Date: Wed, 30 Jun 2021 07:35:31 GMT
Server: Kestrel
Content-Length: 0
```

查 deployment 也可以用 deploy 等價縮寫
```
k get deployments
k get deploy
#NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
#asp-net-core-helloworld-k8s   2/2     2            2           3m49s
```

暴露成 service `NodePort`
在 k8s 內 `ClusterIP` 為內部通信而 `NodePort` 為暴露給外部可以進行訪問
```
k expose deployment asp-net-core-helloworld-k8s --name asp-net-core-helloworld-k8s --type=NodePort
```

最後查看看結果 , 可以看到 cluster 內部訪問是 10.96.165.130 , 而外部則使用 master 機器的 ip 加上 31956

http `http://10.1.25.123:31956`
https `https://10.1.25.123:32418`

```
k get svc
#NAME                          TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
#asp-net-core-helloworld-k8s   NodePort       10.96.165.130    <none>        80:31956/TCP,443:32418/TCP   3h4m
```

萬一想刪除則使用以下命令
```
k delete deployments asp-net-core-helloworld-k8s
k delete service asp-net-core-helloworld-k8s
```

#### HPA Lab

嘗試做做 HPA 的 lab , 看書上寫的含糊 , 東西一直沒起來 , 查了下才發現要安裝 `Metric-Server`
```
k describe hpa asp-net-core-helloworld-k8s
#
#Type     Reason                        Age                From                       Message
#----     ------                        ----               ----                       -------
#Warning  FailedGetResourceMetric       1s (x8 over 107s)  horizontal-pod-autoscaler  failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
#Warning  FailedComputeMetricsReplicas  1s (x8 over 107s)  horizontal-pod-autoscaler  invalid metrics (1 invalid out of 1), first error is: failed to get cpu utilization: unable to get metrics for resource cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource (get pods.metrics.k8s.io)
```

安裝可以參考這個[官方文件](https://github.com/kubernetes-sigs/metrics-server)
直接照著文件做還是會陣亡 , 要特別注意 `Requirements` 這段寫的內容 , 我的問題是要加上 `kubelet-insecure-tls`
```
#Requirements 完全沒問題的話官方作法
#kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

#我的作法
wget https://github.com/kubernetes-sigs/metrics-server/releases/download/v0.5.0/components.yaml
vim components.yaml
#找到 Deployment 加入 kubelet-insecure-tls 參數
#spec:
#  containers:
#  - args:
#	- --cert-dir=/tmp
#	- --secure-port=443
#	- --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
#	- --kubelet-use-node-status-port
#	- --metric-resolution=15s
#	- --kubelet-insecure-tls
#	image: k8s.gcr.io/metrics-server/metrics-server:v0.5.0


#驗證是否成功
k get po,deployment -n kube-system
```

安裝好以後可以調整 `Deployment` 的 `resources` 區塊來限定資源使用 , 注意使用 `HorizontalPodAutoscaler` 前需要先定義 `Deployment`
詳細說明可以看這個[官網文件](https://kubernetes.io/zh/docs/tasks/run-application/horizontal-pod-autoscale/)

asp-net-core-helloworld-k8s.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: asp-net-core-helloworld-k8s
  template:
    metadata:
      labels:
        app: asp-net-core-helloworld-k8s
    spec:
      containers:
      - name: asp-net-core-helloworld-k8s
        image: 10.1.25.123/test/helloworldk8s:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
        - containerPort: 443
        env:
        - name: ASPNETCORE_URLS
          value: http://+:80;https://+:443
        - name: ASPNETCORE_ENVIRONMENT
          value: Development
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
      imagePullSecrets:
      - name: regcred
```

asp-net-core-helloworld-k8s-hpa.yaml
限制 50% cpu 使用率
```
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: asp-net-core-helloworld-k8s
  minReplicas: 1
  maxReplicas: 10
  targetCPUUtilizationPercentage: 50
```

最後是佈署 HPA
```
k apply -f asp-net-core-helloworld-k8s.yaml
k apply -f asp-net-core-helloworld-k8s-hpa.yaml
```

安裝 apache ab , 因為預設會有限制 , 這邊把限制解開 , 接著模擬多人 request 我們的 api
```
#萬一是被拔光的 ubuntu 才安裝以下命令
#apt upgrade
#apt update
#apt list --upgradable
#apt-get install iputils-ping
#apt-get install -y net-tools

#普通 ubuntu 應該直接可以安裝 ab
sudo apt-get install apache2-utils
ulimit -a
ulimit -n 204800

#查目前 ClusterIP
k get svc
#NAME                          TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
#asp-net-core-helloworld-k8s   NodePort       10.96.165.130    <none>        80:31956/TCP,443:32418/TCP   7d2h

#測試模擬多人同時 request  , 注意這邊不管是打 cluster-id 或是用對外的 port 都可以達到同樣效果
ab -r -c 2000 -n 204800 http://10.96.165.130/api/helloworld

#懶得安裝 ab 的話直接用 curl + while 也可以測
while true; do curl http://10.96.165.130/api/helloworld; done
```


查看 HPA 是否有生效 , 注意這邊 TARGETS 超過了總使用量 50% , REPLICAS 也擴充到 10 個 , 至此就完成了整個自動擴容
最後等到 ab 把 request 打完以後 , 會自動縮容預設時間是 5 分鐘 , 要調整的話參數為 `--horizontal-pod-autoscaler-downscale-stabilization`
```
#查 hpa
k get hpa
#NAME                          REFERENCE                                TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
#asp-net-core-helloworld-k8s   Deployment/asp-net-core-helloworld-k8s   146%/50%   1         10        10         78m

#查 pod
k get po

#也可以用 sql plugin 的方式撈
#k sql get po where "name like '%asp%'"

#NAME                                           READY   STATUS             RESTARTS   AGE
#asp-net-core-helloworld-k8s-5766cd7cc5-4x452   1/1     Running            0          92s
#asp-net-core-helloworld-k8s-5766cd7cc5-8kxw6   1/1     Running            0          107s
#asp-net-core-helloworld-k8s-5766cd7cc5-gtcn9   1/1     Running            0          62s
#asp-net-core-helloworld-k8s-5766cd7cc5-js4sj   1/1     Running            0          79m
#asp-net-core-helloworld-k8s-5766cd7cc5-lw4b2   1/1     Running            0          62s
#asp-net-core-helloworld-k8s-5766cd7cc5-m4stc   1/1     Running            0          62s
#asp-net-core-helloworld-k8s-5766cd7cc5-mpblz   1/1     Running            0          107s
#asp-net-core-helloworld-k8s-5766cd7cc5-rlnhs   1/1     Running            0          107s
#asp-net-core-helloworld-k8s-5766cd7cc5-v6m2x   1/1     Running            0          62s
#asp-net-core-helloworld-k8s-5766cd7cc5-zcptc   1/1     Running            0          62s
```

#### 設定 dns
網路部分除了設定 hosts 之外還有 dnsPolicy 可以設定 , 分別為 `Default` , `ClusterFirst` , `ClusterFirstWithHostNet` , `None`
因為在內網裡有自己的 dns server 以我環境使用 ubuntu 為例 , 查詢看看目前用啥 dns ip
```
#應以 netplan 內的為準
cat /etc/netplan/00-network-manager-all.yaml
cat /run/systemd/resolve/resolv.conf
cat /etc/resolv.conf
```

接著設定正確的 dns
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: asp-net-core-helloworld-k8s
  template:
    metadata:
      labels:
        app: asp-net-core-helloworld-k8s
    spec:
      containers:
      - name: asp-net-core-helloworld-k8s
        image: 10.1.25.123/test/asp-net-core-helloworld-k8s:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 80
      dnsPolicy: ClusterFirstWithHostNet
      dnsConfig:
        nameservers:
          - 10.1.25.7
        searches:
          - xxx.com.tw
      imagePullSecrets:
      - name: regcred
```

最後跳進去看看 , 可以看到 k8s 多把 dns 補進去了 , 原本只有 10.96.0.10 這個 nameserver , 跟這串 search default.svc.cluster.local svc.cluster.local cluster.local
現在多補進了之前我們在 deployment 內設定的區塊 
```
k exec -it asp-net-core-helloworld-k8s-7cfc8db5f6-bk2j8 -- sh
cat /etc/resolv.conf

#nameserver 10.96.0.10
#nameserver 10.1.25.7
#search default.svc.cluster.local svc.cluster.local cluster.local xxx.com.tw
#options ndots:5
```
最後可以參考[這篇佛心老外](https://gist.github.com/superseb/f6894ddbf23af8e804ed3fe44dd48457)有其他解法


#### hosts 設定
除了 dns 以外可能會想要在自己的 container 內使用 hosts , k8s 有 hostalias 這個東東可以使用
先查自己有啥 hosts 需要補
linux `/etc/hosts`
windows `C:\Windows\System32\drivers\etc\hosts`

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: asp-net-core-helloworld-k8s
  template:
    metadata:
      labels:
        app: asp-net-core-helloworld-k8s
    spec:
      containers:
      - name: asp-net-core-helloworld-k8s
        image: 10.1.25.123/test/asp-net-core-helloworld:latest
        imagePullPolicy: Always
        ports:
        - containerPort: 8080
      hostAliases:
      - ip: "10.1.17.46"
        hostnames:
        - "ggyy.com.tw"
      imagePullSecrets:
      - name: regcred
```

#### liveness 探針
接著來設定 liveness 探針 , 修改 Deployment , 固定每 10 秒戳一次看看有沒有活 , 啟動時給他個緩衝時間 5 秒 , 若回應不是 200 liveness 會重新啟動 Pod
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  replicas: 1
  selector:
    matchLabels:
      app: asp-net-core-helloworld-k8s
  template:
    metadata:
      labels:
        app: asp-net-core-helloworld-k8s
    spec:
      containers:
      - name: asp-net-core-helloworld-k8s
        image: 10.1.25.123/test/asp-net-core-helloworld-k8s:latest
        imagePullPolicy: Always
        livenessProbe:
          httpGet:
            path: '/health'
            port: 5000
            scheme: HTTP
          initialDelaySeconds: 5
          periodSeconds: 10
        ports:
        - containerPort: 5000
        resources:
          limits:
            cpu: 500m
          requests:
            cpu: 200m
      hostAliases:
      - ip: "10.1.3.5"
        hostnames:
        - "xxooxx"
      imagePullSecrets:
      - name: regcred
```

先在程式碼裡面有插上這段 , 測試可以用 `curl 10.244.1.29:5000/health` 去戳他 , 現在每 10 秒 k8s 會自己去戳 , 正常狀況會給 `Healthy` 細部可以在自己依情境調整
```
public void Configure(IApplicationBuilder app,
	IWebHostEnvironment env)
{
	//... 略
	app.UseEndpoints( endpoints =>
	 {
		 endpoints.MapControllers();
		 endpoints.MapHealthChecks( "/health" );
	 } );

}
```

為了驗證是否有生效可以故意把路徑寫錯 , 改成 gg
```
livenessProbe:
  httpGet:
	path: '/gg'
	port: 5000
	scheme: HTTP
  initialDelaySeconds: 5
  periodSeconds: 10
```

接著 get po 看看會不會 restart
```
k get po -o wide
NAME                                           READY   STATUS         RESTARTS   AGE     IP             NODE              NOMINATED NODE   READINESS GATES
asp-net-core-helloworld-k8s-5d44fff86-4pbbw                    1/1     Running        0          24s     10.244.1.221   node02   <none>           <none>
asp-net-core-helloworld-k8s-5d44fff86-kwd6w                    1/1     Running        0          24s     10.244.1.222   node02   <none>           <none>
asp-net-core-helloworld-k8s-5d44fff86-lkr6b                    1/1     Running        4          2m26s   10.244.1.220   node02   <none>           <none>
```

nlog 設定要注意的問題事項 , 先跳進去 pod 內看看 , 發現居然有 D: 這個資料夾
原來之前有設定 nlog 寫入 log 會放在 D:/Log/${shortdate}_Now.log , 在 k8s 設定時需要特別注意一下
```
k exec -it asp-net-core-helloworld-k8s-7c9b78d948-j7mq9 -- /bin/bash
ls
#BouncyCastle.Crypto.dll                         Microsoft.EntityFrameworkCore.dll                    NLog.MailKit.dll                                 System.IdentityModel.Tokens.Jwt.dll
#D:                                              Microsoft.Extensions.DependencyInjection.dll         NLog.Web.AspNetCore.dll                          System.Runtime.Caching.dll
#...略
```

#### Cronjob Lab
有時候我們可能希望定時做些任務接著回報給自己 , 可能用 line or mail , 這邊用 curl 去定時打一個 api 接著串 mail 來進行測試 cronjob , 這裡有好用的 [crontab](https://crontab.guru/)工具方便 debug
另外要注意自己的檔案是什麼權限 , 可以加上 `securityContext` 區塊來設定使用權限
查詢權限指令可以用這個指令 `cat /etc/passwd`
```
#x:使用者:群組
root:x:0:0:root:/root:/bin/bash
bin:x:2:2:bin:/bin:/usr/sbin/nologin
```

所以想用 root 的話就要設定這樣
```
securityContext:
	runAsUser: 0
	runAsGroup: 0
```

此外我們有用 `hostPath` 把資料夾 `/home/ladisai/curl_example` mount 上去 , 注意使用 hostPath 是指在 node 節點上的資料夾位置 , 實際用的話應該會 mount nfs , 這裡就偷懶
還有一點要特別小心 , 在 command 這個地方要執行多條的話需要在 args 內一直接下去 , 可以參考[這篇](https://stackoverflow.com/questions/33887194/how-to-set-multiple-commands-in-one-yaml-file-with-kubernetes)

cronjob.yaml
```
apiVersion: batch/v1
kind: CronJob
metadata:
  name: sendmail
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sendmail
            image: curlimages/curl
            volumeMounts:
            - mountPath: /test
              name: test-volume
            command: ["/bin/sh"]
            args: [
              "-c" ,
              "timestamp=$(date +%s);
              cp /test/mail_template.txt /test/mail_template_$timestamp.txt;
              curl http://10.1.25.123:30612/api/helloworld >> /test/mail_template_$timestamp.txt;
              echo $timestamp >> /test/mail_template_$timestamp.txt;
              curl smtp://email.xxx.com.tw:25 \ --user 'yourname@xxx.com:yourpassword' \ --mail-from 'yourname@xxx.com' \ --mail-rcpt 'yourname@xxx.com' \ --upload-file /test/mail_template_$timestamp.txt"
			]
            #args: ["-c" , "cd /test;pwd >> pwd.txt; cat /test/send_mail_command.sh >> qq.txt"]
            #args: ["-c" , "curl -L www.google.com >> /test/google.txt"]
          securityContext:
            runAsUser: 0
            runAsGroup: 0
          dnsPolicy: ClusterFirstWithHostNet
          dnsConfig:
            nameservers:
              - 10.1.30.5
          volumes:
          - name: test-volume
            hostPath:
              path: /home/yourname/curl_example
          restartPolicy: Never
```

mail_template.txt
```
From: "yourname" <yourname@xxx.com>
To: "yourname" <yourname@xxx.com>
Subject: This is a test

 _____
< Log >
 -----
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||
```

最後看看執行結果 , 如果是 completed 才 ok
```
k get cronjob
k get po
```

遇到 dns 問題或是權限問題 , 可以先建立一個 Pod 用這樣的方法測試看看 , 逐步偵錯 , 看是權限不足或是 dns 設定有問題
```
apiVersion: v1
kind: Pod
metadata:
  name: google-curl
spec:
  containers:
  - name: google-curl
    image: curlimages/curl
    command: ["/bin/sh"]
    args: ["-c" , "echo nameserver 10.1.2.87 >> /etc/resolv.conf; curl -L www.google.com"]
    securityContext:
      runAsUser: 0
      runAsGroup: 0

#k apply -f google-curl.yaml
#k logs google-curl
```

#### nfs server
[參考老外](https://www.digitalocean.com/community/tutorials/how-to-set-up-an-nfs-mount-on-ubuntu-20-04)
跟這個[大神](https://magiclen.org/ubuntu-server-nfs/)
這邊直接裝在 master node 上
```
#nfs server
sudo apt-get install nfs-kernel-server

#nfs client
sudo apt-get install nfs-common

sudo mkdir /var/nfs/general -p
sudo chown nobody:nogroup /var/nfs/general
ls -la /var/nfs/general
sudo chmod -R 777 /var/nfs/general

#設定可以連線的 client
sudo vim /etc/exports
/var/nfs/general 10.1.25.124(rw,sync,no_subtree_check)

#restart nfs
sudo systemctl restart nfs-kernel-server
```

跳到其他 node 執行以下命令
```
sudo apt-get install nfs-common
sudo mkdir -p /nfs/general

#注意非常重要 , 這邊要 mount master 那台 nfs server 不要寫錯了
sudo mount 10.1.25.123:/var/nfs/general /nfs/general
cd /nfs/general

#測試看看是否可以正常建立檔案 , ok 的話 master & node 都可以看到
echo "qq" > qq
cat qq
```


#### 安裝 Nginx Ingress Controller
預設情況下 k8s 不會幫你安裝 ingress controller , 需一自己安裝
[官網有多種選擇](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/)
因為有選擇障礙這邊用 nginx ingress controller 參考[官網](https://kubernetes.github.io/ingress-nginx/deploy/#docker-desktop)
此外由於預設為 `LoadBalancer` , 內部環境最好改為 `NodePort`
```
wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.47.0/deploy/static/provider/cloud/deploy.yaml

vim deploy.yaml
#搜尋 LoadBalancer
#/LoadBalancer

#修改為 NodePort
#spec:
#  type: NodePort
#  externalTrafficPolicy: Local

k apply -f deploy.yaml
```

安裝會多加上一個 namespace
```
k get ns
#NAME              STATUS   AGE
#default           Active   35d
#development       Active   14d
#foo               Active   22d
#ingress-nginx     Active   7m43s
```

所以要撈的話記得多加參數 `-n ingress-nginx` , 或是直接用 `-A` 撈全部
```
k get svc -n ingress-nginx
k get po -n ingress-nginx
k get svc -A
k get po -A
```

安裝好 nginx ingress controller 後會多加上一個 `NodePort` 來服務對外 , 剛好分配到好難聽的 port 名稱
```
k get svc -n ingress-nginx
#NAME                                 TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)                      AGE
#ingress-nginx-controller             LoadBalancer   10.106.114.179   <pending>     80:30678/TCP,443:31326/TCP   13m
#ingress-nginx-controller-admission   ClusterIP      10.104.100.19    <none>        443/TCP                      13m
```

補充 , 如果不想要對外多加上 `port 30678` 這麼醜的話可以考慮把 `hostPort` 設定起來這樣就可以直接打 80 , 443
```
vim deploy.yaml
#/Deployment

#搜尋 Deployment 找到以下片段
#
#ports:
#  - name: http
#    containerPort: 80
#    hostPort: 80
#    protocol: TCP
#  - name: https
#    containerPort: 443
#    hostPort: 443
```

接著看 nginx-controller 被分配到哪個 node
```
k get po -o wide -n ingress-nginx
#
NAME                                        READY   STATUS      RESTARTS   AGE   IP             NODE              NOMINATED NODE   READINESS GATES
ingress-nginx-admission-create-sx9f4        0/1     Completed   0          16m   10.244.1.172   node02   <none>           <none>
ingress-nginx-admission-patch-jxfx4         0/1     Completed   1          16m   10.244.1.171   node02   <none>           <none>
ingress-nginx-controller-5b74xc9xx8-dg6k5   1/1     Running     0          16m   10.244.1.173   node02   <none>           <none>
```

假設我 node02 的 vm ip 是 `10.1.25.124` , 所以等等就要打 `curl 10.1.25.124:30678/網址` , 試打看看會跳 nginx 頁面
```
curl 10.1.25.124:30678
#<html>
#<head><title>404 Not Found</title></head>
#<body>
#<center><h1>404 Not Found</h1></center>
#<hr><center>nginx</center>
#</body>
#</html>
```

接著把之前的 nodeport 修改一下讓他固定在 port 30345
asp-net-core-helloworld-k8s-service.yaml
```
apiVersion: v1
kind: Service
metadata:
    name: asp-net-core-helloworld-k8s
spec:
    type: NodePort
    ports:
    - port: 80 #service 的 port
      targetPort: 80 # .net core app 的 port
      nodePort: 30345 #外部的 port
    selector:
        app: asp-net-core-helloworld-k8s
```

先用 curl 測看看
```
curl 10.96.165.130/api/helloworld
#Host Name of machine =asp-net-core-helloworld-k8s-5766cd7cc5-js4sj
#IPv4 of Machine is
#10.244.1.119
#IPv6 of Machine is
```

確定都 ok 以後 , 可以加入 ingress 的資源 (舊版 extensions/v1beta1) , 特別注意這種定義方式需要 path 完全 match 否則會找不到
asp-net-core-helloworld-k8s-ingress.yaml
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  rules:
  - host: asp-net-core-helloworld-k8s.com
    http:
      paths:
      - path: /api/helloworld #注意這邊要跟 app 內的路徑完全一樣
        backend:
          serviceName: asp-net-core-helloworld-k8s
          servicePort: 80
```

修改 /etc/hosts , 若是想在 windows 上看的話位置在 `C:\Windows\System32\drivers\etc\hosts`
```
vim /etc/hosts
#10.1.25.124 asp-net-core-helloworld-k8s.com

#下面 example 會用到
#10.1.25.124 helloworld-k8s.com
#10.1.25.124 helloworld-contour-k8s.com
```

最後用 curl 測試一下
```
curl asp-net-core-helloworld-k8s.com:30678/api/helloworld
```

最後用新版的 api 測試看看 (新版 networking.k8s.io/v1) , 這樣定義的話即可讓全部的路徑 mapping 到你的 url
詳細可以參考[官網](https://kubernetes.io/docs/concepts/services-networking/ingress/)
asp-net-core-helloworld-k8s-ingress-new.yaml
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: asp-net-core-helloworld-k8s-new
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: helloworld-k8s.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: asp-net-core-helloworld-k8s
            port:
              number: 80
```

可以用這兩個頁面測試
http://helloworld-k8s.com:30678/swagger/index.html
http://helloworld-k8s.com:30678/api/helloworld


最後補充 nginx ingress controller 會在 `/etc/nginx/nginx.conf` 補上與剛剛設定的 helloworld-k8s.com , 可以跳進去看
```
k exec -it ingress-nginx-controller-5b74bxx868-lg47d -n ingress-nginx -- bash
#cat /etc/nginx/nginx.conf
#vi /etc/nginx/nginx.conf
```


### Helm 安裝 , 參考[官網](https://helm.sh/docs/intro/install/)
```
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

### 其他操作上的小技巧
這裡定義 `${VERSION}` 當作變數 , 並且定義 template.yaml , 可以接上 `envsubst` 快速替換內容來進行更版
另外注意到 `--record` 參數 , 可以更詳細記錄當時的指令
```
VERSION='v1.0' envsubst < template.yaml | k apply --record -f -
```

template.yaml
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: asp-net-core-helloworld-k8s
spec:
  replicas: 4
  selector:
    matchLabels:
      app: asp-net-core-helloworld-k8s
  template:
    metadata:
      labels:
        app: asp-net-core-helloworld-k8s
    spec:
      containers:
      - name: asp-net-core-helloworld-k8s
        image: 10.1.25.123/test/helloworldk8s:${VERSION}
        imagePullPolicy: Always
        ports:
        - containerPort: 80
        - containerPort: 443
        env:
        - name: ASPNETCORE_URLS
          value: http://+:80;https://+:443
        - name: ASPNETCORE_ENVIRONMENT
          value: Development
      imagePullSecrets:
      - name: regcred
```

apply 以後可以用以下指令去查目前更新狀態
```
k rollout status deployment asp-net-core-helloworld-k8s
```

列印出修改歷史
```
k rollout history deployment asp-net-core-helloworld-k8s
```

滾回之前的版本
```
#滾回上個版本
k rollout undo deployment asp-net-core-helloworld-k8s

#滾回特定的版本
k rollout undo deployment asp-net-core-helloworld-k8s --to-revision 5
```

金絲雀佈署因為只多加一個新版的 pod , 所以可以用暫停命令來串
```
VERSION='v1.1' envsubst < template.yaml | k apply --record -f - && \
k rollout pause deployment asp-net-core-helloworld-k8s
```


Here Document 這個技巧可以直接在 command 內快速加上想補的內容
```
'cat <<EOF > /etc/resolv.conf
nameserver 8.8.8.8
EOF'
```

### 其他補充
編輯東西前務必知道的[官網說明](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)

跳進去看看環境變數
```
exec -it asp-net-core-helloworld-k8s-5766cd7cc5-js4sj -- /bin/bash
env | grep ASPNETCORE_URLS
```

開啟 chrome 測試這邊要改成用 curl 測試 , 因為 chrome 會用 keep-alive 連線 , 而 curl 每次都會開一個新的連線

如果想讓每個相同 client ip 都轉到同個 pod 上的話可以開啟這個選項
```
kind: Service
spec:
	sessionAffinity: ClientIP
```


