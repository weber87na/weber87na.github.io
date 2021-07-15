---
title: k8s 安裝筆記
date: 2021-06-29 03:27:42
tags: k8s
---
&nbsp;
<!-- more -->
### k8s master install 安裝事前準備
RAM 2GB
CPU 2
禁用 swap

### 在 hyper-v 上安裝 ubuntu
(https://linuxhint.com/install_ubuntu_1804_lts_hyperv/)

`新增虛擬機` => `下一步` => `名稱: k8s-master` => `第一代` => `2048MB` => `Default Switch`
=> `k8s-master.vhdx` => `從可開機 CD/DVD-ROM 安裝作業系統` => `iso` => `Done` => `CUP * 2`
name:master
pwd:gg

### Ubuntu 安裝 docker
```
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt update
apt-cache policy docker-ce
sudo apt install docker-ce
sudo systemctl status docker
```

### k8s 事前準備
這邊比較雷是防火牆 , 一般的書籍或文件指介紹 `swapoff` 命令 , 沒寫要修改 `/etc/fstab` 關閉的方法
```
#更新
sudo apt update
sudo apt upgrade

#關防火牆
sudo ufw disable
sudo ufw status

#關閉 swap
sudo swapoff -a
sudo vim /etc/fstab

#永久關閉
#註解這段
##/swapfile
```

### 以 kubeadm 安裝 k8s
[安裝 k8s](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)
```
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl

sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 安裝 zsh 補全
[參考說明](https://kubernetes.io/zh/docs/tasks/tools/included/optional-kubectl-configs-zsh/)
萬一出現靈異事件 , 登出以後應該就會生效
```
source <(kubectl completion zsh)
echo 'alias k=kubectl' >>~/.zshrc
echo 'complete -F __start_kubectl k' >>~/.zshrc
source ~/.zshrc
```

另外記得 vim 開 zshrc 找到 plugins 加入 kubectl
```
vim ~/.zshrc
#plugins=(
#  git
#  kubectl
#)
```


### 用 kubeadm 建立 cluster
[參考印度仔](https://k21academy.com/docker-kubernetes/three-node-kubernetes-cluster/)
[官方](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

直接執行會炸 error 只要加 sudo 即可
```
kubeadm init --apiserver-advertise-address 10.1.25.123 --pod-network-cidr 10.244.0.0/16


#[init] Using Kubernetes version: v1.21.1
#[preflight] Running pre-flight checks
#error execution phase preflight: [preflight] Some fatal errors occurred:
#        [ERROR IsPrivilegedUser]: user is not running as root
#[preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
#To see the stack trace of this error execute with --v=5 or higher
```


初始化 kubeadm 大概要等個 1-2 分鐘 , 搞定後會 dump 下面的訊息
注意這段訊息 , 沒裝過的話超黑人問號

```
detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
https://chengdol.github.io/2019/03/09/k8s-systemd-cgroup-driver/
```

修正上述 systemd 的問題
```
docker info | grep Cgroup

#Cgroup Driver: cgroupfs

sudo vim /etc/docker/daemon.json
sudo service docker restart
#加入這段
#{
#  "exec-opts": ["native.cgroupdriver=systemd"]
#}
```

實際執行結果
```
sudo kubeadm init --apiserver-advertise-address 10.1.25.123 --pod-network-cidr 10.244.0.0/16 --token-ttl 0

[init] Using Kubernetes version: v1.21.1
[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Pulling images required for setting up a Kubernetes cluster
[preflight] This might take a minute or two, depending on the speed of your internet connection
[preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
[certs] Using certificateDir folder "/etc/kubernetes/pki"
[certs] Generating "ca" certificate and key
[certs] Generating "apiserver" certificate and key
[certs] apiserver serving cert is signed for DNS names [test01 kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 10.1.25.123]
[certs] Generating "apiserver-kubelet-client" certificate and key
[certs] Generating "front-proxy-ca" certificate and key
[certs] Generating "front-proxy-client" certificate and key
[certs] Generating "etcd/ca" certificate and key
[certs] Generating "etcd/server" certificate and key
[certs] etcd/server serving cert is signed for DNS names [test01 localhost] and IPs [10.1.25.123 127.0.0.1 ::1]
[certs] Generating "etcd/peer" certificate and key
[certs] etcd/peer serving cert is signed for DNS names [test01 localhost] and IPs [10.1.25.123 127.0.0.1 ::1]
[certs] Generating "etcd/healthcheck-client" certificate and key
[certs] Generating "apiserver-etcd-client" certificate and key
[certs] Generating "sa" key and public key
[kubeconfig] Using kubeconfig folder "/etc/kubernetes"
[kubeconfig] Writing "admin.conf" kubeconfig file
[kubeconfig] Writing "kubelet.conf" kubeconfig file
[kubeconfig] Writing "controller-manager.conf" kubeconfig file
[kubeconfig] Writing "scheduler.conf" kubeconfig file
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Starting the kubelet
[control-plane] Using manifest folder "/etc/kubernetes/manifests"
[control-plane] Creating static Pod manifest for "kube-apiserver"
[control-plane] Creating static Pod manifest for "kube-controller-manager"
[control-plane] Creating static Pod manifest for "kube-scheduler"
[etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
[wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
[apiclient] All control plane components are healthy after 24.505356 seconds
[upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
[kubelet] Creating a ConfigMap "kubelet-config-1.21" in namespace kube-system with the configuration for the kubelets in the cluster
[upload-certs] Skipping phase. Please see --upload-certs
[mark-control-plane] Marking the node test01 as control-plane by adding the labels: [node-role.kubernetes.io/master(deprecated) node-role.kubernetes.io/control-plane node.kubernetes.io/exclude-from-external-load-balancers]
[mark-control-plane] Marking the node test01 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
[bootstrap-token] Using token: coba61.otmz27gm3ztjlzuw
[bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
[bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
[bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
[bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
[bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
[kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
[addons] Applied essential addon: CoreDNS
[addons] Applied essential addon: kube-proxy

Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

Alternatively, if you are the root user, you can run:

  export KUBECONFIG=/etc/kubernetes/admin.conf

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join 10.1.25.123:6443 --token coba61.otmz27xxxxxx \
        --discovery-token-ca-cert-hash sha256:29ce1ab9fc6dfa017xxxxxxx
```

比較重要的是要在 master 機器執行這段指令
```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

export KUBECONFIG=/etc/kubernetes/admin.conf

#echo $KUBECONFIG
```

接著設定網路 這邊用常用的 flannel 模組 , 不過比較新的文件這個 flannel 好像沒在用了!?
```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

接著在 node 上面執行 , 記得一樣要用 sudo , 不然會炸 error , 注意是 node 機器
```
kubeadm join 10.1.25.123:6443 --token 45g0g0.avd3ynlzt8pxz9ag \
        --discovery-token-ca-cert-hash sha256:4996f8aab643b1ac908d3bdd1a6bda7b5086f457db61bd62f8cef23e073e9aa6

[preflight] Running pre-flight checks
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
[preflight] Reading configuration from the cluster...
[preflight] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
[kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
[kubelet-start] Starting the kubelet
[kubelet-start] Waiting for the kubelet to perform the TLS Bootstrap...

This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.

```

node 加入以後在 master 機器執行以下 command 驗證 node 是否 ok , 萬一炸以下 error
退出 ssh 再次登入看看 , 或是等一陣子因為加入 node 需要時間 , 或是檢查上面的步驟是否有漏掉
```
kubectl get nodes
#The connection to the server localhost:8080 was refused - did you specify the right host or port
```

萬一狀態是 NotReady 的話 , 可能是網路沒有進行 config


token 問題 , 注意 token 預設只有 24 小時 , 可能會過期 cluster node 就掛了?
https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/



kubelet [錯誤排除](https://ithelp.ithome.com.tw/articles/10198938)
萬一完全解決不了直接移除參考這篇 (https://gist.github.com/meysam-mahmoodi/fc014053d984dcc5d1c0d6709773e199)
-/etc/default/kubelet
[安裝參考](https://ithelp.ithome.com.tw/articles/10235069)
```
cd /etc/systemd/system/kubelet.service.d
sudo vim

# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env

EnvironmentFile="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd --runtime-cgroups=/systemd/system.slice --kubelet-cgroups=/systemd/system.slice

# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS $KUBELET_CGROUP_ARGS
```

萬一遇到一堆 Error 最快解法 rest 全部 node
```
sudo kubeadm reset

[reset] Reading configuration from the cluster...
[reset] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[reset] WARNING: Changes made to this host by 'kubeadm init' or 'kubeadm join' will be reverted.
[reset] Are you sure you want to proceed? [y/N]: y
[preflight] Running pre-flight checks
[reset] Removing info for node "test01" from the ConfigMap "kubeadm-config" in the "kube-system" Namespace
[reset] Stopping the kubelet service
[reset] Unmounting mounted directories in "/var/lib/kubelet"
[reset] Deleting contents of config directories: [/etc/kubernetes/manifests /etc/kubernetes/pki]
[reset] Deleting files: [/etc/kubernetes/admin.conf /etc/kubernetes/kubelet.conf /etc/kubernetes/bootstrap-kubelet.conf /etc/kubernetes/controller-manager.conf /etc/kubernetes/scheduler.conf]
[reset] Deleting contents of stateful directories: [/var/lib/etcd /var/lib/kubelet /var/lib/dockershim /var/run/kubernetes /var/lib/cni]

The reset process does not clean CNI configuration. To do so, you must remove /etc/cni/net.d

The reset process does not reset or clean up iptables rules or IPVS tables.
If you wish to reset iptables, you must do so manually by using the "iptables" command.

If your cluster was setup to utilize IPVS, run ipvsadm --clear (or similar)
to reset your system's IPVS tables.

The reset process does not clean your kubeconfig files and you must remove them manually.
Please, check the contents of the $HOME/.kube/config file.
```

萬一一直搞不定 cgroup 直接移除
```
kubeadm reset
sudo apt-get purge kubeadm kubectl kubelet kubernetes-cni kube*
sudo apt-get autoremove
sudo rm -rf ~/.kube
```


token 的問題可以參考這篇
http://blog.51yip.com/cloud/2404.html

https://blog.johnwu.cc/article/kubernetes-nodes-notready.html
兩個超重要的檔案
`/etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
`/var/lib/kubelet/kubeadm-flags.env`

https://juejin.cn/post/6844903689572843534
`/lib/systemd/system/kubelet.service`



### CGROUP 設定
[參考自](https://chengdol.github.io/2019/03/09/k8s-systemd-cgroup-driver/)
```
#用 vim 修改 CGROUP 方法 1
vim /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
Environment="KUBELET_CGROUP_ARGS=--cgroup-driver=systemd"
ExecStart=/usr/bin/kubelet $KUBELET_KUBECONFIG_ARGS $KUBELET_CONFIG_ARGS $KUBELET_KUBEADM_ARGS $KUBELET_EXTRA_ARGS $KUBELET_CGROUP_ARGS

#用 vim 修改 CGROUP 方法 2
vim /var/lib/kubelet/kubeadm-flags.env
#KUBELET_KUBEADM_ARGS="--network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.4.1
KUBELET_KUBEADM_ARGS="--cgroup-driver=systemd --pod-infra-container-image=k8s.gcr.io/pause:3.4.1"


#更新
sudo systemctl daemon-reload
sudo systemctl restart kubelet

#查結果
sudo systemctl status kubelet -l
ps aux | grep kubelet

```

### KIND 安裝
注意這個暴雷 , 會直接幫你安裝 docker desktop
```
choco install kind
```

建立 cluster 可以參考[老外](https://mcvidanagama.medium.com/set-up-a-multi-node-kubernetes-cluster-locally-using-kind-eafd46dd63e5]
或是[鐵人賽大神](https://ithelp.ithome.com.tw/articles/10240561)
```
nvim kind.yaml
kind create cluster --config kind.yaml

kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
```

蓋好了以後開始查看看 , 注意預設不會安裝 kubectl , 需要自行安裝 , 我機器上何時安裝的已不可考
```
k get nodes
#NAME                 STATUS   ROLES                  AGE     VERSION
#kind-control-plane   Ready    control-plane,master   2m21s   v1.21.1
#kind-worker          Ready    <none>                 115s    v1.21.1
#kind-worker2         Ready    <none>                 115s    v1.21.1
```

### k8s plugin Krew 安裝
基本上參考[官網](https://krew.sigs.k8s.io/docs/user-guide/setup/install/#bash)無腦安裝
```
(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" &&
  tar zxvf krew.tar.gz &&
  KREW=./krew-"${OS}_${ARCH}" &&
  "$KREW" install krew
)
```

加入以下到環境變數 , 並且執行 echo 看看
```
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
#看看有無成功
echo $PATH
```

最好直接加入到 zshrc or bashrc
```
vim ~/.zshrc
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

#讓 zshrc 生效
source ~/.zshrc
```

執行這段有 run 就代表 ok
```
kubectl krew
```

特別注意的是外掛的使用一般都是這樣
```
kubectl pluginname command
kubectl-pluginname command
k pluginname command
```

接著安裝感覺好像比較有用的 plugin

[tree](https://github.com/ahmetb/kubectl-tree)
```
kubectl krew install tree
kubectl tree --help

#用法
kubectl tree deployment kubia
```


[sql](https://github.com/yaacov/kubectl-sql)
```
kubectl krew install sql

#用法

#找狀態是 Running 的
k sql get po where "phase = 'Running'"

#找狀態不是 Running 的 , 表示有問題啦
k sql get po where "phase != 'Running'"

#找名字 , 可以直接用 like
kubectl-sql get po where "name like '%w%'"
```


覺得不滿意的話可以自己寫 plugin , 以喇低賽的 `cowsay` 為例 , 只要把程式命名為 `kubectl-` 開頭複製到 `/usr/local/bin/` 底下即可
詳細可以[參考官方說明](https://kubernetes.io/docs/tasks/extend-kubectl/kubectl-plugins/)
```
sudo apt-get install cowsay
cowsay "helloworld"

#查 cowsay 安裝在哪
which cowsay

#確認內容
cat /usr/games/cowsay

#複製並且重新命名
sudo cp /usr/games/cowsay /usr/local/bin/kubectl-cowsay

#不想用要移除的話
sudo rm /usr/local/bin/kubectl-cowsay
```

### k8s cluster 升級
升級過程主要參考[官網](https://kubernetes.io/zh/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

某天在測試機器 master 節點執行以下命令 , 不曉得啥時被更新成 `v1.21.2`
```
k get nodes
#NAME              STATUS   ROLES                  AGE   VERSION
#master			   Ready    control-plane,master   26d   v1.21.2
#node02			   Ready    <none>                 26d   v1.21.1
#node03			   Ready    <none>                 26d   v1.21.1
```

更新 master 節點
```
sudo apt-mark unhold kubeadm && \
sudo apt-get update && sudo apt-get install -y kubeadm=1.21.2-00 && \
sudo apt-mark hold kubeadm
```

檢查升級計畫
```
sudo kubeadm upgrade plan
```

以下為印出的訊息
```
[upgrade/config] Making sure the configuration is correct:
[upgrade/config] Reading configuration from the cluster...
[upgrade/config] FYI: You can look at this config file with 'kubectl -n kube-system get cm kubeadm-config -o yaml'
[preflight] Running pre-flight checks.
[upgrade] Running cluster health checks
[upgrade] Fetching available versions to upgrade to
[upgrade/versions] Cluster version: v1.21.1
[upgrade/versions] kubeadm version: v1.21.2
[upgrade/versions] Target version: v1.21.2
[upgrade/versions] Latest version in the v1.21 series: v1.21.2

Components that must be upgraded manually after you have upgraded the control plane with 'kubeadm upgrade apply':
COMPONENT   CURRENT       TARGET
kubelet     2 x v1.21.1   v1.21.2
            1 x v1.21.2   v1.21.2

Upgrade to the latest version in the v1.21 series:

COMPONENT                 CURRENT    TARGET
kube-apiserver            v1.21.1    v1.21.2
kube-controller-manager   v1.21.1    v1.21.2
kube-scheduler            v1.21.1    v1.21.2
kube-proxy                v1.21.1    v1.21.2
CoreDNS                   v1.8.0     v1.8.0
etcd                      3.4.13-0   3.4.13-0

You can now apply the upgrade by executing the following command:

        kubeadm upgrade apply v1.21.2

_____________________________________________________________________


The table below shows the current state of component configs as understood by this version of kubeadm.
Configs that have a "yes" mark in the "MANUAL UPGRADE REQUIRED" column require manual config upgrade or
resetting to kubeadm defaults before a successful upgrade can be performed. The version to manually
upgrade to is denoted in the "PREFERRED VERSION" column.

API GROUP                 CURRENT VERSION   PREFERRED VERSION   MANUAL UPGRADE REQUIRED
kubeproxy.config.k8s.io   v1alpha1          v1alpha1            no
kubelet.config.k8s.io     v1beta1           v1beta1             no
```

接著執行以下命令 master 即可完成升級
```
sudo kubeadm upgrade apply v1.21.2
```

node 升級 (注意是在 master 執行此命令)
```
kubectl drain node02 --ignore-daemonsets
```

中間出現以下錯誤
```
node/node02 cordoned
error: unable to drain node "node02", aborting command...

There are pending nodes to be drained:
 node02
error: cannot delete Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet (use --force to override): default/helloworld
```

暫時把 pod `default/helloworld` 幹掉
```
k delete po helloworld
```

或是直接使用 `--force` 命令亦可
```
kubectl drain node02 --ignore-daemonsets --force
```

更新 `kubectl` & `kubelet`
```
sudo apt-mark unhold kubelet kubectl
sudo apt-get update
sudo apt-get install -y kubelet=1.21.2-00 kubectl=1.21.2-00
sudo apt-mark hold kubelet kubectl
```

restart kubelet
```
sudo systemctl daemon-reload
sudo systemctl restart kubelet
```

取消對節點的保護
```
kubectl uncordon node02
```

至此則更新成功
```
k get nodes

#NAME              STATUS   ROLES                  AGE   VERSION
#master   Ready    control-plane,master   26d   v1.21.2
#node02   Ready    <none>                 26d   v1.21.2
#node03   Ready    <none>                 26d   v1.21.1
```


### docker 常用命令 vs k8s 常用命令

#### 刪除指令
這滿容易就搞混的 docker 使用 rm , k8s 使用 delete

docker 刪除
```
docker container rm c4bbaab0f7fd
```

k8s 刪除
```
k delete po xxoo
```

#### 查容器或是 pod 狀態
這也是常常會打錯的問題 docker 使用 inspect , k8s 使用 describe

docker 查狀態
```
docker inspect 3e3bee70d0b
```

k8s 查狀態
```
docker describe po asp-net-core-helloworld-k8s-66f969cb87-69jss
```

#### 跳到容器執行命令

docker
```
docker exec -it 54a /bin/bash
docker exec -it 54a ls
```

特別注意到使用 kubectl 進入容器時最好加上兩條橫槓 `--` 然後才接參數

k8s
```
k exec -it asp-net-core-helloworld-k8s-66f969cb87-69jss -- /bin/bash
k exec -it asp-net-core-helloworld-k8s-66f969cb87-69jss -- ls
```

#### 複製 cp

docker 的 cp
```
#複製 host 檔案到 container
docker cp "C:\Program Files\Git\etc\vimrc" 404b2c:/root/vimrc

#複製 container 檔案到 host
docker cp 404b2c:/root/.vimrc ${PWD}/vimrcnew
```

k8s 的 cp
```
#k8s 複製 haha 這個檔案到 pod 內
k cp haha java-sfc-k8s-dns-7cfc8db5f6-djjlw:/var/log/

#k8s 複製 pod 內的 qoo 到 host
k cp java-sfc-k8s-dns-7cfc8db5f6-djjlw:/qoo qoo
```

#### 查 log
難得有個統一的 , 注意 `-f` 參數為 follow 會一直輸出 , 退出使用 `Ctrl + c`
docker 查 log
```
docker logs 54a
docker logs 54a -f
```

docker 查 log
```
k logs asp-net-core-helloworld-k8s-66f969cb87-69jss
k logs asp-net-core-helloworld-k8s-66f969cb87-69jss -f
```

### dashboard 安裝
下載 dashboard 的 yaml 檔 , 接著修改 Service 讓他從原本的 ClusterIP 變成 NodePort 方便我們訪問
```
mkdir dashboard
cd dashboard
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.2.0/aio/deploy/recommended.yaml
vim recommended.yaml

#kind: Service
#apiVersion: v1
#metadata:
#  labels:
#    k8s-app: kubernetes-dashboard
#  name: kubernetes-dashboard
#  namespace: kubernetes-dashboard
#spec:
#  ports:
#    - port: 443
#      targetPort: 8443
#  selector:
#    k8s-app: kubernetes-dashboard
#  type: NodePort #補上這個

k apply -f recommended.yaml
```

用 chrome 開啟 dashboard 測試看看 , 可能長這樣子 https://10.1.30.191:31061/#/login
此時他會跟你要 token , 問題我們沒有 token , [主要參考這篇](https://upcloud.com/community/tutorials/deploy-kubernetes-dashboard/)
```
#

apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

先看看 ServiceAccount , 可以用以下指令取得 token name
這邊有個技巧就是用 jq 撈 `-r` 代表 raw 可以去掉雙引號
注意撈這些東西後面看到 % 符號的話通常表示結尾符號 , 是不需要填的
```
k get sa -n kubernetes-dashboard
k describe sa admin-user -n kubernetes-dashboard

#撈 token 名稱
k get sa -n kubernetes-dashboard admin-user -o jsonpath="{.secrets[0].name}"

#jq 撈 token 名稱
k get sa -n kubernetes-dashboard admin-user -o json | jq -r '.secrets[0].name'

#yq 撈 token 名稱
k get sa -n kubernetes-dashboard admin-user -o yaml | yq e '.secrets[0].name' -
```

接著看看目前的 secret , 這邊組合了原生撈法 , jq , yq , 另外注意 secret 撈出來是 base64 需要做 decode 動作
```
k get secret -n kubernetes-dashboard

#組合 token 名稱與 secret 看看有啥資訊
TNAME=$(k get sa -n kubernetes-dashboard admin-user -o json | jq -r '.secrets[0].name')

#用 yq 撈
#TNAME=$(k get sa -n kubernetes-dashboard admin-user -o yaml | yq e '.secrets[0].name' -)
k get secret -n kubernetes-dashboard $TNAME -o yaml

#會長這樣
#apiVersion: v1
#data:
#  ca.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeE1EWXdNekF4TkRreU9Gb1hEVE14TURZd01UQXhORGt5T0Zvd0ZURVRNQ
#kVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBTCs2CnJxaysrcmI4RUJ0YUZWS0QwaW5CSGRFc2RDdTBNVm9jV0JCMmVDYXEwUDhrUlUyTFIwMVlmZW52K3BpVnlPVlIKc2ZvTGt6Nnl3L3IwVUR5bEJLK2hB
#RUVBcStHRUxJTVhJU2FqMzErS2FwV1R1ejNac0ZVUENxeENDZFMrMW9FMQpZdWNaRXhxRUdxS3JNa2wrQWF0dGtuOTFwYngvc2ZzeHdRdGo0ZVl0ZC8yVjhaNzJiYVh2Nncxeisvb3dUZ3lqClVZYUY1Wm4wMnVOeXZmTW9tWnhhMTVBNUZMSituRFlXYVRrVzNZS2NKY2UraDNQQWM
#wdjU0M0RmK21kbExiVTkKNk5pSmFVZEhTUjFLQUo0aVhQM1BDNGRxMUZFTnVnN1JUN3VnRmxRN3B1NnBTOElUN2NOUnp4TFEwcC93clpBYwp6cmZtbjRkYmxSWjBMQ1UzMzgwQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0
#hRWURWUjBPQkJZRUZLQkV0UFdydVJYMDFkSHREZXF6L0V1cFhpbUdNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFCOXNyQXgySmt5b3FERXhDSjg5Tk52R0JIL01TcmswbHZoRGhxaEJDbmd4QURGazZEWQpLbzQyUG5rMHdMY3BOVzF0bUc5T080T3FGa2VMUEdWK29wR3NKMjEwZ
#FV6dnJSbzdVUk5PQVlRQjVJQU04bklJClRpZk5TWHFsRzJkQzNPVGNqbHoxYVVwUzRqZGRUUEtESmoxU0ZFT0o0OVRBdko5VEpqRjhvOElDc3NQcDJnRWQKL1VRZEtmTlRodDRSaEd2TVdjcWxGT3l6MkFySTFhRUphWFFUSS9teXBIdXhiSERveDB1UVg1aG43K3dMYTZDTgpFZ0dQ
#YnZ4d2ZlWUltY25uL1dHQU5kQkJLenVYbExnQzJRanFCdDdEeWJ5enorMkE5V2liM2x5TEx6VnpiWGRNCmh5b0ZZSjcvTmlKOXQzMlZuRXh2NUg4ZEFvZ0RFbWV5RXhJKwotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
#  namespace: a3ViZXJuZXRlcy1kYXNoYm9hcmQ=
#  token: XXlKaGJHY2lPaUpTVXpJMU5pSXNJbXRwWkNJNklqUnRjMGh3U0U1S2JVUklRMVU0WHpsb2NHRlNWRE5XVEZsalpHYzNUVm95V1d4U2NWSkhjMHBYVDFraWZRLmV5SnBjM01pT2lKcmRXSmxjbTVsZEdWekwzTmxjblpwWTJWaFkyTnZkVzUwSWl3aWEzVmlaWEp1WlhSbG
#N5NXBieTl6WlhKMmFXT1xZV02qYjNWdWRDOXVZVzFsYzNCaFkyVWlPaUpyZFdKbGNtNWxkR1Z6TFdSaGMyaGliMkZ5WkNJc0ltdDFZbVZ5Ym1WMFpYTXVhVzh2YzJWeWRtbGpaV0ZqWTI5MWJuUXZjMlZqY21WMExtNWhiV1VpT2lKcmRXSmxjbTVsZEdWekxXUmhjMmhpYjJGeVpDM
#TBiMnRsYmkxMlpEVmpjaUlzSW10MVltVnlibVYwWlhNdWFXOHZjMlZ5ZG1salpXRmpZMjkxYm5RdmXyVnlkbWxqWlMxaFkyTnZkVzUwTG01aGJXVWlPaUpyZFdKbGNtNWxkR1Z6TFdSaGMyaGliMkZ5WkNJc0ltdDFZbVZ5Ym1WMFpYTXVhVzh2YzJWeWRtbGpaV0ZqWTI5MWJuUXZj
#MlZ5ZG1salpTMWhZMk52ZFc1MExuVnBaQ0k2SWpnd09USTNNek15TFRKa1ltSXROR0kxTmkwNE9UQmtMV1V6TTJVd016ZzNNR0kzWmlJc0luTjFZaUk2SW5ONWMzUmxiVHB6WlhKMmFXTmxZV05qYjNWdWREcHJkV0psY201bGRHVnpMV1JoYzJoaWIyRnlaRHByZFdKbGNtNWxkR1Z
#6TFdSaGMyaGliMkZ5WkNKOS5TcTYwVjBBcGM3VnUtNno1VVVQV2dvTVl4X0t1dWNoTHhNajc3SEFmdjdrTGxaNmlKckY5aGl1UVR6UkJhWXdxOUNrQkt3NHFod2tPUWZLX0ZWYjhNbkVVV2hsTURyRUltOWVYalVDU3MteEFiV1dmMzNCNGV2Zl8xNEFWMklOTTAzaGRSNS1jWk1aQX
#ZlMG80TDNvTU9OamhJMWNIdW9kN0hjd2ZJMEtxMUFGemxid1ZYQlI0NUlUYXV0U1JWVl9walhjZ2puR0o2aW5oYll121EwUXpDakpkRGdaX3FXdk9KQUVFd3V4WXdsNk1oazJBaVBGb0xRMUdRWDZMaUgxNEQ5RVU2T0U4OHJzd2hOZU0tTjBkZ0NaeVZwbTBkRWlBMldqczlUd0cxc
#kc2M2FrTEZVQkEzeXo4X0JWTEIwWFdWNnIyc1V0bEplN1dINzluQ0oyZ0E=
#kind: Secret
#metadata:
#  annotations:
#    kubernetes.io/service-account.name: kubernetes-dashboard
#    kubernetes.io/service-account.uid: 80927332-2dbb-4b56-890d-e33e03870b7f
#  creationTimestamp: "2021-07-13T02:07:07Z"
#  name: kubernetes-dashboard-token-vd5cr
#  namespace: kubernetes-dashboard
#  resourceVersion: "4934766"
#  uid: 6d0d9a76-2653-48c2-8ba2-cf9c62e312ca
#type: kubernetes.io/service-account-token


#最後可以這樣撈出正確的 token , 注意因為是 base64 所以要 decode
k get secret -n kubernetes-dashboard $TNAME -o json | jq -r '.data.token' | base64 -d
```

接著建立 Read-Only user , 一樣自己撈 token 即可測試 , 就不多寫了
dashboard-read-only.yaml
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: read-only-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
  name: read-only-clusterrole
  namespace: default
rules:
- apiGroups:
  - ""
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-only-binding
roleRef:
  kind: ClusterRole
  name: read-only-clusterrole
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: read-only-user
  namespace: kubernetes-dashboard
```


### 客製化 prompt 
因為使用 zsh , 所以用 zsh 當 example
```
cd ~/.oh-my-zsh/themes
echo $ZSH_THEME
cp robbyrussell.zsh-theme myrobbyrussell.zsh-theme
vim myrobbyrussell.zsh-theme

#多加這行取得 IP
#PROMPT=$(hostname -I | awk '{print $1}')
#這行取得目前使用的 context
#PROMPT+=kubectl config current-context
#...其他內容

vim ~/.zshrc
#修改ZSH_THEME
#ZSH_THEME="myrobbyrussell"

#重新 load config
source ~/.zshrc
```

### 好用工具 yq 地雷
因為看大神使用 yq 及 jq 實際操作 yq 已經升級為 v4 , 命令差滿多的 , 被雷的不要不要的 , 狂炸 permission denied
翻官網最雷的就是這句 `yq installs with strict confinement in snap, this means it doesn't have direct access to root files. To read root files you can:`
萬一檔案是屬於 `root` 要這樣操作才能 work
`-` 切身分 root 的意思
```
sudo cat /etc/myfile | yq e '.a.path' -
```
不然平常只要這樣寫就可以
```
yq e '.apiVersion' curl.yaml
```

第二個雷就是以 `.` 當作文件的 root , v3 寫的時候應該不用先寫 `.` , 詳細還是看看官方[升級說明](https://mikefarah.gitbook.io/yq/upgrading-from-v3)
以 k8s 拿 ca 的 example 會變成要這樣寫
```
sudo cat controller-manager.conf | yq e '.users[0].user.client-certificate-data' -
sudo cat controller-manager.conf | yq e '.apiVersion' -
```

最後是補全 , 好像沒那麼實用 , 我是用 zsh
```
echo "autoload -U compinit; compinit" >> ~/.zshrc
yq shell-completion zsh > "${fpath[1]}/_yq"
```
